import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/constants/domain_enums.dart';
import 'package:happy_share/core/network/api_exception.dart';
import 'package:happy_share/core/session/session_state.dart';
import 'package:happy_share/core/utils/submit_state.dart';
import 'package:happy_share/features/family/data/model/family_with_member.dart';
import 'package:happy_share/features/family/presentation/cubit/family_setup_cubit.dart';
import 'package:happy_share/features/family/presentation/cubit/members_cubit.dart';

import '../helpers/fakes.dart';

Reply _familyOk() =>
    ok({'family': familyJson(), 'member': memberJson()}, status: 201);

void main() {
  group('FamilySetupCubit', () {
    late Reply Function(String path) server;
    late Harness h;
    late FamilySetupCubit cubit;

    setUp(() {
      server = (path) => path == '/me' ? ok(meJson()) : _familyOk();
      h = Harness(
        FakeAdapter((o) => server(o.path)),
        tokens: tokensOf('A1', 'R1'),
      );
      cubit = FamilySetupCubit(h.families, h.session);
    });
    tearDown(() async {
      await cubit.close();
      await h.dispose();
    });

    test('join: mã sai định dạng → báo lỗi ngay, KHÔNG gọi API', () async {
      for (final bad in ['', 'abc', 'K7M2Q9X0', 'K7M2Q9XU', 'K7M2Q9XAA']) {
        await cubit.join(bad);
        expect(cubit.state.fieldErrors, {
          'code': ['invalid'],
        }, reason: bad);
      }
      expect(h.adapter.calls, isEmpty);
    });

    test('join: mã dán dạng "k7m2-q9xa" được chuẩn hóa trước khi gửi', () async {
      await cubit.join(' k7m2-q9xa ');
      // Vào nhóm là đồng ý chia sẻ (D16): luôn gửi kèm phiên bản nội dung hiện hành.
      expect(h.adapter.to('/families/join').single.data, {
        'code': 'K7M2Q9XA',
        'sharing_consent_version': '2026-11-g1',
      });
      expect(cubit.state.status, SubmitStatus.success);
      expect(cubit.state.result!.family.name, 'Nhà Nguyễn');
    });

    test(
      'thành công KHÔNG làm mới phiên ngay (để UI hiện màn xác nhận); finish() mới làm mới',
      () async {
        await cubit.join('K7M2Q9XA');
        expect(h.adapter.count('/me'), 0);
        expect(h.session.state.status, SessionStatus.initializing);

        await cubit.finish();
        expect(h.adapter.count('/me'), 1);
        expect(h.session.state.status, SessionStatus.consentIntro);
      },
    );

    test(
      'finish() chuyển sang nhóm vừa tạo/tham gia khi đã ở nhóm khác',
      () async {
        server = (path) {
          if (path == '/me') {
            final json = meJson(consentStatus: 'granted');
            (json['families'] as List).add({
              'family': {...familyJson(), 'id': 'f2', 'name': 'Hội bạn thân'},
              'member': {...memberJson(), 'member_id': 'm2'},
            });
            return ok(json);
          }
          return ok({
            'family': {...familyJson(), 'id': 'f2', 'name': 'Hội bạn thân'},
            'member': {...memberJson(), 'member_id': 'm2'},
          }, status: 201);
        };
        await h.session.start();
        expect(h.session.state.activeFamily!.family.id, 'f1');

        await cubit.join('K7M2Q9XA');
        await cubit.finish();
        expect(h.session.state.activeFamily!.family.id, 'f2');
      },
    );

    test('create: gửi tên đã trim + múi giờ; thành công giữ kết quả', () async {
      await cubit.create(name: '  Nhà Nguyễn ', timezone: 'Asia/Ho_Chi_Minh');
      expect(h.adapter.to('/families').single.data, {
        'name': 'Nhà Nguyễn',
        'timezone': 'Asia/Ho_Chi_Minh',
        'sharing_consent_version': '2026-11-g1',
      });
      expect(cubit.state.result, isA<FamilyWithMember>());
      expect(cubit.state.result!.member.role, MemberRole.owner);
    });

    test('create: tên rỗng → lỗi cục bộ, không gọi API', () async {
      await cubit.create(name: ' ', timezone: 'Asia/Ho_Chi_Minh');
      expect(h.adapter.calls, isEmpty);
      expect(cubit.state.fieldErrors, {
        'name': ['required'],
      });
    });

    test('mã lỗi của server giữ nguyên để UI hiện đúng thông báo', () async {
      const cases = {
        'INVITE_INVALID': ApiErrorCode.inviteInvalid,
        'INVITE_EXPIRED': ApiErrorCode.inviteExpired,
        'PLAN_LIMIT_MEMBERS': ApiErrorCode.planLimitMembers,
        'GROUP_LIMIT': ApiErrorCode.groupLimit,
        'RATE_LIMITED': ApiErrorCode.rateLimited,
      };
      for (final e in cases.entries) {
        server = (_) => apiError(409, e.key);
        await cubit.join('K7M2Q9XA');
        expect(cubit.state.status, SubmitStatus.failure, reason: e.key);
        expect(cubit.state.error, e.value, reason: e.key);
      }
    });

    test('ALREADY_IN_FAMILY (đã ở nhóm này): đồng bộ lại phiên', () async {
      server = (path) => path == '/me'
          ? ok(meJson(consentStatus: 'granted'))
          : apiError(409, 'ALREADY_IN_FAMILY');
      await cubit.join('K7M2Q9XA');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.state.error, ApiErrorCode.alreadyInFamily);
      expect(h.session.state.status, SessionStatus.ready);
    });

    test('bấm đúp chỉ gửi một request', () async {
      await Future.wait([cubit.join('K7M2Q9XA'), cubit.join('K7M2Q9XA')]);
      expect(h.adapter.count('/families/join'), 1);
    });
  });

  group('MembersCubit', () {
    late Reply Function(String method, String path) server;
    late Harness h;
    late MembersCubit cubit;

    final twoMembers = {
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
    };

    setUp(() async {
      server = (method, path) {
        if (path == '/me') return ok(meJson(consentStatus: 'granted'));
        if (path == '/families/f1/members' && method == 'GET') {
          return ok(twoMembers);
        }
        return ok({});
      };
      h = Harness(
        FakeAdapter((o) => server(o.method, o.path)),
        tokens: tokensOf('A1', 'R1'),
      );
      await h.session.start(); // có gia đình f1
      cubit = MembersCubit(h.families, h.session);
    });
    tearDown(() async {
      await cubit.close();
      await h.dispose();
    });

    test('load: danh sách + xác định mình và quyền chủ nhóm', () async {
      expect(cubit.state.status, MembersStatus.loading);
      await cubit.load();
      expect(cubit.state.status, MembersStatus.loaded);
      expect(cubit.state.members.map((m) => m.label), ['Mẹ', 'Bố']);
      expect(cubit.state.me!.memberId, 'm1');
      expect(cubit.state.iAmOwner, isTrue);
    });

    test(
      'chưa thuộc nhóm nào → failure NOT_FAMILY_MEMBER, không gọi API',
      () async {
        final lone = Harness(
          FakeAdapter((_) => ok(meJson(withFamily: false))),
          tokens: tokensOf('A1', 'R1'),
        );
        await lone.session.start();
        final c = MembersCubit(lone.families, lone.session);
        await c.load();
        expect(c.state.status, MembersStatus.failure);
        expect(c.state.error, ApiErrorCode.notFamilyMember);
        expect(lone.adapter.count('/families/f1/members'), 0);
        await c.close();
        await lone.dispose();
      },
    );

    test(
      'lỗi tải lần đầu → failure; tải lại thành công; lỗi khi đã có dữ liệu thì GIỮ danh sách',
      () async {
        var up = false;
        server = (m, p) => p == '/me'
            ? ok(meJson(consentStatus: 'granted'))
            : up
            ? ok(twoMembers)
            : apiError(500, 'INTERNAL_ERROR');
        await cubit.load();
        expect(cubit.state.status, MembersStatus.failure);

        up = true;
        await cubit.load();
        expect(cubit.state.status, MembersStatus.loaded);

        up = false;
        await cubit.load();
        expect(
          cubit.state.status,
          MembersStatus.loaded,
        ); // vẫn hiển thị danh sách cũ
        expect(cubit.state.members, hasLength(2));
        expect(cubit.state.error, ApiErrorCode.internalError);
      },
    );

    test(
      'NOT_FAMILY_MEMBER khi tải (bị xóa khỏi nhóm) → làm mới phiên; ghi nhận cá nhân không đổi',
      () async {
        server = (m, p) => p == '/me'
            ? ok(meJson(withFamily: false, consentStatus: 'granted'))
            : apiError(403, 'NOT_FAMILY_MEMBER');
        await cubit.load();
        expect(h.session.state.status, SessionStatus.ready);
        expect(h.session.state.activeFamily, isNull);
        expect(
          h.cleaner.clearLocationCalls,
          0,
        ); // mất nhóm KHÔNG dừng thu thập (D15)
      },
    );

    test(
      'dùng nhóm đang xem: chọn nhóm khác thì tải thành viên của nhóm đó',
      () async {
        server = (m, p) {
          if (p == '/me') {
            final json = meJson(consentStatus: 'granted');
            (json['families'] as List).add({
              'family': {...familyJson(), 'id': 'f2', 'name': 'Hội bạn thân'},
              'member': {...memberJson(), 'member_id': 'm2'},
            });
            return ok(json);
          }
          if (p == '/families/f2/members') {
            return ok({
              'items': [memberJson(id: 'm2', displayName: 'Lan')],
            });
          }
          return ok(twoMembers);
        };
        await h.session.refreshMe();
        h.session.selectFamily('f2');
        await cubit.load();
        expect(cubit.state.members.map((m) => m.label), ['Lan']);
        expect(h.adapter.count('/families/f2/members'), 1);
      },
    );

    test('mời: tạo mã, giữ trong bộ nhớ đến khi đóng', () async {
      server = (m, p) => p == '/families/f1/invitations'
          ? ok({
              'code': 'K7M2Q9XA',
              'expires_at': '2026-11-11T02:00:00Z',
              'qr_payload': 'happyshare://join?code=K7M2Q9XA',
            }, status: 201)
          : ok({});
      await cubit.createInvitation();
      expect(cubit.state.invitation!.code, 'K7M2Q9XA');
      expect(cubit.state.inviting, isFalse);

      cubit.dismissInvitation();
      expect(cubit.state.invitation, isNull);
    });

    test(
      'mời bởi người không phải chủ nhóm → FORBIDDEN, không có mã',
      () async {
        server = (m, p) => apiError(403, 'FORBIDDEN');
        await cubit.createInvitation();
        expect(cubit.state.invitation, isNull);
        expect(cubit.state.error, ApiErrorCode.forbidden);
      },
    );

    test(
      'xóa thành viên: bỏ khỏi danh sách; FORBIDDEN thì giữ nguyên',
      () async {
        await cubit.load();
        await cubit.removeMember('m2');
        expect(cubit.state.members.map((m) => m.memberId), ['m1']);
        expect(h.adapter.calls.last.method, 'DELETE');
        expect(h.adapter.calls.last.path, '/families/f1/members/m2');

        await cubit.load();
        server = (m, p) => p == '/families/f1/members'
            ? ok(twoMembers)
            : apiError(403, 'FORBIDDEN');
        await cubit.load();
        await cubit.removeMember('m2');
        expect(cubit.state.members, hasLength(2));
        expect(cubit.state.error, ApiErrorCode.forbidden);
      },
    );

    test('đổi biệt danh: cập nhật đúng dòng', () async {
      await cubit.load();
      server = (m, p) => p == '/families/f1/members/m1'
          ? ok({'member': memberJson(nickname: 'Má')})
          : ok(twoMembers);
      await cubit.updateNickname('m1', 'Má');
      expect(cubit.state.members.first.label, 'Má');
      expect(cubit.state.members.last.label, 'Bố');
    });

    test(
      'rời nhóm: làm mới phiên, KHÔNG dừng thu thập hay xóa hàng đợi (ghi nhận là của tài khoản)',
      () async {
        var left = false;
        server = (m, p) {
          if (p == '/families/f1/leave') {
            left = true;
            return ok({});
          }
          if (p == '/me') {
            return ok(meJson(consentStatus: 'granted', withFamily: !left));
          }
          return ok(twoMembers);
        };
        await cubit.leave();
        expect(h.cleaner.clearLocationCalls, 0);
        expect(h.session.state.status, SessionStatus.ready);
        expect(h.session.state.activeFamily, isNull);
        expect(h.store.tokens, isNotNull); // vẫn đăng nhập
      },
    );

    test(
      'chủ nhóm còn người khác bấm rời → OWNER_CANNOT_LEAVE, không đổi gì',
      () async {
        server = (m, p) => p == '/families/f1/leave'
            ? apiError(409, 'OWNER_CANNOT_LEAVE')
            : ok(meJson(consentStatus: 'granted'));
        await cubit.leave();
        expect(cubit.state.error, ApiErrorCode.ownerCannotLeave);
        expect(h.cleaner.clearLocationCalls, 0);
        expect(h.session.state.status, SessionStatus.ready);
      },
    );
  });
}
