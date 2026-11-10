import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/constants/domain_enums.dart';
import 'package:happy_share/features/auth/data/model/me_data.dart';
import 'package:happy_share/features/auth/data/model/user.dart';
import 'package:happy_share/features/consent/data/model/consent_info.dart';
import 'package:happy_share/features/family/data/model/family.dart';
import 'package:happy_share/features/family/data/model/family_with_member.dart';
import 'package:happy_share/features/family/data/model/invitation.dart';
import 'package:happy_share/features/family/data/model/member.dart';

import '../helpers/fakes.dart';

void main() {
  group('User', () {
    test(
      'parse đúng hợp đồng A4 (snake_case, identifier + identifier_type)',
      () {
        final u = User.fromJson(
          userJson(identifier: '0912345678', type: 'phone'),
        );
        expect(u.id, 'u1');
        expect(u.identifier, '0912345678');
        expect(u.identifierType, IdentifierType.phone);
        expect(u.displayName, 'Mẹ');
        expect(u.avatarUrl, isNull);
        expect(u.createdAt, DateTime.utc(2026, 11, 9, 2));
        expect(u.createdAt.isUtc, isTrue);
      },
    );

    test('identifier_type lạ → unknown, không crash', () {
      expect(
        User.fromJson(userJson(type: 'passkey')).identifierType,
        IdentifierType.unknown,
      );
    });

    test('toJson dùng snake_case', () {
      final json = User.fromJson(userJson()).toJson();
      expect(
        json.keys,
        containsAll([
          'identifier',
          'identifier_type',
          'display_name',
          'created_at',
        ]),
      );
      expect(json.containsKey('identifierType'), isFalse);
    });
  });

  group('Family / Member', () {
    test('Family: plan lạ → unknown', () {
      final f = Family.fromJson(familyJson(plan: 'enterprise'));
      expect(f.plan, SubscriptionPlan.unknown);
      expect(Family.fromJson(familyJson()).plan, SubscriptionPlan.beta);
      expect(f.memberCount, 1);
      expect(f.timezone, 'Asia/Ho_Chi_Minh');
    });

    test('Member: enum lạ → unknown; label ưu tiên biệt danh', () {
      final m = Member.fromJson(
        memberJson(role: 'guest', sharing: 'teleporting', status: 'banned'),
      );
      expect(m.role, MemberRole.unknown);
      expect(m.sharingState, SharingState.unknown);
      expect(m.status, MemberStatus.unknown);

      expect(Member.fromJson(memberJson(displayName: 'Mẹ')).label, 'Mẹ');
      expect(
        Member.fromJson(memberJson(displayName: 'Mẹ', nickname: 'Má')).label,
        'Má',
      );
      expect(
        Member.fromJson(memberJson(displayName: 'Mẹ', nickname: '  ')).label,
        'Mẹ',
      );
    });

    test('Member: đủ bốn sharing_state và isOwner', () {
      const states = {
        'sharing': SharingState.sharing,
        'limited': SharingState.limited,
        'paused': SharingState.paused,
        'not_shared': SharingState.notShared,
      };
      for (final e in states.entries) {
        expect(
          Member.fromJson(memberJson(sharing: e.key)).sharingState,
          e.value,
        );
      }
      expect(Member.fromJson(memberJson(role: 'owner')).isOwner, isTrue);
      expect(Member.fromJson(memberJson(role: 'member')).isOwner, isFalse);
    });
  });

  group('ConsentInfo / MeData', () {
    test('consent chưa đồng ý: status null (không phải unknown)', () {
      final c = ConsentInfo.fromJson({
        'status': null,
        'consent_version': '2026-11-v1',
        'updated_at': null,
      });
      expect(c.status, isNull);
      expect(c.updatedAt, isNull);
      expect(c.hasAgreed, isFalse);
    });

    test('hasAgreed: granted/paused có; revoked/unknown/null không', () {
      bool agreed(String? s) =>
          ConsentInfo.fromJson({'status': s, 'consent_version': 'v'}).hasAgreed;
      expect(agreed('granted'), isTrue);
      expect(agreed('paused'), isTrue);
      expect(agreed('revoked'), isFalse);
      expect(agreed('whatever'), isFalse);
      expect(agreed(null), isFalse);
    });

    test(
      'MeData: chưa có nhóm → families rỗng; consent vẫn là object (D15)',
      () {
        final me = MeData.fromJson(meJson(withFamily: false));
        expect(me.user.displayName, 'Mẹ');
        expect(me.user.timezone, 'Asia/Ho_Chi_Minh');
        expect(me.families, isEmpty);
        expect(me.consent.status, isNull);
        expect(me.consent.consentVersion, '2026-11-v2');
      },
    );

    test(
      'MeData: có nhóm, chưa bật ghi nhận → consent là object với status null',
      () {
        final me = MeData.fromJson(meJson());
        expect(me.families, hasLength(1));
        expect(me.families.single.family.name, 'Nhà Nguyễn');
        expect(me.families.single.member.isMe, isTrue);
        expect(me.consent.status, isNull);
      },
    );

    test('User.timezone mặc định Asia/Ho_Chi_Minh khi server cũ không trả', () {
      final json = userJson()..remove('timezone');
      expect(User.fromJson(json).timezone, 'Asia/Ho_Chi_Minh');
    });

    test('MeData: granted', () {
      final me = MeData.fromJson(meJson(consentStatus: 'granted'));
      expect(me.consent.status, ConsentStatus.granted);
      expect(me.consent.updatedAt, DateTime.utc(2026, 11, 9, 3));
    });

    test('bỏ qua field lạ do server thêm sau (tương thích tiến)', () {
      final json = meJson()..['future_field'] = {'x': 1};
      (json['user'] as Map<String, dynamic>)['badge'] = 'vip';
      expect(MeData.fromJson(json).user.id, 'u1');
    });
  });

  group('FamilyWithMember / Invitation', () {
    test('FamilyWithMember', () {
      final r = FamilyWithMember.fromJson({
        'family': familyJson(),
        'member': memberJson(),
      });
      expect(r.family.id, 'f1');
      expect(r.member.role, MemberRole.owner);
    });

    test('Invitation', () {
      final i = Invitation.fromJson({
        'code': 'K7M2Q9XA',
        'expires_at': '2026-11-11T02:00:00Z',
        'qr_payload': 'happyshare://join?code=K7M2Q9XA',
      });
      expect(i.code, 'K7M2Q9XA');
      expect(i.expiresAt, DateTime.utc(2026, 11, 11, 2));
      expect(i.qrPayload, 'happyshare://join?code=K7M2Q9XA');
    });
  });
}
