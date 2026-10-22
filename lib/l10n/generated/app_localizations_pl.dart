// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Alpha';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageDescription => 'Wybierz język używany przez Alpha';

  @override
  String get languageSystemDefault => 'Domyślny systemowy';

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
  String get navHistory => 'Historia';

  @override
  String get navPlans => 'Plany';

  @override
  String get navGraphs => 'Wykresy';

  @override
  String get navTimer => 'Minutnik';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get errorLabel => 'Błąd';

  @override
  String get tabContentError => 'Nie udało się wyświetlić zawartości karty.';

  @override
  String get cannotHideAllTabs => 'Nie można ukryć wszystkiego!';

  @override
  String removeTabQuestion(String tab) {
    return 'Usunąć kartę $tab?';
  }

  @override
  String get restoreTabFromSettings =>
      'Możesz dodać ją ponownie później w ustawieniach.';

  @override
  String removedTab(String tab) {
    return 'Usunięto $tab';
  }

  @override
  String newVersion(String version) {
    return 'Nowa wersja $version';
  }

  @override
  String get changes => 'Zmiany';

  @override
  String get searchHint => 'Szukaj...';

  @override
  String get deleteSelected => 'Usuń zaznaczone';

  @override
  String get confirmDelete => 'Potwierdź usunięcie';

  @override
  String deleteRecordsConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Czy na pewno chcesz usunąć $count rekordu? Tej operacji nie można cofnąć.',
      many:
          'Czy na pewno chcesz usunąć $count rekordów? Tej operacji nie można cofnąć.',
      few:
          'Czy na pewno chcesz usunąć $count rekordy? Tej operacji nie można cofnąć.',
      one:
          'Czy na pewno chcesz usunąć 1 rekord? Tej operacji nie można cofnąć.',
    );
    return '$_temp0';
  }

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionDiscard => 'Odrzuć';

  @override
  String get unsavedChanges => 'Niezapisane zmiany';

  @override
  String get discardUnsavedChanges => 'Odrzucić niezapisane zmiany?';

  @override
  String get actionDelete => 'Usuń';

  @override
  String get actionRemove => 'Usuń';

  @override
  String get actionEdit => 'Edytuj';

  @override
  String get actionShare => 'Udostępnij';

  @override
  String get clearSelection => 'Wyczyść zaznaczenie';

  @override
  String get clearSearch => 'Wyczyść wyszukiwanie';

  @override
  String get showMenu => 'Pokaż menu';

  @override
  String get selectAll => 'Zaznacz wszystko';

  @override
  String get weightLabel => 'Ciężar';

  @override
  String get filter => 'Filtr';

  @override
  String get filters => 'Filtry';

  @override
  String get categoryLabel => 'Kategoria';

  @override
  String get repsLabel => 'Powtórzenia';

  @override
  String get repsFilter => 'Filtr powtórzeń';

  @override
  String get weightFilter => 'Filtr ciężaru';

  @override
  String get greaterThan => 'Większe niż';

  @override
  String get lessThan => 'Mniejsze niż';

  @override
  String get startDate => 'Data początkowa';

  @override
  String get endDate => 'Data końcowa';

  @override
  String get actionClear => 'Wyczyść';

  @override
  String get actionOk => 'OK';

  @override
  String get actionClose => 'Zamknij';

  @override
  String get sortBy => 'Sortuj według';

  @override
  String get dateNewest => 'Data (najnowsze)';

  @override
  String get dateOldest => 'Data (najstarsze)';

  @override
  String get nameLabel => 'Nazwa';

  @override
  String get missingPermissions => 'Brakujące uprawnienia';

  @override
  String get restTimersPermissionsMissing =>
      'Minutniki odpoczynku są włączone, ale brakuje uprawnień.';

  @override
  String get restTimersPermissionsOptional =>
      'Jeśli wyłączysz minutniki odpoczynku, te uprawnienia nie będą potrzebne.';

  @override
  String get restTimers => 'Minutniki odpoczynku';

  @override
  String get disableBatteryOptimizations => 'Wyłącz optymalizację baterii';

  @override
  String get batteryOptimizationWarning =>
      'Postęp może się zatrzymać, jeśli optymalizacja baterii pozostanie włączona.';

  @override
  String get scheduleExactAlarm => 'Zaplanuj dokładny alarm';

  @override
  String get exactAlarmWarning =>
      'Alarmy nie będą dokładne, jeśli ta opcja jest wyłączona.';

  @override
  String get postNotifications => 'Wyświetlaj powiadomienia';

  @override
  String get notificationBarDescription =>
      'Postęp minutnika jest wyświetlany na pasku powiadomień';

  @override
  String get invalidPermissions => 'Nieprawidłowe uprawnienia';

  @override
  String get insufficientTimerPermissionsConfirmation =>
      'Minutniki odpoczynku są włączone bez wystarczających uprawnień. Czy na pewno chcesz kontynuować?';

  @override
  String get actionConfirm => 'Potwierdź';

  @override
  String get appAccess => 'Dostęp aplikacji';

  @override
  String get appAccessDescription =>
      'Wymagany przez włączone minutniki i powiadomienia.';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get timerProgressAndRestAlerts =>
      'Postęp minutnika i alerty odpoczynku';

  @override
  String get enabledNotificationsDescription =>
      'Włączone przez Ciebie powiadomienia';

  @override
  String get backgroundActivity => 'Aktywność w tle';

  @override
  String get backgroundActivityDescription =>
      'Zapewnia niezawodne działanie minutników w tle';

  @override
  String get exactAlarms => 'Dokładne alarmy';

  @override
  String get exactAlarmsDescription =>
      'Powiadamiaj dokładnie po zakończeniu minutnika odpoczynku';

  @override
  String get noAdditionalAndroidAccessNeeded =>
      'Przy obecnych ustawieniach nie jest wymagany dodatkowy dostęp Androida.';

  @override
  String get actionDone => 'Gotowe';

  @override
  String get allowed => 'Dozwolone';

  @override
  String get actionAllow => 'Zezwól';

  @override
  String get backupLabel => 'Kopia zapasowa';

  @override
  String get databaseLabel => 'Baza danych';

  @override
  String get deleteRecords => 'Usuń rekordy';

  @override
  String get deleteAllGraphsConfirmation =>
      'Czy na pewno chcesz usunąć wszystkie wykresy? Tej operacji nie można cofnąć.';

  @override
  String get deleteAllPlansConfirmation =>
      'Czy na pewno chcesz usunąć wszystkie plany? Tej operacji nie można cofnąć.';

  @override
  String get deleteDatabaseConfirmation =>
      'Czy na pewno chcesz usunąć bazę danych? Tej operacji nie można cofnąć, a wszystkie dane zostaną utracone.';

  @override
  String get importData => 'Importuj dane';

  @override
  String get exportData => 'Eksportuj dane';

  @override
  String get actionReport => 'Zgłoś';

  @override
  String get graphDataImported =>
      'Dane wykresów zostały pomyślnie zaimportowane!';

  @override
  String get plansImported => 'Plany zostały pomyślnie zaimportowane';

  @override
  String failedToImportDatabase(String error) {
    return 'Nie udało się zaimportować bazy danych: $error';
  }

  @override
  String get backupArchiveMissingDatabase =>
      'Kopia zapasowa nie zawiera bazy danych Alpha.';

  @override
  String failedToImportGraphs(String error) {
    return 'Nie udało się zaimportować wykresów: $error';
  }

  @override
  String failedToImportPlans(String error) {
    return 'Nie udało się zaimportować planów: $error';
  }

  @override
  String get selectedFileDoesNotExist => 'Wybrany plik nie istnieje';

  @override
  String get couldNotReadFileData => 'Nie udało się odczytać danych pliku';

  @override
  String get databaseImportWebUnsupported =>
      'Import bazy danych w przeglądarce wymaga ręcznej migracji danych. Wyeksportuj dane jako pliki CSV i zaimportuj je zamiast bazy danych.';

  @override
  String get csvFileEmpty => 'Plik CSV jest pusty';

  @override
  String get csvNeedsDataRow =>
      'Plik CSV musi zawierać co najmniej jeden wiersz danych';

  @override
  String csvRowInsufficientColumns(int row, int count) {
    return 'Wiersz $row ma za mało kolumn: $count';
  }

  @override
  String invalidCsvValue(String field, int row, String value) {
    return 'Nieprawidłowa wartość $field w wierszu $row: $value';
  }

  @override
  String invalidCsvDataType(String field, int row, String type) {
    return 'Nieprawidłowy typ danych $field w wierszu $row: $type';
  }

  @override
  String expectedIntegerPlanId(String value) {
    return 'Oczekiwano całkowitego identyfikatora planu, otrzymano \"$value\"';
  }

  @override
  String get unitLabel => 'Jednostka';

  @override
  String get kilogramsUnit => 'Kilogramy (kg)';

  @override
  String get poundsUnit => 'Funty (lb)';

  @override
  String get stoneUnit => 'Stone';

  @override
  String get stoneUnitShort => 'st';

  @override
  String get kilometersUnit => 'Kilometry (km)';

  @override
  String get milesUnit => 'Mile (mi)';

  @override
  String get metersUnit => 'Metry (m)';

  @override
  String get kilocaloriesUnit => 'Kilokalorie (kcal)';

  @override
  String get enterWeight => 'Wprowadź ciężar';

  @override
  String get requiredField => 'Wymagane';

  @override
  String get invalidNumber => 'Nieprawidłowa liczba';

  @override
  String get previousWeight => 'Poprzedni ciężar';

  @override
  String get imageLabel => 'Obraz';

  @override
  String get longPressToDelete => 'Przytrzymaj, aby usunąć';

  @override
  String get imageError => 'Błąd obrazu';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get aboutTitle => 'O aplikacji';

  @override
  String get donate => 'Wesprzyj';

  @override
  String get helpSupportProject => 'Pomóż wesprzeć ten projekt';

  @override
  String get whatsNewAbout => 'Co nowego?';

  @override
  String get whatsNewTitle => 'Co nowego?';

  @override
  String get seeReleaseNotes => 'Zobacz informacje o wydaniu';

  @override
  String get versionLabel => 'Wersja';

  @override
  String get authorLabel => 'Autor';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get privacyPolicyDescription => 'Jak Alpha przetwarza Twoje dane';

  @override
  String get licenseLabel => 'Licencja';

  @override
  String get sourceCode => 'Kod źródłowy';

  @override
  String get sourceCodeDescription => 'Zobacz na GitHubie';

  @override
  String get leaveReview => 'Dodaj opinię';

  @override
  String get leaveReviewDescription => 'Oceń Alpha w Sklepie Play';

  @override
  String get reportBug => 'Zgłoś błąd';

  @override
  String get reportBugDescription => 'Utwórz zgłoszenie na GitHubie';

  @override
  String get failedMigrations => 'Nieudane migracje';

  @override
  String get errorMessageLabel => 'Komunikat błędu:';

  @override
  String get createIssue => 'Utwórz zgłoszenie';

  @override
  String get addExercise => 'Dodaj ćwiczenie';

  @override
  String get cardio => 'Cardio';

  @override
  String get strength => 'Siła';

  @override
  String get options => 'Opcje';

  @override
  String get periodDay => 'Dzień';

  @override
  String get periodWeek => 'Tydzień';

  @override
  String get periodMonth => 'Miesiąc';

  @override
  String get periodYear => 'Rok';

  @override
  String noDataFor(String name) {
    return 'Brak danych dla $name';
  }

  @override
  String get noDataYet => 'Brak danych';

  @override
  String get exerciseNotes => 'Notatki do ćwiczenia';

  @override
  String get notesForExercise => 'Notatki do tego ćwiczenia';

  @override
  String get useTimeBasedXAxis => 'Użyj osi X opartej na czasie';

  @override
  String updateAllNamed(String name) {
    return 'Zaktualizuj wszystkie $name';
  }

  @override
  String get newName => 'Nowa nazwa';

  @override
  String get restMinutes => 'Minuty odpoczynku';

  @override
  String get restSeconds => 'Sekundy odpoczynku';

  @override
  String get globalProgress => 'Postęp ogólny';

  @override
  String get curveLineGraphs => 'Wygładzone linie wykresów';

  @override
  String get curveLineGraphsDescription =>
      'Rysuj linie wykresów jako płynne krzywe';

  @override
  String noHistoryFor(String name) {
    return 'Brak historii dla $name';
  }

  @override
  String get cancelSelection => 'Anuluj zaznaczenie';

  @override
  String get editSelected => 'Edytuj zaznaczone';

  @override
  String get newExercise => 'Nowe ćwiczenie';

  @override
  String get noGraphsFound => 'Nie znaleziono wykresów';

  @override
  String get searchGraphs => 'Szukaj wykresów...';

  @override
  String get actionAdd => 'Dodaj';

  @override
  String get actionUpdate => 'Aktualizuj';

  @override
  String get hideGlobalProgress => 'Ukryj postęp ogólny';

  @override
  String get chartGroupedByCategory => 'Wykres pogrupowany według kategorii';

  @override
  String get noExercisesFound => 'Nie znaleziono ćwiczeń';

  @override
  String get savePlan => 'Zapisz plan';

  @override
  String get titleOptional => 'Tytuł (opcjonalnie)';

  @override
  String get searchExercises => 'Szukaj ćwiczeń';

  @override
  String get warmupSets => 'Serie rozgrzewkowe';

  @override
  String get workingSetsMax => 'Serie robocze (maks.: 20)';

  @override
  String get actionUndo => 'Cofnij';

  @override
  String get actionSwap => 'Zamień';

  @override
  String get daily => 'Codziennie';

  @override
  String get weekly => 'Co tydzień';

  @override
  String get monthly => 'Co miesiąc';

  @override
  String get yearly => 'Co rok';

  @override
  String get unexpectedError => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get loadingExercises => 'Ładowanie ćwiczeń...';

  @override
  String get noPlansYet => 'Brak planów';

  @override
  String get noMatchingPlans => 'Brak pasujących planów';

  @override
  String get newPlan => 'Nowy plan';

  @override
  String get searchPlans => 'Szukaj planów...';

  @override
  String get noExercisesYet => 'Brak ćwiczeń';

  @override
  String get editPlan => 'Edytuj plan';

  @override
  String get saveSet => 'Zapisz serię';

  @override
  String get minutesLabel => 'Minuty';

  @override
  String get minutesShort => 'min';

  @override
  String get secondsLabel => 'Sekundy';

  @override
  String get distanceLabel => 'Dystans';

  @override
  String get inclinePercent => 'Nachylenie %';

  @override
  String weightWithUnit(String unit) {
    return 'Ciężar ($unit)';
  }

  @override
  String get useBodyWeight => 'Użyj masy ciała';

  @override
  String get noWeightEnteredYet => 'Nie wprowadzono jeszcze ciężaru';

  @override
  String get notesLabel => 'Notatki';

  @override
  String get swapWorkout => 'Zamień trening';

  @override
  String get addSet => 'Dodaj serię';

  @override
  String get deleteSet => 'Usuń serię';

  @override
  String get oneRepMaxEstimate => '1RM (szacunek)';

  @override
  String get valueLabel => 'Wartość';

  @override
  String amountWithUnit(String unit) {
    return 'Wartość ($unit)';
  }

  @override
  String distanceWithUnit(String unit) {
    return 'Dystans ($unit)';
  }

  @override
  String get bodyWeightLabel => 'Masa ciała';

  @override
  String bodyWeightWithUnit(String unit) {
    return 'Masa ciała ($unit)';
  }

  @override
  String get categoryHelper => 'Wybierz istniejącą kategorię lub wpisz nową.';

  @override
  String get manageCategories => 'Zarządzaj kategoriami';

  @override
  String get manageCategoriesDescription =>
      'Twórz, zmieniaj nazwy, łącz lub usuwaj kategorie';

  @override
  String get newCategory => 'Nowa kategoria';

  @override
  String get renameCategory => 'Zmień nazwę kategorii';

  @override
  String get mergeCategory => 'Połącz z inną kategorią';

  @override
  String get noCategories => 'Brak kategorii';

  @override
  String get categoryNameRequired => 'Wpisz nazwę kategorii';

  @override
  String categoryUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Używana przez $count wpisu',
      many: 'Używana przez $count wpisów',
      few: 'Używana przez $count wpisy',
      one: 'Używana przez $count wpis',
      zero: 'Nie jest używana przez żaden wpis',
    );
    return '$_temp0';
  }

  @override
  String deleteCategoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunąć tę kategorię i usunąć ją z $count wpisu?',
      many: 'Usunąć tę kategorię i usunąć ją z $count wpisów?',
      few: 'Usunąć tę kategorię i usunąć ją z $count wpisów?',
      one: 'Usunąć tę kategorię i usunąć ją z $count wpisu?',
      zero: 'Usunąć tę kategorię?',
    );
    return '$_temp0';
  }

  @override
  String get createdDate => 'Data utworzenia';

  @override
  String editSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Edytuj $count serii',
      many: 'Edytuj $count serii',
      few: 'Edytuj $count serie',
      one: 'Edytuj 1 serię',
    );
    return '$_temp0';
  }

  @override
  String get noEntriesYet => 'Brak wpisów';

  @override
  String get historyEmptyMessage =>
      'Ukończ serię lub dodaj ją ręcznie, aby rozpocząć historię.';

  @override
  String deleteSetConfirmation(String name) {
    return 'Czy na pewno chcesz usunąć $name?';
  }

  @override
  String deleteEntriesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Czy na pewno chcesz usunąć $count wpisu?',
      many: 'Czy na pewno chcesz usunąć $count wpisów?',
      few: 'Czy na pewno chcesz usunąć $count wpisy?',
      one: 'Czy na pewno chcesz usunąć 1 wpis?',
    );
    return '$_temp0';
  }

  @override
  String get searchHistory => 'Szukaj w historii...';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeLight => 'Jasny';

  @override
  String get pureBlackAmoled => 'Czysta czerń (AMOLED)';

  @override
  String get showImages => 'Pokaż obrazy';

  @override
  String get peekGraph => 'Podgląd wykresu';

  @override
  String get inputStyleLine => 'Linia';

  @override
  String get inputStyleOutlined => 'Obrys';

  @override
  String get inputStyleFilled => 'Wypełnione';

  @override
  String get inputStyle => 'Styl pól';

  @override
  String get appearance => 'Wygląd';

  @override
  String get automaticBackupsEnabled => 'Automatyczne kopie zapasowe włączone';

  @override
  String get automaticBackup => 'Automatyczna kopia zapasowa';

  @override
  String get appPermissions => 'Uprawnienia aplikacji';

  @override
  String get shareDatabase => 'Udostępnij bazę danych';

  @override
  String get dataManagement => 'Zarządzanie danymi';

  @override
  String get strengthUnit => 'Jednostka siły';

  @override
  String get lastEntry => 'Ostatni wpis';

  @override
  String get cardioUnit => 'Jednostka cardio';

  @override
  String longDateFormat(String format) {
    return 'Długi format daty ($format)';
  }

  @override
  String get formats => 'Formaty';

  @override
  String get setsPerExerciseMax => 'Serie na ćwiczenie (maks.: 20)';

  @override
  String get countLabel => 'Liczba';

  @override
  String get ratioLabel => 'Stosunek';

  @override
  String get reorder => 'Zmień kolejność';

  @override
  String get none => 'Brak';

  @override
  String get monday => 'Poniedziałek';

  @override
  String get examplePlanExercises =>
      'Wyciskanie na ławce, Przysiad, Martwy ciąg';

  @override
  String get tabs => 'Karty';

  @override
  String get swipeBetweenTabs => 'Przesuwaj między kartami';

  @override
  String get vibrate => 'Wibracje';

  @override
  String get enableSound => 'Włącz dźwięk';

  @override
  String get keepScreenOn => 'Nie wyłączaj ekranu';

  @override
  String get keepRinging => 'Ciągłe dzwonienie';

  @override
  String get alarmSound => 'Dźwięk alarmu';

  @override
  String get top => 'Góra';

  @override
  String get bottom => 'Dół';

  @override
  String get removeCustomTimer =>
      'Usuń niestandardowy minutnik (użyj domyślnego globalnego)';

  @override
  String get timers => 'Minutniki';

  @override
  String get timerSettings => 'Ustawienia minutnika';

  @override
  String get groupHistory => 'Grupuj historię';

  @override
  String get showUnits => 'Pokaż jednostki';

  @override
  String get showBodyWeight => 'Pokaż masę ciała';

  @override
  String get showCategories => 'Pokaż kategorie';

  @override
  String get showNotes => 'Pokaż notatki';

  @override
  String get durationEstimation => 'Szacowanie czasu trwania';

  @override
  String get showGraphLimit => 'Pokaż limit wykresu';

  @override
  String get defaultGraphMetric => 'Domyślna metryka wykresu';

  @override
  String get bestWeight => 'Największy ciężar';

  @override
  String get bestReps => 'Najwięcej powtórzeń';

  @override
  String get oneRepMax => '1RM';

  @override
  String get volume => 'Objętość';

  @override
  String get paceCardio => 'Tempo (cardio)';

  @override
  String get distanceCardio => 'Dystans (cardio)';

  @override
  String get defaultGraphPeriod => 'Domyślny okres wykresu';

  @override
  String get defaultGraphLimit => 'Domyślny limit wykresu';

  @override
  String get workouts => 'Treningi';

  @override
  String get actionStop => 'Zatrzymaj';

  @override
  String get timerFinishedToast => 'Minutnik zakończony!';

  @override
  String get stopTimer => 'Zatrzymaj minutnik';

  @override
  String get actionPause => 'Wstrzymaj';

  @override
  String get startStopwatch => 'Uruchom stoper';

  @override
  String get actionStart => 'Start';

  @override
  String get actionRestart => 'Uruchom ponownie';

  @override
  String get addOneMinute => '+1 minuta';

  @override
  String get addOneMinuteNotification => 'Dodaj 1 min';

  @override
  String get restTimer => 'Minutnik odpoczynku';

  @override
  String get timerUp => 'Czas minął';

  @override
  String get openNotification => 'Otwórz powiadomienie';

  @override
  String get timerChannelName => 'Kanał minutnika';

  @override
  String get timerChannelDescription => 'Bieżący postęp minutników odpoczynku.';

  @override
  String get timerFinishedChannelName => 'Kanał zakończonego minutnika';

  @override
  String get timerFinishedChannelDescription =>
      'Odtwarza alarm po zakończeniu minutnika odpoczynku.';

  @override
  String get timerFinished => 'Minutnik zakończony';

  @override
  String get batteryOptimizationRequestUnavailable =>
      'Żądania ignorowania optymalizacji baterii są wyłączone na Twoim urządzeniu.';

  @override
  String get exactAlarmRequestUnavailable =>
      'Żądanie SCHEDULE_EXACT_ALARM zostało odrzucone na Twoim urządzeniu';

  @override
  String get databaseMigrationFailureDescription =>
      'Coś poszło nie tak podczas tworzenia lub aktualizowania bazy danych. Zwykle można to naprawić, usuwając i ponownie tworząc rekordy.';

  @override
  String get curveSmoothness => 'Gładkość krzywych';

  @override
  String get actionBack => 'Wstecz';

  @override
  String get atLeastOneTab => 'Potrzebujesz co najmniej jednej karty';

  @override
  String get invalidTabSettings => 'Nieprawidłowe ustawienia kart.';

  @override
  String get noSettingsFound => 'Nie znaleziono ustawień';

  @override
  String nothingMatchesSearch(String query) {
    return 'Brak wyników dla „$query”.';
  }

  @override
  String get appearanceDescription => 'Motyw, kolory i wygląd interfejsu';

  @override
  String get dataManagementDescription =>
      'Importuj, eksportuj i zarządzaj danymi treningowymi';

  @override
  String get formatsDescription => 'Formatowanie dat, liczb i jednostek';

  @override
  String get plansSettingsDescription =>
      'Domyślne ustawienia i zachowanie planów treningowych';

  @override
  String get tabsDescription => 'Wybierz i uporządkuj główne karty nawigacji';

  @override
  String get timersDescription =>
      'Czas, dźwięk i zachowanie minutników odpoczynku';

  @override
  String get workoutsDescription =>
      'Śledzenie ćwiczeń i preferencje treningowe';

  @override
  String get completeSetForChart =>
      'Ukończ serię tego ćwiczenia, aby utworzyć wykres.';

  @override
  String get dateRange => 'Zakres dat';

  @override
  String get stopDate => 'Data końcowa';

  @override
  String get dataPoints => 'Punkty danych';

  @override
  String get completeSetsForProgress =>
      'Ukończ kilka serii, aby utworzyć wykres postępu.';

  @override
  String get relativeStrength => 'Siła względna';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wybrano $count',
      many: 'Wybrano $count',
      few: 'Wybrano $count',
      one: 'Wybrano 1',
    );
    return '$_temp0';
  }

  @override
  String get completeSetsForHistory =>
      'Ukończ kilka serii, aby zobaczyć tutaj historię tego ćwiczenia.';

  @override
  String get completeSetForFirstGraph =>
      'Ukończ serię, aby utworzyć pierwszy wykres ćwiczenia.';

  @override
  String nothingMatchesGraphSearch(String query) {
    return 'Brak wyników dla „$query”. Możesz utworzyć to jako nowe ćwiczenie.';
  }

  @override
  String addNamed(String name) {
    return 'Dodaj „$name”';
  }

  @override
  String deleteGraphRecordsConfirmation(int count) {
    return 'Spowoduje to usunięcie $count rekordów. Czy na pewno?';
  }

  @override
  String shareWorkout(String summary) {
    return 'Właśnie zrobiłem $summary';
  }

  @override
  String get updateConflict => 'Konflikt aktualizacji';

  @override
  String updateConflictDescription(int count) {
    return 'Nowa nazwa już istnieje dla $count rekordów. Czy na pewno chcesz kontynuować?';
  }

  @override
  String get unitsConflict => 'Konflikt jednostek';

  @override
  String unitsConflictDescription(String unit) {
    return 'Nie wszystkie rekordy mają tę samą jednostkę. Wszystkie jednostki zostaną przeliczone na $unit. Czy na pewno chcesz kontynuować?';
  }

  @override
  String get durationLabel => 'Czas trwania';

  @override
  String get inclineLabel => 'Nachylenie';

  @override
  String get paceDistanceTime => 'Tempo (dystans / czas)';

  @override
  String get adjustedPace => 'Skorygowane tempo';

  @override
  String get addPlan => 'Dodaj plan';

  @override
  String get planDetails => 'Szczegóły planu';

  @override
  String get exercisesLabel => 'Ćwiczenia';

  @override
  String get addExerciseToPlan => 'Dodaj ćwiczenie do tego planu.';

  @override
  String nothingMatchesExerciseSearch(String query) {
    return 'Brak wyników dla „$query”. Możesz dodać to jako nowe ćwiczenie.';
  }

  @override
  String get selectDays => 'Wybierz dni';

  @override
  String get selectExercises => 'Wybierz ćwiczenia';

  @override
  String get todayLabel => 'Dzisiaj';

  @override
  String get setDetails => 'Szczegóły serii';

  @override
  String get themeLabel => 'Motyw';

  @override
  String get pureBlackAmoledDescription =>
      'Używaj czystej czerni na ekranach AMOLED';

  @override
  String get systemColorScheme => 'Systemowy schemat kolorów';

  @override
  String get systemColorSchemeDescription =>
      'Używaj w aplikacji głównego koloru urządzenia';

  @override
  String get showImagesDescription =>
      'Wybieraj i wyświetlaj obrazy na stronie historii';

  @override
  String get showGlobalProgress => 'Pokaż postęp ogólny';

  @override
  String get showGlobalProgressDescription =>
      'Dodaj do wykresu wpis pokazujący postęp według kategorii';

  @override
  String get peekGraphDescription =>
      'Pokaż pierwszy wykres liniowy na stronie wykresów';

  @override
  String get inputStyleDescription => 'Wygląd pól tekstowych';

  @override
  String get automaticBackupNotificationBody =>
      'Alpha będzie codziennie automatycznie tworzyć kopię zapasową danych i obrazów w wybranym folderze.';

  @override
  String get backupSettingsChannel => 'Ustawienia kopii zapasowej';

  @override
  String get backupSettingsChannelDescription =>
      'Powiadomienia objaśniające automatyczne kopie zapasowe';

  @override
  String get backupChannelName => 'Kanał kopii zapasowej';

  @override
  String get backupChannelDescription =>
      'Automatyczne kopie zapasowe danych i obrazów Alpha';

  @override
  String get backupCompletedTitle =>
      'Utworzono kopię zapasową danych i obrazów';

  @override
  String get backupFailurePathNotSet =>
      'Kopia zapasowa nie powiodła się: nie ustawiono lokalizacji. Automatyczne kopie zapasowe wyłączone.';

  @override
  String get backupFailureDirectoryUnavailable =>
      'Kopia zapasowa nie powiodła się: brak dostępu do folderu kopii zapasowej. Automatyczne kopie zapasowe wyłączone.';

  @override
  String get backupFailureCreateFile =>
      'Kopia zapasowa nie powiodła się: nie udało się utworzyć pliku. Automatyczne kopie zapasowe wyłączone.';

  @override
  String get backupFailureAppFilesUnavailable =>
      'Kopia zapasowa nie powiodła się: brak dostępu do folderu plików aplikacji. Automatyczne kopie zapasowe wyłączone.';

  @override
  String get backupFailureDatabaseMissing =>
      'Kopia zapasowa nie powiodła się: nie znaleziono pliku bazy danych. Automatyczne kopie zapasowe wyłączone.';

  @override
  String get backupFailureOutputUnavailable =>
      'Kopia zapasowa nie powiodła się: nie udało się otworzyć strumienia wyjściowego. Automatyczne kopie zapasowe wyłączone.';

  @override
  String get backupFailureUnknown =>
      'Kopia zapasowa nie powiodła się. Automatyczne kopie zapasowe wyłączone.';

  @override
  String get appPermissionsDescription =>
      'Sprawdź dostęp wymagany przez włączone funkcje';

  @override
  String get longDateFormatDescription =>
      'Używany tam, gdzie jest dużo miejsca';

  @override
  String shortDateFormat(String example) {
    return 'Krótki format daty ($example)';
  }

  @override
  String get shortDateFormatDescription =>
      'Do miejsc z małą ilością miejsca (linie wykresów)';

  @override
  String get warmupSetsDescription =>
      'Serie rozgrzewkowe nie uruchamiają minutników odpoczynku';

  @override
  String get setsPerExerciseDescription => 'Domyślna liczba ćwiczeń w planie';

  @override
  String get planTrailingDisplay => 'Informacja po prawej stronie planu';

  @override
  String get planTrailingDisplayDescription =>
      'Zawartość po prawej stronie listy w widokach Plany i Plan';

  @override
  String get restTimersDescription => 'Alarm uruchamiany po ukończeniu serii';

  @override
  String get vibrateDescription => 'Czy minutniki odpoczynku mają wibrować?';

  @override
  String get enableSoundDescription =>
      'Czy minutniki odpoczynku mają odtwarzać dźwięk?';

  @override
  String get keepScreenOnDescription =>
      'Nie wyłączaj ekranu podczas działania minutników odpoczynku';

  @override
  String get keepRingingDescription =>
      'Powtarzaj dźwięk alarmu i wibracje, aż go anulujesz';

  @override
  String get restDurationDescription =>
      'Po jakim czasie mają uruchamiać się alarmy odpoczynku?';

  @override
  String get globalDefault => 'Domyślne globalne';

  @override
  String get alarmSoundDescription =>
      'Muzyka odtwarzana po zakończeniu minutnika odpoczynku';

  @override
  String get progressBarPosition => 'Położenie paska postępu';

  @override
  String get progressBarPositionDescription =>
      'Gdzie ma być umieszczony pasek postępu minutników odpoczynku?';

  @override
  String get perExerciseRestTimes => 'Czas odpoczynku dla ćwiczeń';

  @override
  String get perExerciseRestTimesDescription =>
      'Te ćwiczenia mają niestandardowy czas odpoczynku';

  @override
  String get audioFeaturesUnavailable => 'Funkcje audio są niedostępne';

  @override
  String get groupHistoryDescription => 'Łącz wpisy historii według dnia';

  @override
  String get showUnitsDescription =>
      'Pokaż km/mi oraz kg/lb na wykresach, w historii i planach';

  @override
  String get showBodyWeightDescription =>
      'Włącz lub wyłącz śledzenie masy ciała';

  @override
  String get showCategoriesDescription =>
      'Włącz lub wyłącz kategorie treningowe';

  @override
  String get showNotesDescription =>
      'Zapisuj szczegóły ćwiczenia w polu tekstowym';

  @override
  String get positiveReinforcement => 'Pozytywne wzmocnienie';

  @override
  String get positiveNotificationsDescription =>
      'Wyświetlaj motywujące wiadomości po ustanowieniu nowego rekordu';

  @override
  String get positiveMessagesEnabled =>
      'Pozytywne wiadomości wyglądają teraz tak!';

  @override
  String get recordEncouragement01 => 'Świetna robota! Jesteś niesamowity.';

  @override
  String get recordEncouragement02 =>
      'Dobra robota, królu! Twój postęp inspiruje.';

  @override
  String get recordEncouragement03 => 'Klękam...';

  @override
  String get recordEncouragement04 => 'Co to? Nowy rekord!';

  @override
  String get recordEncouragement05 => 'Niesamowite! Inspirujesz.';

  @override
  String get recordEncouragement06 => 'Wow. Pięknie.';

  @override
  String get recordEncouragement07 => 'Ale rośnie siła, co?';

  @override
  String get recordEncouragement08 => 'Tak. Robisz się naprawdę duży.';

  @override
  String get recordEncouragement09 => 'Niesamowite. Rewelacja.';

  @override
  String get recordEncouragement10 => 'Arnie byłby dumny.';

  @override
  String get recordEncouragement11 => 'Ronnie C patrzy na Ciebie z radością.';

  @override
  String get recordEncouragement12 => 'TAK! LEKKI CIĘŻAR, DZIECIAKU!!!!!!!';

  @override
  String get recordEncouragement13 =>
      'Czy to nowy rekord? Wiedziałem, że dasz radę.';

  @override
  String get recordEncouragement14 => 'Świetna robota! Jestem z Ciebie dumny.';

  @override
  String get recordEncouragement15 => 'Tak jest! Lekki ciężar!';

  @override
  String get recordEncouragement16 => 'Tak trzymaj! Świetny postęp.';

  @override
  String get recordEncouragement17 => 'Idzie Ci naprawdę świetnie.';

  @override
  String get recordEncouragement18 => 'To mój chłopak!';

  @override
  String get recordEncouragement19 => 'Tak trzymaj.';

  @override
  String get recordEncouragement20 => 'Robisz się naprawdę silny.';

  @override
  String get recordEncouragement21 => 'Potężnie.';

  @override
  String get recordEncouragement22 => 'Ale moc!';

  @override
  String get recordEncouragement23 => 'Jestem z Ciebie dumny.';

  @override
  String get recordEncouragement24 => 'Tak trzymaj, świetna robota.';

  @override
  String get recordEncouragement25 =>
      'Głowa do góry! Właśnie ustanowiłeś nowy rekord.';

  @override
  String get recordEncouragement26 =>
      'Nowy rekord! Poszedłeś dalej niż kiedykolwiek!';

  @override
  String get recordEncouragement27 => 'Tak! To rekord.';

  @override
  String get recordEncouragement28 => 'Wow! Nowy rekord!';

  @override
  String get recordEncouragement29 => 'Naprawdę świetnie.';

  @override
  String get durationEstimationDescription =>
      'Spróbuj przewidzieć czas trwania cardio';

  @override
  String get showGraphXAxisToggle => 'Pokaż przełącznik osi X wykresu';

  @override
  String get showGraphXAxisToggleDescription =>
      'Pokaż na wykresach przełącznik osi X opartej na czasie';

  @override
  String get showGraphLimitDescription => 'Pokaż suwak limitu na wykresach';

  @override
  String get defaultTimeBasedXAxis => 'Domyślnie oś X oparta na czasie';

  @override
  String get defaultTimeBasedXAxisDescription =>
      'Domyślnie używaj na wykresach osi X opartej na czasie';

  @override
  String get createFirstTrainingPlan =>
      'Utwórz pierwszy plan treningowy, aby zacząć.';

  @override
  String nothingMatchesPlanSearch(String query) {
    return 'Brak wyników dla „$query”. Możesz utworzyć to jako nowy plan.';
  }

  @override
  String get createPlan => 'Utwórz plan';

  @override
  String createNamedPlan(String name) {
    return 'Utwórz „$name”';
  }

  @override
  String setNumber(int number) {
    return 'Seria $number';
  }

  @override
  String get tabStart => 'Pulpit';

  @override
  String get tabTraining => 'Trening';

  @override
  String get tabExercises => 'Ćwiczenia';

  @override
  String get tabProfile => 'Profil';

  @override
  String get calendarTitle => 'Kalendarz';

  @override
  String dayStreak(int count) {
    return '$count dni z rzędu';
  }

  @override
  String weekStreak(int count) {
    return '$count tygodni z rzędu';
  }

  @override
  String get thisWeek => 'Ten tydzień';

  @override
  String get bodyWeightChart => 'Masa ciała';

  @override
  String get strengthChart => 'Siła';

  @override
  String get weeklyVolumeChart => 'Tygodniowa objętość';

  @override
  String get noChartData => 'Za mało danych';

  @override
  String get newTemplate => 'Nowy szablon';

  @override
  String get templateLimit => 'Możesz zapisać do 7 szablonów.';

  @override
  String get templatesEmpty => 'Ten szablon nie ma jeszcze ćwiczeń.';

  @override
  String get allMuscles => 'Wszystkie';

  @override
  String get noHistory => 'Brak historii';

  @override
  String bestOneRepMax(String value) {
    return 'Szacowane 1RM $value kg';
  }

  @override
  String bestLoad(String value) {
    return 'Największy ciężar $value kg';
  }

  @override
  String get profileName => 'Imię';

  @override
  String get heightCm => 'Wzrost (cm)';

  @override
  String get ageOptional => 'Wiek (opcjonalnie)';

  @override
  String get goals => 'Cele';

  @override
  String get bodyData => 'Dane ciała';

  @override
  String get addBodyWeight => 'Dodaj wagę';

  @override
  String get weightKg => 'Waga (kg)';

  @override
  String get aiCoaching => 'Coaching AI';

  @override
  String get apiKey => 'Klucz API';

  @override
  String get apiKeyStoredLocally =>
      'Zapisany tylko na tym telefonie. Jeszcze nieużywany.';

  @override
  String get profileSaved => 'Profil zapisany';

  @override
  String get noTrainingThisDay => 'Brak wpisu tego dnia';

  @override
  String targetSets(int count) {
    return '$count serie';
  }

  @override
  String repRangeLabel(String range) {
    return '$range powt.';
  }

  @override
  String get repMinLabel => 'Powtórzenia od';

  @override
  String get repMaxLabel => 'Powtórzenia do';

  @override
  String get exerciseDatabaseCreditTitle => 'Biblioteka ćwiczeń';

  @override
  String get exerciseDatabaseCreditBody =>
      'Nazwy z free-exercise-db autorstwa yuhonas, Unlicense (domena publiczna). Alpha dodała nazwy i aliasy.';

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
  String get finishWorkoutAsk => 'Zakończyć ten trening?';

  @override
  String get finishWorkoutBody =>
      'Sesja zostanie zapisana, a szablon pozostanie bez zmian.';

  @override
  String get discardWorkoutAsk => 'Odrzucić ten trening?';

  @override
  String get discardWorkoutBody =>
      'Zapisane serie z tej sesji zostaną usunięte.';

  @override
  String get noRest => 'Bez przerwy';

  @override
  String get restWheelTitle => 'Przerwa';

  @override
  String get deleteTemplateAsk => 'Usunąć ten szablon?';

  @override
  String deleteTemplateBody(String name) {
    return 'Usunąć „$name”? Zapisane treningi zostaną.';
  }

  @override
  String get warmupAction => 'Rozgrzewka';

  @override
  String get warmupMark => 'W';

  @override
  String get confirmAddExercise => 'Dodaj ćwiczenie';

  @override
  String get tabOverview => 'Przegląd';

  @override
  String get tabHistory => 'Historia';

  @override
  String get tabHowTo => 'Wykonanie';

  @override
  String get primaryMuscleLabel => 'Główny mięsień';

  @override
  String get secondaryMuscleLabel => 'Mięśnie pomocnicze';

  @override
  String get equipmentLabel => 'Sprzęt';

  @override
  String get heaviestWeight => 'Największy ciężar';

  @override
  String get estimatedOneRm => 'Szacowane 1RM';

  @override
  String get volumeChart => 'Objętość treningu';

  @override
  String get recordsTitle => 'Rekordy';

  @override
  String get weekGoal => 'Cel tygodnia';

  @override
  String weekGoalProgress(int done, int goal) {
    return '$done z $goal';
  }

  @override
  String startWorkoutNamed(String name) {
    return 'Zacznij trening · $name';
  }

  @override
  String get musclesThisWeek => 'Mięśnie w tym tygodniu';

  @override
  String get progressHeading => 'Postęp';

  @override
  String get lastEightWeeks => 'Ostatnie osiem tygodni';

  @override
  String get chooseProfile => 'Wybierz profil';

  @override
  String get createProfileAction => 'Utwórz profil';

  @override
  String get plateCalculator => 'Kalkulator obciążeń';

  @override
  String get barbellCalc => 'Sztanga';

  @override
  String get dumbbellCalc => 'Hantel';

  @override
  String get extraWeight => 'Dodatkowy ciężar';

  @override
  String get barWeightLabel => 'Ciężar gryfu';

  @override
  String get plateSetLabel => 'Talery na stronę';

  @override
  String get dumbbellHandleLabel => 'Uchwyt';

  @override
  String get dumbbellEachLabel => 'Na hantel';

  @override
  String get chooseGym => 'Wybierz siłownię';

  @override
  String get gymsTitle => 'Siłownie';

  @override
  String get newGym => 'Nowa siłownia';

  @override
  String get progressionHelp => 'Pomoc w progresji';

  @override
  String progressionAsk(String name, String weight, int reps) {
    return '$name: następnym razem $weight kg i zacząć od $reps powtórzeń?';
  }

  @override
  String get actionAccept => 'Przyjmij';

  @override
  String get actionReject => 'Odrzuć';

  @override
  String get importExportTitle => 'Importuj i eksportuj dane';

  @override
  String get importWorkouts => 'Importuj treningi';

  @override
  String get importMeasurements => 'Importuj pomiary';

  @override
  String get exportAlphaData => 'Eksportuj dane Alpha';

  @override
  String get importPreviewTitle => 'Podgląd importu';

  @override
  String importSummary(int workouts, int exercises) {
    return '$workouts treningów, $exercises ćwiczeń';
  }

  @override
  String get templatesDetected => 'Wykryte szablony';

  @override
  String get renameLabel => 'Zmień nazwę';

  @override
  String get mapExercise => 'Przypisz ćwiczenie';

  @override
  String get checkForUpdates => 'Sprawdź aktualizacje';

  @override
  String get upToDate => 'Masz aktualną wersję';

  @override
  String get updateCheckFailed => 'Sprawdzenie aktualizacji nie powiodło się';

  @override
  String updateVersionAvailable(String version) {
    return 'Wersja $version dostępna';
  }

  @override
  String get downloadInBrowser => 'Pobierz w przeglądarce';

  @override
  String get installPermissionTitle => 'Zezwól na instalację';

  @override
  String get installPermissionBody =>
      'Android potrzebuje zgody, aby instalować aktualizacje Alpha. Pobieranie ruszy dalej, gdy wrócisz.';

  @override
  String get openInstallSettings => 'Otwórz ustawienie';

  @override
  String get tapToInstall => 'Dotknij, aby zainstalować';

  @override
  String get downloadingUpdate => 'Pobieranie aktualizacji';

  @override
  String updateDownloadProgress(String received, String total) {
    return '$received z $total MB';
  }

  @override
  String get updateInstallFailed => 'Nie udało się zainstalować aktualizacji';

  @override
  String get downloadFailed => 'Pobieranie nie powiodło się';

  @override
  String get updateFailureNetwork => 'Brak połączenia.';

  @override
  String get updateFailureTimeout => 'Przekroczono czas.';

  @override
  String updateFailureHttp(String status) {
    return 'Serwer odpowiedział kodem $status.';
  }

  @override
  String get updateFailureEmpty => 'Plik jest pusty.';

  @override
  String get updateFailureSize => 'Plik jest niekompletny.';

  @override
  String get updateFailurePermission => 'Instalacja nie jest dozwolona.';

  @override
  String get updateFailureGeneric => 'To się nie udało.';

  @override
  String get errorDetails => 'Szczegóły';

  @override
  String get createOwnExercise => 'Utwórz własne ćwiczenie';

  @override
  String get customExerciseMuscleRequired => 'Wybierz główny mięsień.';

  @override
  String get licensesTitle => 'Licencje';

  @override
  String get flexifyMitNotice =>
      'Flexify jest publikowany na licencji MIT. Copyright Brandon Dick.';

  @override
  String get exerciseDbNotice =>
      'Każde ćwiczenie podaje własne źródło i licencję.';

  @override
  String get sourceLabel => 'Źródło';

  @override
  String get tipsLabel => 'Wskazówki';

  @override
  String get imageSourceLabel => 'Źródło obrazu';

  @override
  String get imageLicenseLabel => 'Licencja obrazu';

  @override
  String get muscleUpperChest => 'Górna klatka';

  @override
  String get muscleFrontShoulder => 'Przedni bark';

  @override
  String get muscleSideShoulder => 'Boczny bark';

  @override
  String get muscleRearShoulder => 'Tylny bark';

  @override
  String get muscleLatissimus => 'Najszerszy grzbietu';

  @override
  String get muscleUpperBack => 'Górne plecy';

  @override
  String get muscleTrapez => 'Kaptury';

  @override
  String get muscleLowerBack => 'Dolne plecy';

  @override
  String get muscleForearms => 'Przedramiona';

  @override
  String get muscleRectus => 'Prosty brzucha';

  @override
  String get muscleObliques => 'Skośne brzucha';

  @override
  String get muscleQuadriceps => 'Czworogłowy';

  @override
  String get muscleAdductors => 'Przywodziciele';

  @override
  String get muscleAbductors => 'Odwodziciele';

  @override
  String get muscleHipFlexors => 'Zginacze biodra';

  @override
  String get alternativesLabel => 'Zamienniki';

  @override
  String get mechanicLabel => 'Mechanika';

  @override
  String get aiCoachTitle => 'Trener SI';

  @override
  String get aiProviderLabel => 'Dostawca';

  @override
  String get aiOffNotice =>
      'Trener pozostaje wyłączony, dopóki nie zapiszesz własnego klucza.';

  @override
  String get coachHint => 'Zapytaj trenera';

  @override
  String get voiceInput => 'Wpis głosowy';

  @override
  String voiceUnderstood(String text) {
    return 'Zrozumiano: $text';
  }

  @override
  String get speechFailed => 'Wpis głosowy nie powiódł się';

  @override
  String get confirmVoiceSet => 'Zastosować tę serię?';

  @override
  String get periodSession => 'Ten trening';

  @override
  String get muscleMapTitle => 'Mapa mięśni';

  @override
  String get frontView => 'Przód';

  @override
  String get backView => 'Tył';

  @override
  String quoteKeepGoing(int done, int goal) {
    return '$done z $goal sesji w tym tygodniu. Tak trzymaj.';
  }

  @override
  String quoteRemaining(int count) {
    return 'Zostało $count sesji w tym tygodniu.';
  }

  @override
  String get quotePullDay => 'Dzień przyciągania. Plecy i biceps czekają.';

  @override
  String get quotePushDay => 'Dzień wypychania. Klatka, barki i triceps.';

  @override
  String get quoteLegDay => 'Dzień nóg. Czworogłowe, dwugłowe i pośladki.';

  @override
  String versionAndLicenses(String version) {
    return 'Wersja $version · Licencje';
  }

  @override
  String get liveWorkoutLabel => 'Trening trwa';

  @override
  String get muscleChest => 'Klatka';

  @override
  String get muscleShoulders => 'Barki';

  @override
  String get muscleBiceps => 'Biceps ramienia';

  @override
  String get muscleTriceps => 'Triceps ramienia';

  @override
  String get muscleAbs => 'Brzuch';

  @override
  String get muscleQuads => 'Czworogłowe';

  @override
  String get muscleCalves => 'Łydki';

  @override
  String get muscleTraps => 'Kaptury';

  @override
  String get muscleBack => 'Plecy';

  @override
  String get muscleGlutes => 'Pośladki';

  @override
  String get muscleHams => 'Dwugłowe uda';

  @override
  String get weekGoalManual => 'Ustaw cel tygodnia samodzielnie';

  @override
  String get sessionsPerWeek => 'Sesje w tygodniu';

  @override
  String get gymNameHint => 'Nazwa siłowni';

  @override
  String get coachProfileNote => 'Notatka trenera';

  @override
  String get openPackageLicenses => 'Otwórz licencje pakietów';

  @override
  String get lengthUnitLabel => 'Długość ciała';

  @override
  String get centimetersShort => 'Centymetry (cm)';

  @override
  String get inchesShort => 'Cale (in)';

  @override
  String get heightInches => 'Wzrost (cale)';

  @override
  String get welcomeToAlpha => 'Witaj w Alpha';

  @override
  String get createProfileButton => 'Utwórz profil';

  @override
  String get onboardingWeightHint => 'Masa ciała, opcjonalnie';

  @override
  String get familyLabel => 'Rodzina';

  @override
  String get gripLabel => 'Chwyt';

  @override
  String get positionLabel => 'Pozycja';

  @override
  String get movementLabel => 'Ruch';

  @override
  String get unilateralLabel => 'Jednostronne';

  @override
  String get otherVariants => 'Inne warianty';

  @override
  String get sideLeft => 'Lewa';

  @override
  String get sideRight => 'Prawa';

  @override
  String get createCustomExercise => 'Utwórz ćwiczenie';

  @override
  String get editCustomExercise => 'Edytuj ćwiczenie';

  @override
  String get unassignedExercise => 'Nieprzypisane';

  @override
  String get deleteCustomExercise => 'Usuń ćwiczenie';

  @override
  String get deleteCustomExerciseBody =>
      'Usunąć to ćwiczenie? Dotychczasowe treningi zostają w historii.';

  @override
  String get customExerciseName => 'Nazwa';

  @override
  String get customExerciseFamily => 'Identyfikator rodziny';

  @override
  String get createAsCustomExercise => 'Utwórz jako własne ćwiczenie';

  @override
  String get customExerciseInvalid => 'Wybierz nazwę, mięśnie i sprzęt.';

  @override
  String get motionPress => 'Wyciskanie';

  @override
  String get motionPull => 'Przyciąganie';

  @override
  String get motionLegs => 'Nogi/biodra';

  @override
  String get motionCore => 'Tułów';

  @override
  String get motionCardio => 'Cardio';

  @override
  String get mechanicCompound => 'Złożone';

  @override
  String get mechanicIsolation => 'Izolowane';

  @override
  String get ownExerciseSource => 'Własne ćwiczenie';

  @override
  String get notSpecified => '–';

  @override
  String get resumeWorkout => 'Wznów trening';

  @override
  String get importBackupZip => 'Importuj kopię (.zip)';

  @override
  String importSetSummary(int workouts, int sets) {
    return '$workouts treningów, $sets serii';
  }

  @override
  String importDateErrorCount(int count) {
    return '$count wierszy ma datę, której nie dało się odczytać.';
  }

  @override
  String importUnmatchedNames(String names) {
    return 'Brak dopasowania: $names';
  }

  @override
  String importTemplatesSkipped(String names) {
    return 'Nieutworzone, osiągnięto limit szablonów: $names';
  }

  @override
  String importApplying(int done, int total) {
    return '$done z $total';
  }

  @override
  String get customExerciseMovementRequired => 'Wybierz ruch.';

  @override
  String get setRemoved => 'Seria usunięta';

  @override
  String get exerciseRemovedUndo => 'Ćwiczenie usunięte';

  @override
  String get exerciseSwappedUndo => 'Ćwiczenie zamienione';

  @override
  String get saveRestInTemplate => 'Zapisz też w szablonie';

  @override
  String get deleteGymTitle => 'Usunąć studio?';

  @override
  String get deleteGymAction => 'Usuń studio';

  @override
  String get exerciseAlreadyInPlan => 'Już jest w tym planie';

  @override
  String get deleteGymBody =>
      'Treningi powiązane z tym studiem zostają. Usuwane jest tylko studio.';

  @override
  String get renameGym => 'Zmień nazwę studia';

  @override
  String get cleanupImports => 'Posprzątaj wpisy z importu';

  @override
  String cleanupImportsPreview(int workouts, int templates) {
    return '$workouts zaimportowanych treningów i $templates szablonów zostanie usuniętych. Treningi wpisane ręcznie zostają.';
  }

  @override
  String get cleanupImportsEmpty => 'Nie ma czego sprzątać.';

  @override
  String get cleanupImportsDone => 'Wpisy z importu usunięte.';

  @override
  String measurementsImported(int count) {
    return '$count pomiarów zaimportowano.';
  }

  @override
  String get splitSidesToggle => 'Lewa i prawa';

  @override
  String get trainWhereTitle => 'Gdzie dziś ćwiczysz?';

  @override
  String get startTrainingAction => 'Zacznij trening';

  @override
  String lastTrainedLabel(String when) {
    return 'Ostatnio: $when';
  }

  @override
  String get trainedToday => 'dziś';

  @override
  String get trainedYesterday => 'wczoraj';

  @override
  String trainedDaysAgo(int count) {
    return '$count dni temu';
  }

  @override
  String get startWithoutStudio => 'Zacznij bez siłowni';

  @override
  String get noStudiosYet => 'Nie ma jeszcze siłowni. Dodaj albo zacznij bez.';

  @override
  String get sortExercisesTitle => 'Kolejność';

  @override
  String get sortExercisesHint => 'Przytrzymaj uchwyt i przeciągnij.';

  @override
  String get feedbackTitle => 'Opinia';

  @override
  String get feedbackSettings => 'Wyślij opinię';

  @override
  String get feedbackCategory => 'Kategoria';

  @override
  String get feedbackBug => 'Błąd';

  @override
  String get feedbackImprovement => 'Ulepszenie';

  @override
  String get feedbackTranslation => 'Tłumaczenie';

  @override
  String get feedbackMessageHint => 'Co powinniśmy wiedzieć?';

  @override
  String get feedbackDictate => 'Dyktuj';

  @override
  String get feedbackAttachAudio => 'Dołącz nagranie';

  @override
  String get feedbackRemoveAudio => 'Usuń nagranie';

  @override
  String get feedbackSend => 'Wyślij';

  @override
  String get feedbackMailUnavailable => 'Brak aplikacji pocztowej.';

  @override
  String get feedbackStopRecording => 'Zatrzymaj nagrywanie';

  @override
  String get otherVariant => 'Inny wariant';

  @override
  String get firstStudioTitle =>
      'Jak nazywa się siłownia, na której teraz ćwiczysz?';

  @override
  String get renameProfile => 'Zmień nazwę';

  @override
  String get deleteProfile => 'Usuń profil';

  @override
  String get deleteProfileTitle => 'Usunąć ten profil?';

  @override
  String deleteProfileBody(String name) {
    return 'Wpisz „$name”, aby usunąć ten profil i jego dane.';
  }

  @override
  String get deleteProfileBlockedActive =>
      'Aktywnego profilu nie można usunąć.';

  @override
  String get deleteProfileBlockedLast => 'Ostatniego profilu nie można usunąć.';

  @override
  String get profileNameEmpty => 'Nazwa nie może być pusta.';

  @override
  String get profileNameDuplicate => 'Taka nazwa już istnieje.';

  @override
  String get finishBeforeSwitch =>
      'Zakończ albo odrzuć trening, zanim zmienisz profil.';

  @override
  String get switchFinishWorkout => 'Zakończ trening';

  @override
  String get switchDiscardWorkout => 'Odrzuć trening';

  @override
  String get groupLegs => 'Nogi';

  @override
  String get gearBarbell => 'Sztanga';

  @override
  String get gearDumbbell => 'Hantel';

  @override
  String get gearEzBar => 'Gryf łamany';

  @override
  String get gearCable => 'Wyciąg';

  @override
  String get gearMachine => 'Maszyna';

  @override
  String get gearSmith => 'Maszyna Smitha';

  @override
  String get gearBodyweight => 'Ciężar ciała';

  @override
  String get gearKettlebell => 'Kettlebell';

  @override
  String get gearBand => 'Guma oporowa';

  @override
  String get gearCardio => 'Sprzęt cardio';

  @override
  String get gearPlate => 'Obciążenie';

  @override
  String get gearAbWheel => 'Kółko do brzucha';

  @override
  String get gearBattleRope => 'Lina treningowa';

  @override
  String get gearSled => 'Sanie';

  @override
  String get gearJumpRope => 'Skakanka';

  @override
  String get positionFlat => 'Poziomo';

  @override
  String get positionIncline => 'Skośnie';

  @override
  String get positionDecline => 'Ujemnie';

  @override
  String get positionSeated => 'Siedząc';

  @override
  String get positionStanding => 'Stojąc';

  @override
  String get positionLying => 'Leżąc';

  @override
  String get positionBent => 'W opadzie';

  @override
  String get gripClose => 'Wąski chwyt';

  @override
  String get gripWide => 'Szeroki chwyt';

  @override
  String get gripOverhand => 'Nachwyt';

  @override
  String get gripUnderhand => 'Podchwyt';

  @override
  String get gripNeutral => 'Chwyt neutralny';
}
