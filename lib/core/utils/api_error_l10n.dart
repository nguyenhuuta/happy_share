import '../l10n/gen/app_localizations.dart';
import '../network/api_exception.dart';

/// Map mã lỗi → chuỗi l10n. UI dùng hàm này, không bao giờ hiển thị `message` của server.
extension ApiErrorCodeL10n on ApiErrorCode {
  String localized(AppLocalizations l10n) => switch (this) {
    ApiErrorCode.validationError ||
    ApiErrorCode.batchTooLarge => l10n.errorValidation,
    ApiErrorCode.unauthenticated => l10n.errorUnauthenticated,
    ApiErrorCode.tokenExpired ||
    ApiErrorCode.refreshTokenInvalid => l10n.errorSessionExpired,
    ApiErrorCode.invalidCredentials => l10n.errorInvalidCredentials,
    ApiErrorCode.forbidden ||
    ApiErrorCode.deviceNotRegistered => l10n.errorForbidden,
    ApiErrorCode.notFamilyMember => l10n.errorNotFamilyMember,
    ApiErrorCode.consentRequired => l10n.errorConsentRequired,
    ApiErrorCode.consentRevoked => l10n.errorConsentRevoked,
    ApiErrorCode.notFound => l10n.errorNotFound,
    ApiErrorCode.identifierTaken => l10n.errorIdentifierTaken,
    ApiErrorCode.alreadyInFamily => l10n.errorAlreadyInFamily,
    ApiErrorCode.inviteInvalid => l10n.errorInviteInvalid,
    ApiErrorCode.inviteExpired => l10n.errorInviteExpired,
    ApiErrorCode.ownerCannotLeave => l10n.errorOwnerCannotLeave,
    ApiErrorCode.groupLimit => l10n.errorGroupLimit,
    ApiErrorCode.planLimitMembers => l10n.errorPlanLimitMembers,
    ApiErrorCode.planLimitPlaces => l10n.errorPlanLimitPlaces,
    ApiErrorCode.historyOutOfPlan => l10n.errorHistoryOutOfPlan,
    ApiErrorCode.rateLimited => l10n.errorRateLimited,
    ApiErrorCode.networkError => l10n.errorNetwork,
    ApiErrorCode.internalError || ApiErrorCode.unknown => l10n.errorUnknown,
  };
}
