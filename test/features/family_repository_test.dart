import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/constants/domain_enums.dart';
import 'package:happy_share/core/network/api_exception.dart';

import '../helpers/fakes.dart';

void main() {
  Harness build(
    Reply Function(String path) reply, {
    Map<String, dynamic>? last,
  }) =>
      Harness(FakeAdapter((o) => reply(o.path)), tokens: tokensOf('A1', 'R1'));

  test('createFamily: trim tên, chỉ gửi timezone khi có', () async {
    final h = build(
      (_) => ok({'family': familyJson(), 'member': memberJson()}, status: 201),
    );
    final r = await h.families.createFamily(
      name: '  Nhà Nguyễn ',
      timezone: 'Asia/Ho_Chi_Minh',
    );
    expect(h.adapter.calls.single.path, '/families');
    expect(h.adapter.calls.single.data, {
      'name': 'Nhà Nguyễn',
      'timezone': 'Asia/Ho_Chi_Minh',
      'sharing_consent_version':
          '2026-11-g1', // tạo nhóm là đồng ý chia sẻ (D16)
    });
    expect(r.family.name, 'Nhà Nguyễn');
    expect(r.member.role, MemberRole.owner);

    final h2 = build(
      (_) => ok({'family': familyJson(), 'member': memberJson()}),
    );
    await h2.families.createFamily(name: 'A');
    expect(h2.adapter.calls.single.data, {
      'name': 'A',
      'sharing_consent_version': '2026-11-g1',
    }); // không có khóa timezone
  });

  test(
    'joinFamily gửi {code, sharing_consent_version} và trả family + member',
    () async {
      final h = build(
        (_) => ok({
          'family': familyJson(memberCount: 2),
          'member': memberJson(role: 'member', isMe: true),
        }),
      );
      final r = await h.families.joinFamily('K7M2Q9XA');
      expect(h.adapter.calls.single.path, '/families/join');
      expect(h.adapter.calls.single.data, {
        'code': 'K7M2Q9XA',
        'sharing_consent_version': '2026-11-g1',
      });
      expect(r.family.memberCount, 2);
      expect(r.member.isOwner, isFalse);
    },
  );

  test('lỗi tham gia giữ nguyên mã lỗi của server', () async {
    const codes = {
      'INVITE_INVALID': ApiErrorCode.inviteInvalid,
      'INVITE_EXPIRED': ApiErrorCode.inviteExpired,
      'ALREADY_IN_FAMILY': ApiErrorCode.alreadyInFamily,
      'PLAN_LIMIT_MEMBERS': ApiErrorCode.planLimitMembers,
      'RATE_LIMITED': ApiErrorCode.rateLimited,
    };
    for (final e in codes.entries) {
      final h = build((_) => apiError(409, e.key));
      await expectLater(
        h.families.joinFamily('K7M2Q9XA'),
        throwsA(isA<ApiException>().having((x) => x.code, 'code', e.value)),
      );
    }
  });

  test('listMembers: GET đúng đường dẫn, parse danh sách', () async {
    final h = build(
      (_) => ok({
        'items': [
          memberJson(),
          memberJson(
            id: 'm2',
            userId: 'u2',
            displayName: 'Bố',
            role: 'member',
            isMe: false,
            sharing: 'limited',
          ),
        ],
      }),
    );
    final list = await h.families.listMembers('f1');
    expect(h.adapter.calls.single.path, '/families/f1/members');
    expect(h.adapter.calls.single.method, 'GET');
    expect(list.map((m) => m.label), ['Mẹ', 'Bố']);
    expect(list[1].sharingState, SharingState.limited);
  });

  test(
    'createInvitation: POST không body, parse mã + hạn + qr_payload',
    () async {
      final h = build(
        (_) => ok({
          'code': 'K7M2Q9XA',
          'expires_at': '2026-11-11T02:00:00Z',
          'qr_payload': 'happyshare://join?code=K7M2Q9XA',
        }, status: 201),
      );
      final inv = await h.families.createInvitation('f1');
      expect(h.adapter.calls.single.path, '/families/f1/invitations');
      expect(h.adapter.calls.single.method, 'POST');
      expect(inv.code, 'K7M2Q9XA');
      expect(inv.expiresAt.isUtc, isTrue);
    },
  );

  test(
    'updateNickname / removeMember / leave dùng đúng method + đường dẫn',
    () async {
      final h = build(
        (p) => p.endsWith('/m1') && p.contains('/members/')
            ? ok({'member': memberJson(nickname: 'Má')})
            : ok({}),
      );
      final m = await h.families.updateNickname(
        familyId: 'f1',
        memberId: 'm1',
        nickname: '  Má ',
      );
      expect(m.nickname, 'Má');
      expect(h.adapter.calls.last.method, 'PATCH');
      expect(h.adapter.calls.last.path, '/families/f1/members/m1');
      expect(h.adapter.calls.last.data, {'nickname': 'Má'});

      await h.families.removeMember(familyId: 'f1', memberId: 'm2');
      expect(h.adapter.calls.last.method, 'DELETE');
      expect(h.adapter.calls.last.path, '/families/f1/members/m2');

      await h.families.leave('f1');
      expect(h.adapter.calls.last.method, 'POST');
      expect(h.adapter.calls.last.path, '/families/f1/leave');
    },
  );

  test('phản hồi sai định dạng → lỗi chung, không crash', () async {
    final h = build((_) => ok({'items': 'không phải danh sách'}));
    await expectLater(
      h.families.listMembers('f1'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', ApiErrorCode.unknown),
      ),
    );
  });
}
