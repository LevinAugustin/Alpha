// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Alpha';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageDescription =>
      'زبان مورد استفاده در Alpha را انتخاب کنید';

  @override
  String get languageSystemDefault => 'پیش‌فرض سیستم';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameGerman => 'Deutsch';

  @override
  String get languageNameItalian => 'Italiano';

  @override
  String get languageNamePortugueseBrazil => 'Português (Brasil)';

  @override
  String get languageNamePortuguesePortugal => 'Português (Portugal)';

  @override
  String get languageNameDutch => 'Nederlands';

  @override
  String get languageNamePolish => 'Polski';

  @override
  String get languageNameJapanese => '日本語';

  @override
  String get languageNameKorean => '한국어';

  @override
  String get languageNameSimplifiedChinese => '简体中文';

  @override
  String get languageNameTraditionalChinese => '繁體中文';

  @override
  String get languageNameTurkish => 'Türkçe';

  @override
  String get languageNameRussian => 'Русский';

  @override
  String get languageNameHindi => 'हिन्दी';

  @override
  String get languageNameArabic => 'العربية';

  @override
  String get languageNameIndonesian => 'Bahasa Indonesia';

  @override
  String get languageNameVietnamese => 'Tiếng Việt';

  @override
  String get languageNameBengali => 'বাংলা';

  @override
  String get languageNameUrdu => 'اردو';

  @override
  String get languageNamePersian => 'فارسی';

  @override
  String get languageNameThai => 'ไทย';

  @override
  String get languageNameMalay => 'Bahasa Melayu';

  @override
  String get languageNameUkrainian => 'Українська';

  @override
  String get navHistory => 'تاریخچه';

  @override
  String get navPlans => 'برنامه‌ها';

  @override
  String get navGraphs => 'نمودارها';

  @override
  String get navTimer => 'تایمر';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get errorLabel => 'خطا';

  @override
  String get tabContentError => 'محتوای برگه ساخته نشد.';

  @override
  String get cannotHideAllTabs => 'نمی‌توان همه‌چیز را پنهان کرد!';

  @override
  String removeTabQuestion(String tab) {
    return 'برگه $tab حذف شود؟';
  }

  @override
  String get restoreTabFromSettings =>
      'بعداً می‌توانید آن را از تنظیمات دوباره اضافه کنید.';

  @override
  String removedTab(String tab) {
    return '$tab حذف شد';
  }

  @override
  String newVersion(String version) {
    return 'نسخه جدید $version';
  }

  @override
  String get changes => 'تغییرات';

  @override
  String get searchHint => 'جست‌وجو...';

  @override
  String get deleteSelected => 'حذف موارد انتخاب‌شده';

  @override
  String get confirmDelete => 'تأیید حذف';

  @override
  String deleteRecordsConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'مطمئنید می‌خواهید $count رکورد را حذف کنید؟ این کار قابل بازگشت نیست.',
      one: 'مطمئنید می‌خواهید 1 رکورد را حذف کنید؟ این کار قابل بازگشت نیست.',
    );
    return '$_temp0';
  }

  @override
  String get actionCancel => 'لغو';

  @override
  String get actionDiscard => 'کنار گذاشتن';

  @override
  String get unsavedChanges => 'تغییرات ذخیره‌نشده';

  @override
  String get discardUnsavedChanges => 'تغییرات ذخیره‌نشده کنار گذاشته شوند؟';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionRemove => 'برداشتن';

  @override
  String get actionEdit => 'ویرایش';

  @override
  String get actionShare => 'اشتراک‌گذاری';

  @override
  String get clearSelection => 'پاک کردن انتخاب';

  @override
  String get clearSearch => 'پاک کردن جست‌وجو';

  @override
  String get showMenu => 'نمایش منو';

  @override
  String get selectAll => 'انتخاب همه';

  @override
  String get weightLabel => 'وزن';

  @override
  String get filter => 'فیلتر';

  @override
  String get filters => 'فیلترها';

  @override
  String get categoryLabel => 'دسته‌بندی';

  @override
  String get repsLabel => 'تکرارها';

  @override
  String get repsFilter => 'فیلتر تکرارها';

  @override
  String get weightFilter => 'فیلتر وزن';

  @override
  String get greaterThan => 'بیشتر از';

  @override
  String get lessThan => 'کمتر از';

  @override
  String get startDate => 'تاریخ شروع';

  @override
  String get endDate => 'تاریخ پایان';

  @override
  String get actionClear => 'پاک کردن';

  @override
  String get actionOk => 'تأیید';

  @override
  String get actionClose => 'بستن';

  @override
  String get sortBy => 'مرتب‌سازی بر اساس';

  @override
  String get dateNewest => 'تاریخ (جدیدترین)';

  @override
  String get dateOldest => 'تاریخ (قدیمی‌ترین)';

  @override
  String get nameLabel => 'نام';

  @override
  String get missingPermissions => 'مجوزهای لازم وجود ندارد';

  @override
  String get restTimersPermissionsMissing =>
      'تایمرهای استراحت روشن هستند، اما مجوزها وجود ندارند.';

  @override
  String get restTimersPermissionsOptional =>
      'اگر تایمرهای استراحت را غیرفعال کنید، دیگر به این مجوزها نیاز نیست.';

  @override
  String get restTimers => 'تایمرهای استراحت';

  @override
  String get disableBatteryOptimizations => 'غیرفعال کردن بهینه‌سازی باتری';

  @override
  String get batteryOptimizationWarning =>
      'اگر بهینه‌سازی باتری روشن بماند، ممکن است پیشرفت متوقف شود.';

  @override
  String get scheduleExactAlarm => 'زمان‌بندی هشدار دقیق';

  @override
  String get exactAlarmWarning =>
      'اگر این گزینه غیرفعال باشد، هشدارها نمی‌توانند دقیق باشند.';

  @override
  String get postNotifications => 'نمایش اعلان‌ها';

  @override
  String get notificationBarDescription =>
      'پیشرفت تایمر در نوار اعلان نمایش داده می‌شود';

  @override
  String get invalidPermissions => 'مجوزهای نامعتبر';

  @override
  String get insufficientTimerPermissionsConfirmation =>
      'تایمرهای استراحت بدون مجوزهای کافی فعال هستند. مطمئنید؟';

  @override
  String get actionConfirm => 'تأیید';

  @override
  String get appAccess => 'دسترسی برنامه';

  @override
  String get appAccessDescription => 'برای تایمرها و اعلان‌های فعال لازم است.';

  @override
  String get notifications => 'اعلان‌ها';

  @override
  String get timerProgressAndRestAlerts => 'پیشرفت تایمر و هشدارهای استراحت';

  @override
  String get enabledNotificationsDescription => 'اعلان‌هایی که فعال کرده‌اید';

  @override
  String get backgroundActivity => 'فعالیت پس‌زمینه';

  @override
  String get backgroundActivityDescription =>
      'تایمرها را در پس‌زمینه قابل اعتماد نگه دارید';

  @override
  String get exactAlarms => 'هشدارهای دقیق';

  @override
  String get exactAlarmsDescription =>
      'دقیقاً هنگام پایان تایمر استراحت هشدار بده';

  @override
  String get noAdditionalAndroidAccessNeeded =>
      'برای تنظیمات فعلی شما دسترسی اضافی Android لازم نیست.';

  @override
  String get actionDone => 'انجام شد';

  @override
  String get allowed => 'مجاز';

  @override
  String get actionAllow => 'اجازه دادن';

  @override
  String get backupLabel => 'پشتیبان‌گیری';

  @override
  String get databaseLabel => 'پایگاه داده';

  @override
  String get deleteRecords => 'حذف رکوردها';

  @override
  String get deleteAllGraphsConfirmation =>
      'مطمئنید می‌خواهید همه نمودارها را حذف کنید؟ این کار قابل بازگشت نیست.';

  @override
  String get deleteAllPlansConfirmation =>
      'مطمئنید می‌خواهید همه برنامه‌ها را حذف کنید؟ این کار قابل بازگشت نیست.';

  @override
  String get deleteDatabaseConfirmation =>
      'مطمئنید می‌خواهید پایگاه داده خود را حذف کنید؟ این کار قابل بازگشت نیست و همه داده‌های شما را از بین می‌برد.';

  @override
  String get importData => 'ورود داده‌ها';

  @override
  String get exportData => 'خروجی گرفتن از داده‌ها';

  @override
  String get actionReport => 'گزارش';

  @override
  String get graphDataImported => 'داده‌های نمودار با موفقیت وارد شدند!';

  @override
  String get plansImported => 'برنامه‌ها با موفقیت وارد شدند';

  @override
  String failedToImportDatabase(String error) {
    return 'ورود پایگاه داده ناموفق بود: $error';
  }

  @override
  String get backupArchiveMissingDatabase =>
      'بایگانی پشتیبان شامل پایگاه داده Alpha نیست.';

  @override
  String failedToImportGraphs(String error) {
    return 'ورود نمودارها ناموفق بود: $error';
  }

  @override
  String failedToImportPlans(String error) {
    return 'ورود برنامه‌ها ناموفق بود: $error';
  }

  @override
  String get selectedFileDoesNotExist => 'فایل انتخاب‌شده وجود ندارد';

  @override
  String get couldNotReadFileData => 'داده‌های فایل خوانده نشد';

  @override
  String get databaseImportWebUnsupported =>
      'ورود پایگاه داده در وب نیازمند انتقال دستی داده‌ها است. لطفاً داده‌های خود را به صورت فایل‌های CSV خروجی بگیرید و سپس آن‌ها را وارد کنید.';

  @override
  String get csvFileEmpty => 'فایل CSV خالی است';

  @override
  String get csvNeedsDataRow => 'فایل CSV باید حداقل یک ردیف داده داشته باشد';

  @override
  String csvRowInsufficientColumns(int row, int count) {
    return 'ردیف $row ستون‌های کافی ندارد: $count';
  }

  @override
  String invalidCsvValue(String field, int row, String value) {
    return 'مقدار $field در ردیف $row نامعتبر است: $value';
  }

  @override
  String invalidCsvDataType(String field, int row, String type) {
    return 'نوع داده $field در ردیف $row نامعتبر است: $type';
  }

  @override
  String expectedIntegerPlanId(String value) {
    return 'برای plan id عدد صحیح انتظار می‌رفت، اما \"$value\" دریافت شد';
  }

  @override
  String get unitLabel => 'واحد';

  @override
  String get kilogramsUnit => 'کیلوگرم (kg)';

  @override
  String get poundsUnit => 'پوند (lb)';

  @override
  String get stoneUnit => 'استون';

  @override
  String get stoneUnitShort => 'st';

  @override
  String get kilometersUnit => 'کیلومتر (km)';

  @override
  String get milesUnit => 'مایل (mi)';

  @override
  String get metersUnit => 'متر (m)';

  @override
  String get kilocaloriesUnit => 'کیلوکالری (kcal)';

  @override
  String get enterWeight => 'وزن را وارد کنید';

  @override
  String get requiredField => 'الزامی';

  @override
  String get invalidNumber => 'عدد نامعتبر';

  @override
  String get previousWeight => 'وزن قبلی';

  @override
  String get imageLabel => 'تصویر';

  @override
  String get longPressToDelete => 'برای حذف نگه دارید';

  @override
  String get imageError => 'خطای تصویر';

  @override
  String get actionSave => 'ذخیره';

  @override
  String get aboutTitle => 'درباره';

  @override
  String get donate => 'حمایت مالی';

  @override
  String get helpSupportProject => 'به پشتیبانی از این پروژه کمک کنید';

  @override
  String get whatsNewAbout => 'چه خبر؟';

  @override
  String get whatsNewTitle => 'چه چیز جدیدی هست؟';

  @override
  String get seeReleaseNotes => 'یادداشت‌های انتشار را ببینید';

  @override
  String get versionLabel => 'نسخه';

  @override
  String get authorLabel => 'نویسنده';

  @override
  String get privacyPolicy => 'سیاست حفظ حریم خصوصی';

  @override
  String get privacyPolicyDescription =>
      'Alpha چگونه با داده‌های شما برخورد می‌کند';

  @override
  String get licenseLabel => 'مجوز';

  @override
  String get sourceCode => 'کد منبع';

  @override
  String get sourceCodeDescription => 'در GitHub ببینید';

  @override
  String get leaveReview => 'ثبت نظر';

  @override
  String get leaveReviewDescription => 'به Alpha در Play Store امتیاز دهید';

  @override
  String get reportBug => 'گزارش باگ';

  @override
  String get reportBugDescription => 'در GitHub یک تیکت باز کنید';

  @override
  String get failedMigrations => 'مهاجرت‌های ناموفق';

  @override
  String get errorMessageLabel => 'پیام خطا:';

  @override
  String get createIssue => 'ایجاد ایشو';

  @override
  String get addExercise => 'افزودن تمرین';

  @override
  String get cardio => 'کاردیو';

  @override
  String get strength => 'قدرت';

  @override
  String get options => 'گزینه‌ها';

  @override
  String get periodDay => 'روز';

  @override
  String get periodWeek => 'هفته';

  @override
  String get periodMonth => 'ماه';

  @override
  String get periodYear => 'سال';

  @override
  String noDataFor(String name) {
    return 'هنوز داده‌ای برای $name وجود ندارد';
  }

  @override
  String get noDataYet => 'هنوز داده‌ای وجود ندارد';

  @override
  String get exerciseNotes => 'یادداشت‌های تمرین';

  @override
  String get notesForExercise => 'یادداشت‌های این تمرین';

  @override
  String get useTimeBasedXAxis => 'استفاده از محور X مبتنی بر زمان';

  @override
  String updateAllNamed(String name) {
    return 'به‌روزرسانی همه $name';
  }

  @override
  String get newName => 'نام جدید';

  @override
  String get restMinutes => 'دقایق استراحت';

  @override
  String get restSeconds => 'ثانیه‌های استراحت';

  @override
  String get globalProgress => 'پیشرفت کلی';

  @override
  String get curveLineGraphs => 'نمودارهای خطی منحنی';

  @override
  String get curveLineGraphsDescription =>
      'خطوط نمودار را به صورت منحنی‌های نرم رسم کنید';

  @override
  String noHistoryFor(String name) {
    return 'هنوز تاریخچه‌ای برای $name وجود ندارد';
  }

  @override
  String get cancelSelection => 'لغو انتخاب';

  @override
  String get editSelected => 'ویرایش موارد انتخاب‌شده';

  @override
  String get newExercise => 'تمرین جدید';

  @override
  String get noGraphsFound => 'نموداری پیدا نشد';

  @override
  String get searchGraphs => 'جست‌وجوی نمودارها...';

  @override
  String get actionAdd => 'افزودن';

  @override
  String get actionUpdate => 'به‌روزرسانی';

  @override
  String get hideGlobalProgress => 'پنهان کردن پیشرفت کلی';

  @override
  String get chartGroupedByCategory => 'نمودار گروه‌بندی‌شده بر اساس دسته‌بندی';

  @override
  String get noExercisesFound => 'تمرینی پیدا نشد';

  @override
  String get savePlan => 'ذخیره برنامه';

  @override
  String get titleOptional => 'عنوان (اختیاری)';

  @override
  String get searchExercises => 'جستجوی حرکت';

  @override
  String get warmupSets => 'ست‌های گرم‌کردن';

  @override
  String get workingSetsMax => 'ست‌های اصلی (حداکثر: 20)';

  @override
  String get actionUndo => 'واگرد';

  @override
  String get actionSwap => 'جابه‌جایی';

  @override
  String get daily => 'روزانه';

  @override
  String get weekly => 'هفتگی';

  @override
  String get monthly => 'ماهانه';

  @override
  String get yearly => 'سالانه';

  @override
  String get unexpectedError => 'مشکلی پیش آمد. دوباره تلاش کنید.';

  @override
  String get loadingExercises => 'در حال بارگیری تمرین‌ها...';

  @override
  String get noPlansYet => 'هنوز برنامه‌ای وجود ندارد';

  @override
  String get noMatchingPlans => 'برنامه مطابقی پیدا نشد';

  @override
  String get newPlan => 'برنامه جدید';

  @override
  String get searchPlans => 'جست‌وجوی برنامه‌ها...';

  @override
  String get noExercisesYet => 'هنوز تمرینی وجود ندارد';

  @override
  String get editPlan => 'ویرایش برنامه';

  @override
  String get saveSet => 'ذخیره ست';

  @override
  String get minutesLabel => 'دقیقه';

  @override
  String get minutesShort => 'دقیقه';

  @override
  String get secondsLabel => 'ثانیه';

  @override
  String get distanceLabel => 'مسافت';

  @override
  String get inclinePercent => 'شیب %';

  @override
  String weightWithUnit(String unit) {
    return 'وزن ($unit)';
  }

  @override
  String get useBodyWeight => 'استفاده از وزن بدن';

  @override
  String get noWeightEnteredYet => 'هنوز وزنی وارد نشده';

  @override
  String get notesLabel => 'یادداشت‌ها';

  @override
  String get swapWorkout => 'جابه‌جایی تمرین';

  @override
  String get addSet => 'افزودن ست';

  @override
  String get deleteSet => 'حذف ست';

  @override
  String get oneRepMaxEstimate => 'حداکثر یک تکرار (تخمین)';

  @override
  String get valueLabel => 'مقدار';

  @override
  String amountWithUnit(String unit) {
    return 'مقدار ($unit)';
  }

  @override
  String distanceWithUnit(String unit) {
    return 'مسافت ($unit)';
  }

  @override
  String get bodyWeightLabel => 'وزن بدن';

  @override
  String bodyWeightWithUnit(String unit) {
    return 'وزن بدن ($unit)';
  }

  @override
  String get categoryHelper =>
      'یک دسته‌بندی موجود را انتخاب کنید یا دسته‌بندی جدیدی بنویسید.';

  @override
  String get manageCategories => 'مدیریت دسته‌بندی‌ها';

  @override
  String get manageCategoriesDescription =>
      'دسته‌بندی‌ها را ایجاد، تغییرنام، ادغام یا حذف کنید';

  @override
  String get newCategory => 'دسته‌بندی جدید';

  @override
  String get renameCategory => 'تغییر نام دسته‌بندی';

  @override
  String get mergeCategory => 'ادغام در دسته‌بندی دیگر';

  @override
  String get noCategories => 'هنوز دسته‌بندی‌ای وجود ندارد';

  @override
  String get categoryNameRequired => 'نام دسته‌بندی را وارد کنید';

  @override
  String categoryUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'در $count ورودی استفاده شده',
      one: 'در 1 ورودی استفاده شده',
      zero: 'در هیچ ورودی استفاده نشده',
    );
    return '$_temp0';
  }

  @override
  String deleteCategoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'این دسته‌بندی حذف و از $count ورودی برداشته شود؟',
      one: 'این دسته‌بندی حذف و از 1 ورودی برداشته شود؟',
      zero: 'این دسته‌بندی حذف شود؟',
    );
    return '$_temp0';
  }

  @override
  String get createdDate => 'تاریخ ایجاد';

  @override
  String editSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ویرایش $count ست',
      one: 'ویرایش 1 ست',
    );
    return '$_temp0';
  }

  @override
  String get noEntriesYet => 'هنوز ورودی‌ای وجود ندارد';

  @override
  String get historyEmptyMessage =>
      'برای شروع تاریخچه یک ست را کامل کنید یا یکی را دستی اضافه کنید.';

  @override
  String deleteSetConfirmation(String name) {
    return 'مطمئنید می‌خواهید $name را حذف کنید؟';
  }

  @override
  String deleteEntriesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مطمئنید می‌خواهید $count ورودی را حذف کنید؟',
      one: 'مطمئنید می‌خواهید 1 ورودی را حذف کنید؟',
    );
    return '$_temp0';
  }

  @override
  String get searchHistory => 'جست‌وجوی تاریخچه...';

  @override
  String get themeSystem => 'سیستم';

  @override
  String get themeDark => 'تیره';

  @override
  String get themeLight => 'روشن';

  @override
  String get pureBlackAmoled => 'سیاه خالص (AMOLED)';

  @override
  String get showImages => 'نمایش تصاویر';

  @override
  String get peekGraph => 'پیش‌نمایش نمودار';

  @override
  String get inputStyleLine => 'خطی';

  @override
  String get inputStyleOutlined => 'حاشیه‌دار';

  @override
  String get inputStyleFilled => 'پُر';

  @override
  String get inputStyle => 'سبک ورودی';

  @override
  String get appearance => 'ظاهر';

  @override
  String get automaticBackupsEnabled => 'پشتیبان‌گیری خودکار فعال است';

  @override
  String get automaticBackup => 'پشتیبان‌گیری خودکار';

  @override
  String get appPermissions => 'مجوزهای برنامه';

  @override
  String get shareDatabase => 'اشتراک‌گذاری پایگاه داده';

  @override
  String get dataManagement => 'مدیریت داده‌ها';

  @override
  String get strengthUnit => 'واحد قدرت';

  @override
  String get lastEntry => 'آخرین ورودی';

  @override
  String get cardioUnit => 'واحد کاردیو';

  @override
  String longDateFormat(String format) {
    return 'قالب تاریخ بلند ($format)';
  }

  @override
  String get formats => 'قالب‌ها';

  @override
  String get setsPerExerciseMax => 'ست به ازای هر تمرین (حداکثر: 20)';

  @override
  String get countLabel => 'تعداد';

  @override
  String get ratioLabel => 'نسبت';

  @override
  String get reorder => 'مرتب‌سازی مجدد';

  @override
  String get none => 'هیچ‌کدام';

  @override
  String get monday => 'دوشنبه';

  @override
  String get examplePlanExercises => 'پرس سینه، اسکوات، ددلیفت';

  @override
  String get tabs => 'برگه‌ها';

  @override
  String get swipeBetweenTabs => 'بین برگه‌ها بکشید';

  @override
  String get vibrate => 'لرزش';

  @override
  String get enableSound => 'فعال کردن صدا';

  @override
  String get keepScreenOn => 'روشن نگه داشتن صفحه';

  @override
  String get keepRinging => 'ادامه زنگ';

  @override
  String get alarmSound => 'صدای هشدار';

  @override
  String get top => 'بالا';

  @override
  String get bottom => 'پایین';

  @override
  String get removeCustomTimer => 'حذف تایمر سفارشی (استفاده از پیش‌فرض کلی)';

  @override
  String get timers => 'تایمرها';

  @override
  String get timerSettings => 'تنظیمات تایمر';

  @override
  String get groupHistory => 'گروه‌بندی تاریخچه';

  @override
  String get showUnits => 'نمایش واحدها';

  @override
  String get showBodyWeight => 'نمایش وزن بدن';

  @override
  String get showCategories => 'نمایش دسته‌بندی‌ها';

  @override
  String get showNotes => 'نمایش یادداشت‌ها';

  @override
  String get durationEstimation => 'تخمین مدت';

  @override
  String get showGraphLimit => 'نمایش محدودیت نمودار';

  @override
  String get defaultGraphMetric => 'معیار پیش‌فرض نمودار';

  @override
  String get bestWeight => 'بهترین وزن';

  @override
  String get bestReps => 'بیشترین تکرار';

  @override
  String get oneRepMax => 'حداکثر یک تکرار';

  @override
  String get volume => 'حجم';

  @override
  String get paceCardio => 'سرعت (کاردیو)';

  @override
  String get distanceCardio => 'مسافت (کاردیو)';

  @override
  String get defaultGraphPeriod => 'دوره پیش‌فرض نمودار';

  @override
  String get defaultGraphLimit => 'محدودیت پیش‌فرض نمودار';

  @override
  String get workouts => 'تمرین‌ها';

  @override
  String get actionStop => 'توقف';

  @override
  String get timerFinishedToast => 'تایمر تمام شد!';

  @override
  String get stopTimer => 'توقف تایمر';

  @override
  String get actionPause => 'مکث';

  @override
  String get startStopwatch => 'شروع کرنومتر';

  @override
  String get actionStart => 'شروع';

  @override
  String get actionRestart => 'شروع دوباره';

  @override
  String get addOneMinute => '+1 دقیقه';

  @override
  String get addOneMinuteNotification => 'افزودن 1 دقیقه';

  @override
  String get restTimer => 'تایمر استراحت';

  @override
  String get timerUp => 'پایان تایمر';

  @override
  String get openNotification => 'باز کردن اعلان';

  @override
  String get timerChannelName => 'کانال تایمر';

  @override
  String get timerChannelDescription => 'پیشرفت جاری تایمرهای استراحت.';

  @override
  String get timerFinishedChannelName => 'کانال پایان تایمر';

  @override
  String get timerFinishedChannelDescription =>
      'هنگام پایان تایمر استراحت هشدار پخش می‌کند.';

  @override
  String get timerFinished => 'تایمر تمام شد';

  @override
  String get batteryOptimizationRequestUnavailable =>
      'درخواست نادیده گرفتن بهینه‌سازی باتری در دستگاه شما غیرفعال است.';

  @override
  String get exactAlarmRequestUnavailable =>
      'درخواست SCHEDULE_EXACT_ALARM در دستگاه شما رد شد';

  @override
  String get databaseMigrationFailureDescription =>
      'هنگام ساخت یا ارتقای پایگاه داده مشکلی پیش آمد. معمولاً با حذف و ایجاد دوباره رکوردها برطرف می‌شود.';

  @override
  String get curveSmoothness => 'نرمی منحنی';

  @override
  String get actionBack => 'بازگشت';

  @override
  String get atLeastOneTab => 'حداقل یک برگه لازم است';

  @override
  String get invalidTabSettings => 'تنظیمات برگه نامعتبر است.';

  @override
  String get noSettingsFound => 'تنظیمی پیدا نشد';

  @override
  String nothingMatchesSearch(String query) {
    return 'چیزی با «$query» مطابقت ندارد.';
  }

  @override
  String get appearanceDescription => 'پوسته، رنگ‌ها و سبک رابط';

  @override
  String get dataManagementDescription =>
      'داده‌های تمرین خود را وارد، صادر و مدیریت کنید';

  @override
  String get formatsDescription => 'قالب‌بندی تاریخ‌ها، اعداد و اندازه‌گیری‌ها';

  @override
  String get plansSettingsDescription => 'پیش‌فرض‌ها و رفتار برنامه‌های تمرینی';

  @override
  String get tabsDescription => 'برگه‌های اصلی پیمایش را انتخاب و مرتب کنید';

  @override
  String get timersDescription => 'مدت، صدا و رفتار تایمر استراحت';

  @override
  String get workoutsDescription => 'ردیابی تمرین و ترجیحات تمرینی';

  @override
  String get completeSetForChart =>
      'برای ساخت نمودار این تمرین یک ست را کامل کنید.';

  @override
  String get dateRange => 'بازه تاریخ';

  @override
  String get stopDate => 'تاریخ پایان';

  @override
  String get dataPoints => 'نقاط داده';

  @override
  String get completeSetsForProgress =>
      'چند ست را کامل کنید تا نمودار پیشرفت ساخته شود.';

  @override
  String get relativeStrength => 'قدرت نسبی';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد انتخاب شده',
      one: '1 مورد انتخاب شده',
    );
    return '$_temp0';
  }

  @override
  String get completeSetsForHistory =>
      'چند ست را کامل کنید تا تاریخچه این تمرین را اینجا ببینید.';

  @override
  String get completeSetForFirstGraph =>
      'برای ساخت اولین نمودار تمرین یک ست را کامل کنید.';

  @override
  String nothingMatchesGraphSearch(String query) {
    return 'چیزی با «$query» مطابقت ندارد. می‌توانید آن را به عنوان تمرین جدید بسازید.';
  }

  @override
  String addNamed(String name) {
    return 'افزودن «$name»';
  }

  @override
  String deleteGraphRecordsConfirmation(int count) {
    return 'این کار $count رکورد را حذف می‌کند. مطمئنید؟';
  }

  @override
  String shareWorkout(String summary) {
    return 'من همین الان $summary انجام دادم';
  }

  @override
  String get updateConflict => 'تعارض به‌روزرسانی';

  @override
  String updateConflictDescription(int count) {
    return 'نام جدید شما از قبل برای $count رکورد وجود دارد. مطمئنید؟';
  }

  @override
  String get unitsConflict => 'تعارض واحدها';

  @override
  String unitsConflictDescription(String unit) {
    return 'همه رکوردهای شما واحد یکسانی ندارند. این کار همه واحدها را به $unit تبدیل می‌کند. مطمئنید؟';
  }

  @override
  String get durationLabel => 'مدت';

  @override
  String get inclineLabel => 'شیب';

  @override
  String get paceDistanceTime => 'سرعت (مسافت / زمان)';

  @override
  String get adjustedPace => 'سرعت تعدیل‌شده';

  @override
  String get addPlan => 'افزودن برنامه';

  @override
  String get planDetails => 'جزئیات برنامه';

  @override
  String get exercisesLabel => 'تمرین‌ها';

  @override
  String get addExerciseToPlan => 'یک تمرین به این برنامه اضافه کنید.';

  @override
  String nothingMatchesExerciseSearch(String query) {
    return 'چیزی با «$query» مطابقت ندارد. می‌توانید آن را به عنوان تمرین جدید اضافه کنید.';
  }

  @override
  String get selectDays => 'انتخاب روزها';

  @override
  String get selectExercises => 'انتخاب تمرین‌ها';

  @override
  String get todayLabel => 'امروز';

  @override
  String get setDetails => 'جزئیات ست';

  @override
  String get themeLabel => 'پوسته';

  @override
  String get pureBlackAmoledDescription =>
      'برای نمایشگرهای AMOLED از رنگ‌های سیاه خالص استفاده کنید';

  @override
  String get systemColorScheme => 'طرح رنگ سیستم';

  @override
  String get systemColorSchemeDescription =>
      'از رنگ اصلی دستگاه برای برنامه استفاده کنید';

  @override
  String get showImagesDescription =>
      'تصاویر را در صفحه تاریخچه انتخاب یا نمایش دهید';

  @override
  String get showGlobalProgress => 'نمایش پیشرفت کلی';

  @override
  String get showGlobalProgressDescription =>
      'یک ورودی نمودار برای نمایش پیشرفت بر اساس دسته‌بندی اضافه کنید';

  @override
  String get peekGraphDescription =>
      'اولین نمودار خطی را در صفحه نمودارها نمایش دهید';

  @override
  String get inputStyleDescription => 'سبک ظاهری فیلدهای ورود متن';

  @override
  String get automaticBackupNotificationBody =>
      'Alpha هر روز به‌طور خودکار از داده‌ها و تصاویر شما در پوشه انتخاب‌شده پشتیبان می‌گیرد.';

  @override
  String get backupSettingsChannel => 'تنظیمات پشتیبان‌گیری';

  @override
  String get backupSettingsChannelDescription =>
      'اعلان‌هایی که پشتیبان‌گیری خودکار را توضیح می‌دهند';

  @override
  String get backupChannelName => 'کانال پشتیبان‌گیری';

  @override
  String get backupChannelDescription =>
      'پشتیبان‌گیری خودکار از داده‌ها و تصاویر Alpha';

  @override
  String get backupCompletedTitle =>
      'پشتیبان‌گیری از داده‌ها و تصاویر انجام شد';

  @override
  String get backupFailurePathNotSet =>
      'پشتیبان‌گیری ناموفق بود: مسیر پشتیبان تنظیم نشده است. پشتیبان‌گیری خودکار غیرفعال شد.';

  @override
  String get backupFailureDirectoryUnavailable =>
      'پشتیبان‌گیری ناموفق بود: دسترسی به پوشه پشتیبان ممکن نبود. پشتیبان‌گیری خودکار غیرفعال شد.';

  @override
  String get backupFailureCreateFile =>
      'پشتیبان‌گیری ناموفق بود: فایل پشتیبان ایجاد نشد. پشتیبان‌گیری خودکار غیرفعال شد.';

  @override
  String get backupFailureAppFilesUnavailable =>
      'پشتیبان‌گیری ناموفق بود: دسترسی به پوشه فایل‌های برنامه ممکن نبود. پشتیبان‌گیری خودکار غیرفعال شد.';

  @override
  String get backupFailureDatabaseMissing =>
      'پشتیبان‌گیری ناموفق بود: فایل پایگاه داده پیدا نشد. پشتیبان‌گیری خودکار غیرفعال شد.';

  @override
  String get backupFailureOutputUnavailable =>
      'پشتیبان‌گیری ناموفق بود: جریان خروجی باز نشد. پشتیبان‌گیری خودکار غیرفعال شد.';

  @override
  String get backupFailureUnknown =>
      'پشتیبان‌گیری ناموفق بود. پشتیبان‌گیری خودکار غیرفعال شد.';

  @override
  String get appPermissionsDescription =>
      'دسترسی‌های مورد نیاز قابلیت‌های فعال را بررسی کنید';

  @override
  String get longDateFormatDescription =>
      'جایی استفاده می‌شود که فضای کافی وجود دارد';

  @override
  String shortDateFormat(String example) {
    return 'قالب تاریخ کوتاه ($example)';
  }

  @override
  String get shortDateFormatDescription =>
      'برای جاهایی که فضا محدود است (خطوط نمودار)';

  @override
  String get warmupSetsDescription => 'ست‌های گرم‌کردن تایمر استراحت ندارند';

  @override
  String get setsPerExerciseDescription =>
      'تعداد پیش‌فرض تمرین‌ها در یک برنامه';

  @override
  String get planTrailingDisplay => 'نمایش انتهای برنامه';

  @override
  String get planTrailingDisplayDescription =>
      'آنچه در سمت راست فهرست در نمای Plans + Plan نشان داده می‌شود';

  @override
  String get restTimersDescription =>
      'هشداری که پس از کامل کردن یک ست اجرا می‌شود';

  @override
  String get vibrateDescription => 'آیا تایمرهای استراحت بلرزند؟';

  @override
  String get enableSoundDescription => 'آیا تایمرهای استراحت صدا پخش کنند؟';

  @override
  String get keepScreenOnDescription =>
      'هنگام تایمرهای استراحت صفحه را روشن نگه دارید';

  @override
  String get keepRingingDescription =>
      'صدا و لرزش هشدار را تا زمانی که لغوش کنید تکرار کن';

  @override
  String get restDurationDescription => 'چه مدت تا اجرای هشدار استراحت؟';

  @override
  String get globalDefault => 'پیش‌فرض کلی';

  @override
  String get alarmSoundDescription =>
      'موسیقی‌ای که در پایان تایمر استراحت پخش می‌شود';

  @override
  String get progressBarPosition => 'محل نوار پیشرفت';

  @override
  String get progressBarPositionDescription =>
      'نوار پیشرفت تایمرهای استراحت کجا قرار بگیرد؟';

  @override
  String get perExerciseRestTimes => 'زمان استراحت برای هر تمرین';

  @override
  String get perExerciseRestTimesDescription =>
      'این تمرین‌ها مدت استراحت سفارشی دارند';

  @override
  String get audioFeaturesUnavailable => 'قابلیت‌های صوتی در دسترس نیستند';

  @override
  String get groupHistoryDescription =>
      'ورودی‌های تاریخچه را بر اساس روز ترکیب کنید';

  @override
  String get showUnitsDescription =>
      'نمایش km/mi و kg/lb در نمودارها/تاریخچه/برنامه‌ها';

  @override
  String get showBodyWeightDescription => 'فعال/غیرفعال کردن ردیابی وزن بدن';

  @override
  String get showCategoriesDescription =>
      'فعال/غیرفعال کردن دسته‌بندی‌های تمرین';

  @override
  String get showNotesDescription =>
      'جزئیات حرکت خود را در یک بخش متنی ثبت کنید';

  @override
  String get positiveReinforcement => 'تقویت مثبت';

  @override
  String get positiveNotificationsDescription =>
      'هنگام ثبت رکورد جدید پیام‌های تشویقی نمایش دهید';

  @override
  String get positiveMessagesEnabled =>
      'پیام‌های مثبت حالا این‌طور نمایش داده می‌شوند!';

  @override
  String get recordEncouragement01 => 'عالی بود! فوق‌العاده‌ای.';

  @override
  String get recordEncouragement02 => 'دمت گرم قهرمان! پیشرفتت الهام‌بخش است.';

  @override
  String get recordEncouragement03 => 'تعظیم می‌کنم...';

  @override
  String get recordEncouragement04 => 'این چیه؟ یک رکورد جدید!';

  @override
  String get recordEncouragement05 => 'فوق‌العاده بود! واقعاً الهام‌بخشی.';

  @override
  String get recordEncouragement06 => 'واو. عالی.';

  @override
  String get recordEncouragement07 => 'خیلی قوی شدی، نه؟';

  @override
  String get recordEncouragement08 => 'آره. حسابی بزرگ شدی.';

  @override
  String get recordEncouragement09 => 'شگفت‌انگیز. فوق‌العاده.';

  @override
  String get recordEncouragement10 => 'آرنی بهت افتخار می‌کرد.';

  @override
  String get recordEncouragement11 => 'رانی سی با خوشحالی نگاهت می‌کند.';

  @override
  String get recordEncouragement12 => 'آره! لایت‌ویت بیبی!!!!!!!';

  @override
  String get recordEncouragement13 =>
      'این یک رکورد جدید بود؟ می‌دانستم می‌توانی.';

  @override
  String get recordEncouragement14 => 'عالی بود! بهت افتخار می‌کنم.';

  @override
  String get recordEncouragement15 => 'آره بیبی! لایت‌ویت!';

  @override
  String get recordEncouragement16 => 'ادامه بده! پیشرفت عالیه.';

  @override
  String get recordEncouragement17 => 'خیلی خوب داری پیش می‌ری.';

  @override
  String get recordEncouragement18 => 'آفرین پسر!';

  @override
  String get recordEncouragement19 => 'ادامه بده.';

  @override
  String get recordEncouragement20 => 'داری خیلی قوی می‌شی.';

  @override
  String get recordEncouragement21 => 'قدرتمند.';

  @override
  String get recordEncouragement22 => 'چه قدرتی!';

  @override
  String get recordEncouragement23 => 'بهت افتخار می‌کنم.';

  @override
  String get recordEncouragement24 => 'همین کار عالی را ادامه بده.';

  @override
  String get recordEncouragement25 =>
      'سرت را بالا بگیر! همین الان رکورد جدید زدی.';

  @override
  String get recordEncouragement26 => 'رکورد جدید! از همیشه جلوتر رفتی!';

  @override
  String get recordEncouragement27 => 'آره! این رکورده.';

  @override
  String get recordEncouragement28 => 'واو! رکورد جدید!';

  @override
  String get recordEncouragement29 => 'خیلی خوب بود.';

  @override
  String get durationEstimationDescription =>
      'سعی کنید مدت کاردیوی خود را تخمین بزنید';

  @override
  String get showGraphXAxisToggle => 'نمایش کلید محور X نمودار';

  @override
  String get showGraphXAxisToggleDescription =>
      'کلید محور X مبتنی بر زمان را روی نمودارها نمایش دهید';

  @override
  String get showGraphLimitDescription =>
      'لغزنده محدودیت را روی نمودارها نمایش دهید';

  @override
  String get defaultTimeBasedXAxis => 'محور X پیش‌فرض مبتنی بر زمان';

  @override
  String get defaultTimeBasedXAxisDescription =>
      'به‌طور پیش‌فرض در نمودارها از محور X مبتنی بر زمان استفاده کنید';

  @override
  String get createFirstTrainingPlan =>
      'برای شروع اولین برنامه تمرینی خود را بسازید.';

  @override
  String nothingMatchesPlanSearch(String query) {
    return 'چیزی با «$query» مطابقت ندارد. می‌توانید آن را به عنوان برنامه جدید بسازید.';
  }

  @override
  String get createPlan => 'ایجاد برنامه';

  @override
  String createNamedPlan(String name) {
    return 'ایجاد «$name»';
  }

  @override
  String setNumber(int number) {
    return 'ست $number';
  }

  @override
  String get tabStart => 'شروع';

  @override
  String get tabTraining => 'تمرین';

  @override
  String get tabExercises => 'حرکت‌ها';

  @override
  String get tabProfile => 'نمایه';

  @override
  String get calendarTitle => 'تقویم';

  @override
  String dayStreak(int count) {
    return '$count روز پیاپی';
  }

  @override
  String weekStreak(int count) {
    return '$count هفته پیاپی';
  }

  @override
  String get thisWeek => 'این هفته';

  @override
  String get bodyWeightChart => 'وزن بدن';

  @override
  String get strengthChart => 'قدرت';

  @override
  String get weeklyVolumeChart => 'حجم هفتگی';

  @override
  String get noChartData => 'داده هنوز کم است';

  @override
  String get newTemplate => 'الگوی تازه';

  @override
  String get templateLimit => 'تا ۷ الگو می‌توانی ذخیره کنی.';

  @override
  String get templatesEmpty => 'این الگو هنوز حرکتی ندارد.';

  @override
  String get allMuscles => 'همه';

  @override
  String get noHistory => 'هنوز سابقه‌ای نیست';

  @override
  String bestOneRepMax(String value) {
    return 'یک تکرار بیشینه تخمینی $value کیلو';
  }

  @override
  String bestLoad(String value) {
    return 'بهترین وزنه $value کیلو';
  }

  @override
  String get profileName => 'نام';

  @override
  String get heightCm => 'قد (سانتی‌متر)';

  @override
  String get ageOptional => 'سن (اختیاری)';

  @override
  String get goals => 'هدف‌ها';

  @override
  String get bodyData => 'داده‌های بدن';

  @override
  String get addBodyWeight => 'افزودن وزن';

  @override
  String get weightKg => 'وزن (کیلوگرم)';

  @override
  String get aiCoaching => 'مربی هوش مصنوعی';

  @override
  String get apiKey => 'کلید API';

  @override
  String get apiKeyStoredLocally =>
      'فقط روی همین گوشی ذخیره می‌شود. هنوز استفاده نمی‌شود.';

  @override
  String get profileSaved => 'نمایه ذخیره شد';

  @override
  String get noTrainingThisDay => 'در این روز چیزی ثبت نشده';

  @override
  String targetSets(int count) {
    return '$count ست';
  }

  @override
  String repRangeLabel(String range) {
    return '$range تکرار';
  }

  @override
  String get repMinLabel => 'تکرار از';

  @override
  String get repMaxLabel => 'تکرار تا';

  @override
  String get exerciseDatabaseCreditTitle => 'کتابخانه حرکات';

  @override
  String get exerciseDatabaseCreditBody =>
      'نام‌ها از free-exercise-db اثر yuhonas با مجوز Unlicense (مالکیت عمومی). Alpha نام‌ها و نام‌های مستعار را افزوده است.';

  @override
  String get workoutFinish => 'Beenden';

  @override
  String get volumeLabel => 'Volumen';

  @override
  String get setsLabel => 'Sätze';

  @override
  String get restSkip => 'Überspringen';

  @override
  String get columnSet => 'SATZ';

  @override
  String get columnPrevious => 'VORHERIGE';

  @override
  String get columnKg => 'KG';

  @override
  String get columnReps => 'WDH';

  @override
  String get addExerciseWorkout => 'Übung hinzufügen';

  @override
  String get addNote => 'Notiz hinzufügen';

  @override
  String get swapExercise => 'Übung tauschen';

  @override
  String get moveExerciseUp => 'Nach oben';

  @override
  String get moveExerciseDown => 'Nach unten';

  @override
  String get removeExercise => 'Entfernen';

  @override
  String get restSecondsLabel => 'Pause in Sekunden';

  @override
  String get newRecordTitle => 'NEUER REKORD!';

  @override
  String get recordKeepGoing => 'Weiter so';

  @override
  String get exerciseSearchHint => 'Übung suchen';

  @override
  String get installUpdate => 'Update installieren';

  @override
  String get updateAvailable => 'Eine neuere Version ist da';

  @override
  String get localProfiles => 'Profile';

  @override
  String get newProfile => 'Neues Profil';

  @override
  String get profileNameHint => 'Profilname';

  @override
  String get profileActive => 'Aktiv';

  @override
  String get switchProfile => 'Wechseln';

  @override
  String get themeSetting => 'Design';

  @override
  String get themeTiefschwarz => 'Tiefschwarz';

  @override
  String get themeEisblau => 'Eisblau';

  @override
  String get themePink => 'Pink';

  @override
  String get restSound => 'Pausenton';

  @override
  String get restSoundVolume => 'Lautstärke der Pause';

  @override
  String get restSoundCredit => 'Notification Sound von yfjesse, CC0';

  @override
  String get splashMotto => 'Stärke. Disziplin. Fortschritt.';

  @override
  String helloName(String name) {
    return 'Hallo, $name';
  }

  @override
  String get alphaSettings => 'Alpha';

  @override
  String get alphaSettingsDescription => 'Profile, Design und Pausenton';

  @override
  String get finishWorkoutAsk => 'این تمرین تمام شود؟';

  @override
  String get finishWorkoutBody => 'جلسه ذخیره می‌شود و قالب همان می‌ماند.';

  @override
  String get discardWorkoutAsk => 'این تمرین کنار گذاشته شود؟';

  @override
  String get discardWorkoutBody => 'ست‌های ثبت‌شده این جلسه حذف می‌شوند.';

  @override
  String get noRest => 'بدون استراحت';

  @override
  String get restWheelTitle => 'استراحت';

  @override
  String get deleteTemplateAsk => 'این قالب حذف شود؟';

  @override
  String deleteTemplateBody(String name) {
    return '«$name» حذف شود؟ تمرین‌های ذخیره‌شده می‌مانند.';
  }

  @override
  String get warmupAction => 'گرم کردن';

  @override
  String get warmupMark => 'W';

  @override
  String get confirmAddExercise => 'افزودن حرکت';

  @override
  String get tabOverview => 'نمای کلی';

  @override
  String get tabHistory => 'تاریخچه';

  @override
  String get tabHowTo => 'اجرا';

  @override
  String get primaryMuscleLabel => 'عضله اصلی';

  @override
  String get secondaryMuscleLabel => 'عضله‌های کمکی';

  @override
  String get equipmentLabel => 'وسیله';

  @override
  String get heaviestWeight => 'سنگین‌ترین وزن';

  @override
  String get estimatedOneRm => '۱RM تخمینی';

  @override
  String get volumeChart => 'حجم تمرین';

  @override
  String get recordsTitle => 'رکوردها';

  @override
  String get weekGoal => 'هدف هفته';

  @override
  String weekGoalProgress(int done, int goal) {
    return '$done از $goal';
  }

  @override
  String startWorkoutNamed(String name) {
    return 'شروع تمرین · $name';
  }

  @override
  String get musclesThisWeek => 'عضله‌های این هفته';

  @override
  String get progressHeading => 'پیشرفت';

  @override
  String get lastEightWeeks => 'هشت هفته اخیر';

  @override
  String get chooseProfile => 'یک نمایه انتخاب کنید';

  @override
  String get createProfileAction => 'ساخت نمایه';

  @override
  String get plateCalculator => 'ماشین‌حساب صفحه';

  @override
  String get barbellCalc => 'هالتر';

  @override
  String get cableCalc => 'برج کابل';

  @override
  String get extraWeight => 'وزن اضافه';

  @override
  String get barWeightLabel => 'وزن میله';

  @override
  String get plateSetLabel => 'صفحه در هر سمت';

  @override
  String get cableStepLabel => 'گام دسته وزنه';

  @override
  String get chooseGym => 'باشگاه را انتخاب کنید';

  @override
  String get gymsTitle => 'باشگاه‌ها';

  @override
  String get newGym => 'باشگاه تازه';

  @override
  String get progressionHelp => 'کمک پیشرفت';

  @override
  String progressionAsk(String name, String weight, int reps) {
    return '$name: دفعه بعد $weight کیلو و شروع دوباره از $reps تکرار؟';
  }

  @override
  String get actionAccept => 'پذیرفتن';

  @override
  String get actionReject => 'رد کردن';

  @override
  String get importExportTitle => 'وارد و خارج کردن داده';

  @override
  String get importWorkouts => 'وارد کردن تمرین‌ها';

  @override
  String get importMeasurements => 'وارد کردن اندازه‌ها';

  @override
  String get exportAlphaData => 'خروجی داده Alpha';

  @override
  String get importPreviewTitle => 'پیش‌نمایش ورود';

  @override
  String importSummary(int workouts, int exercises) {
    return '$workouts تمرین، $exercises حرکت';
  }

  @override
  String get templatesDetected => 'قالب‌های شناخته‌شده';

  @override
  String get renameLabel => 'تغییر نام';

  @override
  String get mapExercise => 'تطبیق حرکت';

  @override
  String get checkForUpdates => 'جستجوی به‌روزرسانی';

  @override
  String get upToDate => 'نسخه شما تازه است';

  @override
  String get updateCheckFailed => 'جستجوی به‌روزرسانی ناموفق بود';

  @override
  String get licensesTitle => 'مجوزها';

  @override
  String get flexifyMitNotice =>
      'Flexify با مجوز MIT منتشر شده است. Copyright Brandon Dick.';

  @override
  String get exerciseDbNotice => 'هر حرکت منبع و مجوز خودش را نشان می‌دهد.';

  @override
  String get sourceLabel => 'منبع';

  @override
  String get tipsLabel => 'نکته‌ها';

  @override
  String get imageSourceLabel => 'منبع تصویر';

  @override
  String get imageLicenseLabel => 'مجوز تصویر';

  @override
  String get muscleUpperChest => 'سینه بالا';

  @override
  String get muscleFrontShoulder => 'سرشانه جلو';

  @override
  String get muscleSideShoulder => 'سرشانه بغل';

  @override
  String get muscleRearShoulder => 'سرشانه پشت';

  @override
  String get muscleLatissimus => 'لت';

  @override
  String get muscleUpperBack => 'بالای کمر';

  @override
  String get muscleTrapez => 'کول';

  @override
  String get muscleLowerBack => 'پایین کمر';

  @override
  String get muscleForearms => 'ساعد';

  @override
  String get muscleRectus => 'عضله راست شکم';

  @override
  String get muscleObliques => 'مورب شکم';

  @override
  String get muscleQuadriceps => 'چهارسر';

  @override
  String get muscleAdductors => 'نزدیک‌کننده';

  @override
  String get muscleAbductors => 'دورکننده';

  @override
  String get muscleHipFlexors => 'خم‌کننده لگن';

  @override
  String get alternativesLabel => 'جایگزین‌ها';

  @override
  String get mechanicLabel => 'مکانیک';

  @override
  String get aiCoachTitle => 'مربی هوش مصنوعی';

  @override
  String get aiProviderLabel => 'ارائه‌دهنده';

  @override
  String get aiOffNotice =>
      'تا وقتی کلید خودتان را ذخیره نکنید مربی خاموش است.';

  @override
  String get coachHint => 'از مربی بپرس';

  @override
  String get voiceInput => 'ورود صوتی';

  @override
  String voiceUnderstood(String text) {
    return 'فهمیدم: $text';
  }

  @override
  String get speechFailed => 'ورود صوتی ناموفق بود';

  @override
  String get confirmVoiceSet => 'این ست اعمال شود؟';

  @override
  String get periodSession => 'این تمرین';

  @override
  String get muscleMapTitle => 'نقشه عضله';

  @override
  String get frontView => 'جلو';

  @override
  String get backView => 'پشت';

  @override
  String quoteKeepGoing(int done, int goal) {
    return '$done از $goal جلسه این هفته. ادامه بده.';
  }

  @override
  String quoteRemaining(int count) {
    return '$count جلسه این هفته مانده است.';
  }

  @override
  String get quotePullDay => 'روز کشش. پشت و دوسر بازو آماده‌اند.';

  @override
  String get quotePushDay => 'روز فشار. سینه، شانه و سه‌سر.';

  @override
  String get quoteLegDay => 'روز پا. چهارسر، همسترینگ و سرینی.';

  @override
  String versionAndLicenses(String version) {
    return 'نسخه $version · مجوزها';
  }

  @override
  String get liveWorkoutLabel => 'تمرین در جریان است';

  @override
  String get muscleChest => 'سینه';

  @override
  String get muscleShoulders => 'شانه‌ها';

  @override
  String get muscleBiceps => 'دوسر بازو';

  @override
  String get muscleTriceps => 'سه‌سر بازو';

  @override
  String get muscleAbs => 'شکم';

  @override
  String get muscleQuads => 'چهارسر';

  @override
  String get muscleCalves => 'ساق';

  @override
  String get muscleTraps => 'ذوزنقه‌ای';

  @override
  String get muscleBack => 'پشت';

  @override
  String get muscleGlutes => 'سرینی';

  @override
  String get muscleHams => 'همسترینگ';

  @override
  String get weekGoalManual => 'هدف هفته را خودت بگذار';

  @override
  String get sessionsPerWeek => 'جلسه در هفته';

  @override
  String get gymNameHint => 'نام باشگاه';

  @override
  String get coachProfileNote => 'یادداشت مربی';

  @override
  String get openPackageLicenses => 'مجوز بسته‌ها را باز کن';

  @override
  String get lengthUnitLabel => 'قد بدن';

  @override
  String get centimetersShort => 'سانتی‌متر (cm)';

  @override
  String get inchesShort => 'اینچ (in)';

  @override
  String get heightInches => 'قد (اینچ)';

  @override
  String get welcomeToAlpha => 'به Alpha خوش آمدید';

  @override
  String get createProfileButton => 'ساختن نمایه';

  @override
  String get onboardingWeightHint => 'وزن بدن، اختیاری';

  @override
  String get familyLabel => 'خانواده';

  @override
  String get gripLabel => 'گرفتن';

  @override
  String get positionLabel => 'وضعیت';

  @override
  String get movementLabel => 'حرکت';

  @override
  String get unilateralLabel => 'یک‌طرفه';

  @override
  String get otherVariants => 'گونه‌های دیگر';

  @override
  String get sideLeft => 'چپ';

  @override
  String get sideRight => 'راست';

  @override
  String get createCustomExercise => 'ساخت حرکت';

  @override
  String get editCustomExercise => 'ویرایش حرکت';

  @override
  String get deleteCustomExercise => 'حذف حرکت';

  @override
  String get deleteCustomExerciseBody =>
      'این حرکت حذف شود؟ تمرین‌های قبلی در تاریخچه می‌مانند.';

  @override
  String get customExerciseName => 'نام';

  @override
  String get customExerciseFamily => 'شناسه خانواده';

  @override
  String get createAsCustomExercise => 'ساخت به‌عنوان حرکت شخصی';

  @override
  String get customExerciseInvalid => 'نام، عضله‌ها و وسیله را انتخاب کنید.';

  @override
  String get motionPress => 'پرس';

  @override
  String get motionPull => 'کشش';

  @override
  String get motionLegs => 'پا/لگن';

  @override
  String get motionCore => 'میان‌تنه';

  @override
  String get motionCardio => 'کاردیو';

  @override
  String get mechanicCompound => 'ترکیبی';

  @override
  String get mechanicIsolation => 'ایزوله';

  @override
  String get ownExerciseSource => 'حرکت شخصی';

  @override
  String get notSpecified => '–';

  @override
  String get resumeWorkout => 'ادامه تمرین';

  @override
  String get importBackupZip => 'درون‌ریزی پشتیبان (.zip)';

  @override
  String importSetSummary(int workouts, int sets) {
    return '$workouts تمرین، $sets ست';
  }

  @override
  String importDateErrorCount(int count) {
    return '$count ردیف تاریخی دارند که خوانده نشد.';
  }

  @override
  String importUnmatchedNames(String names) {
    return 'بدون تطبیق: $names';
  }

  @override
  String importTemplatesSkipped(String names) {
    return 'ساخته نشد، سقف قالب‌ها پر است: $names';
  }

  @override
  String importApplying(int done, int total) {
    return '$done از $total';
  }

  @override
  String get customExerciseMovementRequired => 'یک حرکت انتخاب کن.';

  @override
  String get setRemoved => 'ست حذف شد';

  @override
  String get exerciseRemovedUndo => 'حرکت حذف شد';

  @override
  String get exerciseSwappedUndo => 'حرکت عوض شد';

  @override
  String get saveRestInTemplate => 'در قالب هم ذخیره شود';

  @override
  String get deleteGymTitle => 'باشگاه حذف شود؟';

  @override
  String get deleteGymBody =>
      'تمرین‌های مرتبط با این باشگاه می‌مانند. فقط باشگاه حذف می‌شود.';

  @override
  String get renameGym => 'تغییر نام باشگاه';

  @override
  String get cleanupImports => 'پاک‌سازی موارد واردشده';

  @override
  String cleanupImportsPreview(int workouts, int templates) {
    return '$workouts تمرین واردشده و $templates قالب حذف می‌شوند. تمرین‌های دستی می‌مانند.';
  }

  @override
  String get cleanupImportsEmpty => 'چیزی برای پاک‌سازی نیست.';

  @override
  String get cleanupImportsDone => 'موارد واردشده حذف شدند.';

  @override
  String measurementsImported(int count) {
    return '$count اندازه‌گیری وارد شد.';
  }
}
