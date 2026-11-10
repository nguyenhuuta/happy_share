import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../network/auth_tokens.dart';

/// Lưu token trong Keychain/Keystore (không dùng SharedPreferences).
/// Isolate nền (workmanager) cũng đọc được cùng kho này.
abstract class TokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

@LazySingleton(as: TokenStore)
class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._storage);

  static const _key = 'auth_tokens_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<AuthTokens?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return AuthTokens.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _storage.delete(key: _key);
      return null;
    }
  }

  @override
  Future<void> write(AuthTokens tokens) =>
      _storage.write(key: _key, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
