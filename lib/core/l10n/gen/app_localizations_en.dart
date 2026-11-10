// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Happy Share';

  @override
  String get tabFamily => 'Group';

  @override
  String get tabJourney => 'Journey';

  @override
  String get tabPlaces => 'Places';

  @override
  String get tabMembers => 'Members';

  @override
  String get tabSettings => 'Settings';

  @override
  String get emptyComingSoon => 'Coming soon';

  @override
  String get errorNetwork => 'No network connection. Please try again.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorUnauthenticated => 'Invalid session. Please sign in again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorInvalidCredentials => 'Incorrect account or password.';

  @override
  String get errorForbidden => 'You are not allowed to do this.';

  @override
  String get errorNotFamilyMember => 'You are not in this group.';

  @override
  String get errorConsentRequired => 'Turn on journey recording first.';

  @override
  String get errorConsentRevoked => 'You turned journey recording off.';

  @override
  String get errorNotFound => 'Data not found.';

  @override
  String get errorIdentifierTaken => 'This account is already in use.';

  @override
  String get errorAlreadyInFamily => 'You are already in this group.';

  @override
  String get errorInviteInvalid => 'The invite code is wrong or already used.';

  @override
  String get errorInviteExpired => 'The invite code has expired.';

  @override
  String get errorOwnerCannotLeave =>
      'The owner cannot leave while other members remain.';

  @override
  String get errorGroupLimit =>
      'You are in the maximum number of groups. Leave a group before joining another.';

  @override
  String get errorPlanLimitMembers =>
      'The group reached the member limit of its plan.';

  @override
  String get errorPlanLimitPlaces =>
      'The group reached the place limit of its plan.';

  @override
  String get errorHistoryOutOfPlan =>
      'This date is outside your plan\'s history window.';

  @override
  String get errorRateLimited =>
      'You\'re going too fast. Please try again later.';

  @override
  String get errorValidation =>
      'Some data is invalid. Please check and try again.';

  @override
  String get pageLogin => 'Sign in';

  @override
  String get pageRegister => 'Create account';

  @override
  String get pageFamilySetup => 'Get started with a group';

  @override
  String get pageCreateFamily => 'Create a group';

  @override
  String get pageJoinFamily => 'Join a group';

  @override
  String get pageConsentIntro => 'Record my journey';

  @override
  String get sharingStateSharing => 'Sharing';

  @override
  String get sharingStateLimited => 'Limited sharing';

  @override
  String get sharingStatePaused => 'Paused';

  @override
  String get sharingStateNotShared => 'Not sharing';

  @override
  String get freshnessStale => 'Outdated data';

  @override
  String get freshnessNone => 'No data yet';
}
