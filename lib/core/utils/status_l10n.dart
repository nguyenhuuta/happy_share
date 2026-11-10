import '../constants/domain_enums.dart';
import '../l10n/gen/app_localizations.dart';

/// Nhãn hiển thị của trạng thái chia sẻ. Luôn đi kèm biểu tượng (không chỉ màu) — xem
/// `AppStatusColors.forSharing`. Giá trị lạ (`unknown`) hiển thị như "Chưa chia sẻ".
extension SharingStateL10n on SharingState {
  String label(AppLocalizations l10n) => switch (this) {
    SharingState.sharing => l10n.sharingStateSharing,
    SharingState.limited => l10n.sharingStateLimited,
    SharingState.paused => l10n.sharingStatePaused,
    SharingState.notShared ||
    SharingState.unknown => l10n.sharingStateNotShared,
  };
}
