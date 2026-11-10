import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Happy Share'**
  String get appName;

  /// No description provided for @tabFamily.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm'**
  String get tabFamily;

  /// No description provided for @tabJourney.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình'**
  String get tabJourney;

  /// No description provided for @tabPlaces.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm'**
  String get tabPlaces;

  /// No description provided for @tabMembers.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên'**
  String get tabMembers;

  /// No description provided for @tabSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get tabSettings;

  /// No description provided for @emptyComingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp có'**
  String get emptyComingSoon;

  /// No description provided for @errorNetwork.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối mạng. Vui lòng thử lại.'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Đã có lỗi xảy ra. Vui lòng thử lại.'**
  String get errorUnknown;

  /// No description provided for @errorUnauthenticated.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.'**
  String get errorUnauthenticated;

  /// No description provided for @errorSessionExpired.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'**
  String get errorSessionExpired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản hoặc mật khẩu không đúng.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorForbidden.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không có quyền thực hiện thao tác này.'**
  String get errorForbidden;

  /// No description provided for @errorNotFamilyMember.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không thuộc nhóm này.'**
  String get errorNotFamilyMember;

  /// No description provided for @errorConsentRequired.
  ///
  /// In vi, this message translates to:
  /// **'Bạn cần bật ghi lại hành trình trước.'**
  String get errorConsentRequired;

  /// No description provided for @errorConsentRevoked.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã tắt ghi lại hành trình.'**
  String get errorConsentRevoked;

  /// No description provided for @errorNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy dữ liệu.'**
  String get errorNotFound;

  /// No description provided for @errorIdentifierTaken.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản này đã được sử dụng.'**
  String get errorIdentifierTaken;

  /// No description provided for @errorAlreadyInFamily.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã ở trong nhóm này.'**
  String get errorAlreadyInFamily;

  /// No description provided for @errorInviteInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Mã mời không đúng hoặc đã được dùng.'**
  String get errorInviteInvalid;

  /// No description provided for @errorInviteExpired.
  ///
  /// In vi, this message translates to:
  /// **'Mã mời đã hết hạn.'**
  String get errorInviteExpired;

  /// No description provided for @errorOwnerCannotLeave.
  ///
  /// In vi, this message translates to:
  /// **'Chủ nhóm không thể rời khi còn thành viên khác.'**
  String get errorOwnerCannotLeave;

  /// No description provided for @errorGroupLimit.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã ở đủ số nhóm tối đa. Hãy rời một nhóm trước khi tham gia nhóm khác.'**
  String get errorGroupLimit;

  /// No description provided for @errorPlanLimitMembers.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm đã đạt số thành viên tối đa của gói.'**
  String get errorPlanLimitMembers;

  /// No description provided for @errorPlanLimitPlaces.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm đã đạt số địa điểm tối đa của gói.'**
  String get errorPlanLimitPlaces;

  /// No description provided for @errorHistoryOutOfPlan.
  ///
  /// In vi, this message translates to:
  /// **'Ngày này nằm ngoài lịch sử của gói hiện tại.'**
  String get errorHistoryOutOfPlan;

  /// No description provided for @errorRateLimited.
  ///
  /// In vi, this message translates to:
  /// **'Bạn thao tác quá nhanh. Vui lòng thử lại sau.'**
  String get errorRateLimited;

  /// No description provided for @errorValidation.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu chưa hợp lệ. Vui lòng kiểm tra lại.'**
  String get errorValidation;

  /// No description provided for @pageLogin.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get pageLogin;

  /// No description provided for @pageRegister.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get pageRegister;

  /// No description provided for @pageFamilySetup.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu cùng nhóm'**
  String get pageFamilySetup;

  /// No description provided for @pageCreateFamily.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhóm'**
  String get pageCreateFamily;

  /// No description provided for @pageJoinFamily.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia nhóm'**
  String get pageJoinFamily;

  /// No description provided for @pageConsentIntro.
  ///
  /// In vi, this message translates to:
  /// **'Ghi lại hành trình'**
  String get pageConsentIntro;

  /// No description provided for @sharingStateSharing.
  ///
  /// In vi, this message translates to:
  /// **'Đang chia sẻ'**
  String get sharingStateSharing;

  /// No description provided for @sharingStateLimited.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ hạn chế'**
  String get sharingStateLimited;

  /// No description provided for @sharingStatePaused.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạm dừng'**
  String get sharingStatePaused;

  /// No description provided for @sharingStateNotShared.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chia sẻ'**
  String get sharingStateNotShared;

  /// No description provided for @freshnessStale.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu cũ'**
  String get freshnessStale;

  /// No description provided for @freshnessNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu'**
  String get freshnessNone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
