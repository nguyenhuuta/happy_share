import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:happy_share/core/config/env.dart';
import 'package:happy_share/core/network/api_client.dart';
import 'package:happy_share/core/network/auth_tokens.dart';
import 'package:happy_share/core/session/app_session_cubit.dart';
import 'package:happy_share/core/storage/local_data_cleaner.dart';
import 'package:happy_share/core/storage/secure_token_store.dart';
import 'package:happy_share/features/auth/data/repository/auth_repository.dart';
import 'package:happy_share/features/auth/data/repository/me_repository.dart';
import 'package:happy_share/features/family/data/repository/family_repository.dart';

// ---------------------------------------------------------------------------
// Kho token & dọn dữ liệu
// ---------------------------------------------------------------------------

class MemoryTokenStore implements TokenStore {
  AuthTokens? tokens;

  @override
  Future<AuthTokens?> read() async => tokens;

  @override
  Future<void> write(AuthTokens t) async => tokens = t;

  @override
  Future<void> clear() async => tokens = null;
}

/// Giống [DefaultLocalDataCleaner] nhưng đếm số lần gọi để test hành vi dọn dữ liệu.
class RecordingCleaner implements LocalDataCleaner {
  RecordingCleaner(this._tokens);

  final TokenStore _tokens;
  int clearAllCalls = 0;
  int clearLocationCalls = 0;

  @override
  Future<void> clearAll() async {
    clearAllCalls++;
    await _tokens.clear();
  }

  @override
  Future<void> clearLocationData() async => clearLocationCalls++;
}

// ---------------------------------------------------------------------------
// HTTP giả
// ---------------------------------------------------------------------------

typedef Reply = ({int status, Object? body});

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final FutureOr<Reply> Function(RequestOptions options) handler;
  final List<RequestOptions> calls = [];

  Iterable<RequestOptions> to(String path) =>
      calls.where((c) => c.path == path);
  int count(String path) => to(path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    final reply = await handler(options);
    final isText = reply.body is String;
    return ResponseBody.fromString(
      isText ? reply.body as String : jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [
          isText ? 'text/html' : Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Reply ok(Object? data, {int status = 200}) =>
    (status: status, body: {'success': true, 'data': data, 'error': null});

Reply apiError(int status, String code, {Map<String, dynamic>? details}) => (
  status: status,
  body: {
    'success': false,
    'data': null,
    'error': {'code': code, 'message': 'x', 'details': details ?? {}},
  },
);

AuthTokens tokensOf(String access, String refresh) => AuthTokens(
  accessToken: access,
  refreshToken: refresh,
  accessExpiresAt: DateTime.utc(2030),
  refreshExpiresAt: DateTime.utc(2031),
);

Map<String, dynamic> tokensJson(String access, String refresh) => {
  'access_token': access,
  'refresh_token': refresh,
  'access_expires_at': '2030-01-01T00:00:00Z',
  'refresh_expires_at': '2031-01-01T00:00:00Z',
};

// ---------------------------------------------------------------------------
// Dữ liệu mẫu đúng hợp đồng A4 (snake_case, ISO UTC)
// ---------------------------------------------------------------------------

Map<String, dynamic> userJson({
  String id = 'u1',
  String identifier = 'mai.tran',
  String type = 'username',
  String displayName = 'Mẹ',
}) => {
  'id': id,
  'identifier': identifier,
  'identifier_type': type,
  'display_name': displayName,
  'avatar_url': null,
  'timezone': 'Asia/Ho_Chi_Minh',
  'created_at': '2026-11-09T02:00:00Z',
};

Map<String, dynamic> familyJson({int memberCount = 1, String plan = 'beta'}) =>
    {
      'id': 'f1',
      'name': 'Nhà Nguyễn',
      'timezone': 'Asia/Ho_Chi_Minh',
      'owner_user_id': 'u1',
      'plan': plan,
      'member_count': memberCount,
      'created_at': '2026-11-09T02:00:00Z',
    };

Map<String, dynamic> memberJson({
  String id = 'm1',
  String userId = 'u1',
  String displayName = 'Mẹ',
  String? nickname,
  String role = 'owner',
  String sharing = 'not_shared',
  bool isMe = true,
  String status = 'active',
}) => {
  'member_id': id,
  'user_id': userId,
  'display_name': displayName,
  'nickname': nickname,
  'avatar_url': null,
  'role': role,
  'status': status,
  'joined_at': '2026-11-09T02:00:00Z',
  'sharing_state': sharing,
  'is_me': isMe,
};

/// `GET /me` (hợp đồng 2.0). `withFamily` → một nhóm "Nhà Nguyễn" (`families` rỗng nếu false).
/// `consentStatus`: `'none'` = chưa từng bật ghi nhận (object với status null); còn lại là giá trị
/// `consent_status`. `consent` luôn là object, kể cả khi chưa có nhóm nào (D15).
Map<String, dynamic> meJson({
  bool withFamily = true,
  String consentStatus = 'none',
}) => {
  'user': userJson(),
  'families': [
    if (withFamily) {'family': familyJson(), 'member': memberJson()},
  ],
  'consent': {
    'status': consentStatus == 'none' ? null : consentStatus,
    'consent_version': '2026-11-v2',
    'updated_at': consentStatus == 'none' ? null : '2026-11-09T03:00:00Z',
  },
};

// ---------------------------------------------------------------------------
// Dựng cả chồng (ApiClient + repository + cubit phiên) trên adapter giả
// ---------------------------------------------------------------------------

class Harness {
  Harness(this.adapter, {AuthTokens? tokens}) {
    store.tokens = tokens;
    api = ApiClient(
      const Env(
        name: 'test',
        apiBaseUrl: 'http://test/api/v1',
        googleMapsApiKey: '',
      ),
      store,
    )..useAdapter(adapter);
    cleaner = RecordingCleaner(store);
    auth = AuthRepository(api, store, cleaner);
    me = MeRepository(api);
    families = FamilyRepository(api);
    session = AppSessionCubit(me, auth, store, cleaner, api);
  }

  final FakeAdapter adapter;
  final MemoryTokenStore store = MemoryTokenStore();
  late final ApiClient api;
  late final RecordingCleaner cleaner;
  late final AuthRepository auth;
  late final MeRepository me;
  late final FamilyRepository families;
  late final AppSessionCubit session;

  Future<void> dispose() => session.close();
}
