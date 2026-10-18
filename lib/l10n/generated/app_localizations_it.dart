// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Alpha';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageDescription => 'Scegli la lingua usata da Alpha';

  @override
  String get languageSystemDefault => 'Predefinita di sistema';

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
  String get navHistory => 'Cronologia';

  @override
  String get navPlans => 'Schede';

  @override
  String get navGraphs => 'Grafici';

  @override
  String get navTimer => 'Timer';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get errorLabel => 'Errore';

  @override
  String get tabContentError =>
      'Impossibile visualizzare il contenuto della scheda.';

  @override
  String get cannotHideAllTabs => 'Non puoi nascondere tutte le schede!';

  @override
  String removeTabQuestion(String tab) {
    return 'Rimuovere la scheda $tab?';
  }

  @override
  String get restoreTabFromSettings =>
      'Potrai aggiungerla di nuovo in seguito dalle impostazioni.';

  @override
  String removedTab(String tab) {
    return '$tab rimossa';
  }

  @override
  String newVersion(String version) {
    return 'Nuova versione $version';
  }

  @override
  String get changes => 'Novità';

  @override
  String get searchHint => 'Cerca...';

  @override
  String get deleteSelected => 'Elimina selezionati';

  @override
  String get confirmDelete => 'Conferma eliminazione';

  @override
  String deleteRecordsConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Vuoi davvero eliminare $count record? Questa azione non può essere annullata.',
      one:
          'Vuoi davvero eliminare 1 record? Questa azione non può essere annullata.',
    );
    return '$_temp0';
  }

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionDiscard => 'Scarta';

  @override
  String get unsavedChanges => 'Modifiche non salvate';

  @override
  String get discardUnsavedChanges => 'Scartare le modifiche non salvate?';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionRemove => 'Rimuovi';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionShare => 'Condividi';

  @override
  String get clearSelection => 'Deseleziona tutto';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get showMenu => 'Mostra menu';

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get weightLabel => 'Peso';

  @override
  String get filter => 'Filtra';

  @override
  String get filters => 'Filtri';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get repsLabel => 'Ripetizioni';

  @override
  String get repsFilter => 'Filtro ripetizioni';

  @override
  String get weightFilter => 'Filtro peso';

  @override
  String get greaterThan => 'Maggiore di';

  @override
  String get lessThan => 'Minore di';

  @override
  String get startDate => 'Data di inizio';

  @override
  String get endDate => 'Data di fine';

  @override
  String get actionClear => 'Cancella';

  @override
  String get actionOk => 'OK';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get sortBy => 'Ordina per';

  @override
  String get dateNewest => 'Data (più recenti)';

  @override
  String get dateOldest => 'Data (più vecchie)';

  @override
  String get nameLabel => 'Nome';

  @override
  String get missingPermissions => 'Autorizzazioni mancanti';

  @override
  String get restTimersPermissionsMissing =>
      'I timer di recupero sono attivi, ma mancano alcune autorizzazioni.';

  @override
  String get restTimersPermissionsOptional =>
      'Se disattivi i timer di recupero, queste autorizzazioni non sono necessarie.';

  @override
  String get restTimers => 'Timer di recupero';

  @override
  String get disableBatteryOptimizations => 'Disattiva ottimizzazione batteria';

  @override
  String get batteryOptimizationWarning =>
      'Il timer potrebbe interrompersi se l’ottimizzazione della batteria resta attiva.';

  @override
  String get scheduleExactAlarm => 'Programma allarme esatto';

  @override
  String get exactAlarmWarning =>
      'Gli allarmi non possono essere precisi se questa opzione è disattivata.';

  @override
  String get postNotifications => 'Mostra notifiche';

  @override
  String get notificationBarDescription =>
      'L’avanzamento del timer viene mostrato nella barra delle notifiche';

  @override
  String get invalidPermissions => 'Autorizzazioni non valide';

  @override
  String get insufficientTimerPermissionsConfirmation =>
      'I timer di recupero sono attivi senza autorizzazioni sufficienti. Vuoi continuare?';

  @override
  String get actionConfirm => 'Conferma';

  @override
  String get appAccess => 'Accesso app';

  @override
  String get appAccessDescription => 'Necessario per timer e notifiche attivi.';

  @override
  String get notifications => 'Notifiche';

  @override
  String get timerProgressAndRestAlerts =>
      'Avanzamento timer e avvisi di recupero';

  @override
  String get enabledNotificationsDescription => 'Notifiche che hai attivato';

  @override
  String get backgroundActivity => 'Attività in background';

  @override
  String get backgroundActivityDescription =>
      'Mantiene affidabili i timer in background';

  @override
  String get exactAlarms => 'Allarmi esatti';

  @override
  String get exactAlarmsDescription =>
      'Avvisa esattamente quando termina un timer di recupero';

  @override
  String get noAdditionalAndroidAccessNeeded =>
      'Con le impostazioni attuali non è necessario alcun accesso Android aggiuntivo.';

  @override
  String get actionDone => 'Fatto';

  @override
  String get allowed => 'Consentito';

  @override
  String get actionAllow => 'Consenti';

  @override
  String get backupLabel => 'Backup';

  @override
  String get databaseLabel => 'Database';

  @override
  String get deleteRecords => 'Elimina record';

  @override
  String get deleteAllGraphsConfirmation =>
      'Vuoi davvero eliminare tutti i grafici? Questa azione non può essere annullata.';

  @override
  String get deleteAllPlansConfirmation =>
      'Vuoi davvero eliminare tutte le schede? Questa azione non può essere annullata.';

  @override
  String get deleteDatabaseConfirmation =>
      'Vuoi davvero eliminare il database? Questa azione non può essere annullata e cancellerà tutti i tuoi dati.';

  @override
  String get importData => 'Importa dati';

  @override
  String get exportData => 'Esporta dati';

  @override
  String get actionReport => 'Segnala';

  @override
  String get graphDataImported => 'Dati dei grafici importati correttamente!';

  @override
  String get plansImported => 'Schede importate correttamente';

  @override
  String failedToImportDatabase(String error) {
    return 'Impossibile importare il database: $error';
  }

  @override
  String get backupArchiveMissingDatabase =>
      'Il backup non contiene il database di Alpha.';

  @override
  String failedToImportGraphs(String error) {
    return 'Impossibile importare i grafici: $error';
  }

  @override
  String failedToImportPlans(String error) {
    return 'Impossibile importare le schede: $error';
  }

  @override
  String get selectedFileDoesNotExist => 'Il file selezionato non esiste';

  @override
  String get couldNotReadFileData => 'Impossibile leggere i dati del file';

  @override
  String get databaseImportWebUnsupported =>
      'L’importazione del database sul Web richiede una migrazione manuale dei dati. Esporta i dati come file CSV e importa quelli.';

  @override
  String get csvFileEmpty => 'Il file CSV è vuoto';

  @override
  String get csvNeedsDataRow =>
      'Il file CSV deve contenere almeno una riga di dati';

  @override
  String csvRowInsufficientColumns(int row, int count) {
    return 'La riga $row contiene colonne insufficienti: $count';
  }

  @override
  String invalidCsvValue(String field, int row, String value) {
    return 'Valore $field non valido alla riga $row: $value';
  }

  @override
  String invalidCsvDataType(String field, int row, String type) {
    return 'Tipo di dati $field non valido alla riga $row: $type';
  }

  @override
  String expectedIntegerPlanId(String value) {
    return 'Era previsto un ID scheda intero, ricevuto: \"$value\"';
  }

  @override
  String get unitLabel => 'Unità';

  @override
  String get kilogramsUnit => 'Chilogrammi (kg)';

  @override
  String get poundsUnit => 'Libbre (lb)';

  @override
  String get stoneUnit => 'Stone';

  @override
  String get stoneUnitShort => 'st';

  @override
  String get kilometersUnit => 'Chilometri (km)';

  @override
  String get milesUnit => 'Miglia (mi)';

  @override
  String get metersUnit => 'Metri (m)';

  @override
  String get kilocaloriesUnit => 'Chilocalorie (kcal)';

  @override
  String get enterWeight => 'Inserisci peso';

  @override
  String get requiredField => 'Obbligatorio';

  @override
  String get invalidNumber => 'Numero non valido';

  @override
  String get previousWeight => 'Peso precedente';

  @override
  String get imageLabel => 'Immagine';

  @override
  String get longPressToDelete => 'Tieni premuto per eliminare';

  @override
  String get imageError => 'Errore immagine';

  @override
  String get actionSave => 'Salva';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get donate => 'Fai una donazione';

  @override
  String get helpSupportProject => 'Aiuta a sostenere questo progetto';

  @override
  String get whatsNewAbout => 'Novità';

  @override
  String get whatsNewTitle => 'Novità';

  @override
  String get seeReleaseNotes => 'Vedi note di rilascio';

  @override
  String get versionLabel => 'Versione';

  @override
  String get authorLabel => 'Autore';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get privacyPolicyDescription => 'Come Alpha gestisce i tuoi dati';

  @override
  String get licenseLabel => 'Licenza';

  @override
  String get sourceCode => 'Codice sorgente';

  @override
  String get sourceCodeDescription => 'Visualizza su GitHub';

  @override
  String get leaveReview => 'Lascia una recensione';

  @override
  String get leaveReviewDescription => 'Valuta Alpha sul Play Store';

  @override
  String get reportBug => 'Segnala un bug';

  @override
  String get reportBugDescription => 'Apri un ticket su GitHub';

  @override
  String get failedMigrations => 'Migrazioni non riuscite';

  @override
  String get errorMessageLabel => 'Messaggio di errore:';

  @override
  String get createIssue => 'Crea segnalazione';

  @override
  String get addExercise => 'Aggiungi esercizio';

  @override
  String get cardio => 'Cardio';

  @override
  String get strength => 'Forza';

  @override
  String get options => 'Opzioni';

  @override
  String get periodDay => 'Giorno';

  @override
  String get periodWeek => 'Settimana';

  @override
  String get periodMonth => 'Mese';

  @override
  String get periodYear => 'Anno';

  @override
  String noDataFor(String name) {
    return 'Ancora nessun dato per $name';
  }

  @override
  String get noDataYet => 'Ancora nessun dato';

  @override
  String get exerciseNotes => 'Note esercizio';

  @override
  String get notesForExercise => 'Note per questo esercizio';

  @override
  String get useTimeBasedXAxis => 'Usa asse X basato sul tempo';

  @override
  String updateAllNamed(String name) {
    return 'Aggiorna tutti i record $name';
  }

  @override
  String get newName => 'Nuovo nome';

  @override
  String get restMinutes => 'Minuti di recupero';

  @override
  String get restSeconds => 'Secondi di recupero';

  @override
  String get globalProgress => 'Progresso globale';

  @override
  String get curveLineGraphs => 'Smussa linee dei grafici';

  @override
  String get curveLineGraphsDescription =>
      'Disegna le linee dei grafici come curve morbide';

  @override
  String noHistoryFor(String name) {
    return 'Ancora nessuna cronologia per $name';
  }

  @override
  String get cancelSelection => 'Annulla selezione';

  @override
  String get editSelected => 'Modifica selezionati';

  @override
  String get newExercise => 'Nuovo esercizio';

  @override
  String get noGraphsFound => 'Nessun grafico trovato';

  @override
  String get searchGraphs => 'Cerca grafici...';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionUpdate => 'Aggiorna';

  @override
  String get hideGlobalProgress => 'Nascondi progresso globale';

  @override
  String get chartGroupedByCategory => 'Grafico raggruppato per categoria';

  @override
  String get noExercisesFound => 'Nessun esercizio trovato';

  @override
  String get savePlan => 'Salva scheda';

  @override
  String get titleOptional => 'Titolo (facoltativo)';

  @override
  String get searchExercises => 'Cerca esercizi';

  @override
  String get warmupSets => 'Serie di riscaldamento';

  @override
  String get workingSetsMax => 'Serie allenanti (max: 20)';

  @override
  String get actionUndo => 'Annulla';

  @override
  String get actionSwap => 'Sostituisci';

  @override
  String get daily => 'Giornaliero';

  @override
  String get weekly => 'Settimanale';

  @override
  String get monthly => 'Mensile';

  @override
  String get yearly => 'Annuale';

  @override
  String get unexpectedError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get loadingExercises => 'Caricamento esercizi...';

  @override
  String get noPlansYet => 'Ancora nessuna scheda';

  @override
  String get noMatchingPlans => 'Nessuna scheda corrispondente';

  @override
  String get newPlan => 'Nuova scheda';

  @override
  String get searchPlans => 'Cerca schede...';

  @override
  String get noExercisesYet => 'Ancora nessun esercizio';

  @override
  String get editPlan => 'Modifica scheda';

  @override
  String get saveSet => 'Salva serie';

  @override
  String get minutesLabel => 'Minuti';

  @override
  String get minutesShort => 'min';

  @override
  String get secondsLabel => 'Secondi';

  @override
  String get distanceLabel => 'Distanza';

  @override
  String get inclinePercent => 'Pendenza %';

  @override
  String weightWithUnit(String unit) {
    return 'Peso ($unit)';
  }

  @override
  String get useBodyWeight => 'Usa peso corporeo';

  @override
  String get noWeightEnteredYet => 'Nessun peso ancora inserito';

  @override
  String get notesLabel => 'Note';

  @override
  String get swapWorkout => 'Sostituisci esercizio';

  @override
  String get addSet => 'Aggiungi serie';

  @override
  String get deleteSet => 'Elimina serie';

  @override
  String get oneRepMaxEstimate => 'Massimale 1RM (stima)';

  @override
  String get valueLabel => 'Valore';

  @override
  String amountWithUnit(String unit) {
    return 'Quantità ($unit)';
  }

  @override
  String distanceWithUnit(String unit) {
    return 'Distanza ($unit)';
  }

  @override
  String get bodyWeightLabel => 'Peso corporeo';

  @override
  String bodyWeightWithUnit(String unit) {
    return 'Peso corporeo ($unit)';
  }

  @override
  String get categoryHelper =>
      'Scegli una categoria esistente o inseriscine una nuova.';

  @override
  String get manageCategories => 'Gestisci categorie';

  @override
  String get manageCategoriesDescription =>
      'Crea, rinomina, unisci o rimuovi categorie';

  @override
  String get newCategory => 'Nuova categoria';

  @override
  String get renameCategory => 'Rinomina categoria';

  @override
  String get mergeCategory => 'Unisci a un\'altra categoria';

  @override
  String get noCategories => 'Nessuna categoria';

  @override
  String get categoryNameRequired => 'Inserisci un nome per la categoria';

  @override
  String categoryUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usata da $count voci',
      one: 'Usata da 1 voce',
      zero: 'Non usata da nessuna voce',
    );
    return '$_temp0';
  }

  @override
  String deleteCategoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminare questa categoria e rimuoverla da $count voci?',
      one: 'Eliminare questa categoria e rimuoverla da 1 voce?',
      zero: 'Eliminare questa categoria?',
    );
    return '$_temp0';
  }

  @override
  String get createdDate => 'Data di creazione';

  @override
  String editSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Modifica $count serie',
      one: 'Modifica 1 serie',
    );
    return '$_temp0';
  }

  @override
  String get noEntriesYet => 'Ancora nessuna voce';

  @override
  String get historyEmptyMessage =>
      'Completa una serie o aggiungine una manualmente per iniziare la cronologia.';

  @override
  String deleteSetConfirmation(String name) {
    return 'Vuoi davvero eliminare $name?';
  }

  @override
  String deleteEntriesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vuoi davvero eliminare $count voci?',
      one: 'Vuoi davvero eliminare 1 voce?',
    );
    return '$_temp0';
  }

  @override
  String get searchHistory => 'Cerca nella cronologia...';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get pureBlackAmoled => 'Nero puro (AMOLED)';

  @override
  String get showImages => 'Mostra immagini';

  @override
  String get peekGraph => 'Anteprima grafico';

  @override
  String get inputStyleLine => 'Linea';

  @override
  String get inputStyleOutlined => 'Contorno';

  @override
  String get inputStyleFilled => 'Riempito';

  @override
  String get inputStyle => 'Stile dei campi';

  @override
  String get appearance => 'Aspetto';

  @override
  String get automaticBackupsEnabled => 'Backup automatici attivati';

  @override
  String get automaticBackup => 'Backup automatico';

  @override
  String get appPermissions => 'Autorizzazioni app';

  @override
  String get shareDatabase => 'Condividi database';

  @override
  String get dataManagement => 'Gestione dati';

  @override
  String get strengthUnit => 'Unità di peso';

  @override
  String get lastEntry => 'Ultima voce';

  @override
  String get cardioUnit => 'Unità cardio';

  @override
  String longDateFormat(String format) {
    return 'Formato data lungo ($format)';
  }

  @override
  String get formats => 'Formati';

  @override
  String get setsPerExerciseMax => 'Serie per esercizio (max: 20)';

  @override
  String get countLabel => 'Conteggio';

  @override
  String get ratioLabel => 'Rapporto';

  @override
  String get reorder => 'Riordina';

  @override
  String get none => 'Nessuno';

  @override
  String get monday => 'Lunedì';

  @override
  String get examplePlanExercises => 'Panca piana, Squat, Stacco da terra';

  @override
  String get tabs => 'Schede';

  @override
  String get swipeBetweenTabs => 'Scorri tra le schede';

  @override
  String get vibrate => 'Vibrazione';

  @override
  String get enableSound => 'Attiva suono';

  @override
  String get keepScreenOn => 'Mantieni schermo acceso';

  @override
  String get keepRinging => 'Continua a suonare';

  @override
  String get alarmSound => 'Suono allarme';

  @override
  String get top => 'In alto';

  @override
  String get bottom => 'In basso';

  @override
  String get removeCustomTimer =>
      'Rimuovi timer personalizzato (usa valore globale)';

  @override
  String get timers => 'Timer';

  @override
  String get timerSettings => 'Impostazioni timer';

  @override
  String get groupHistory => 'Raggruppa cronologia';

  @override
  String get showUnits => 'Mostra unità';

  @override
  String get showBodyWeight => 'Mostra peso corporeo';

  @override
  String get showCategories => 'Mostra categorie';

  @override
  String get showNotes => 'Mostra note';

  @override
  String get durationEstimation => 'Stima durata';

  @override
  String get showGraphLimit => 'Mostra limite grafico';

  @override
  String get defaultGraphMetric => 'Metrica grafico predefinita';

  @override
  String get bestWeight => 'Peso migliore';

  @override
  String get bestReps => 'Migliori ripetizioni';

  @override
  String get oneRepMax => 'Massimale 1RM';

  @override
  String get volume => 'Volume';

  @override
  String get paceCardio => 'Passo (cardio)';

  @override
  String get distanceCardio => 'Distanza (cardio)';

  @override
  String get defaultGraphPeriod => 'Periodo grafico predefinito';

  @override
  String get defaultGraphLimit => 'Limite grafico predefinito';

  @override
  String get workouts => 'Allenamenti';

  @override
  String get actionStop => 'Ferma';

  @override
  String get timerFinishedToast => 'Timer terminato!';

  @override
  String get stopTimer => 'Ferma timer';

  @override
  String get actionPause => 'Pausa';

  @override
  String get startStopwatch => 'Avvia cronometro';

  @override
  String get actionStart => 'Avvia';

  @override
  String get actionRestart => 'Riavvia';

  @override
  String get addOneMinute => '+1 minuto';

  @override
  String get addOneMinuteNotification => 'Aggiungi 1 min';

  @override
  String get restTimer => 'Timer di recupero';

  @override
  String get timerUp => 'Tempo scaduto';

  @override
  String get openNotification => 'Apri notifica';

  @override
  String get timerChannelName => 'Canale timer';

  @override
  String get timerChannelDescription =>
      'Avanzamento continuo dei timer di recupero.';

  @override
  String get timerFinishedChannelName => 'Canale timer terminati';

  @override
  String get timerFinishedChannelDescription =>
      'Riproduce un allarme quando termina un timer di recupero.';

  @override
  String get timerFinished => 'Timer terminato';

  @override
  String get batteryOptimizationRequestUnavailable =>
      'Le richieste per ignorare l’ottimizzazione della batteria sono disattivate sul dispositivo.';

  @override
  String get exactAlarmRequestUnavailable =>
      'La richiesta SCHEDULE_EXACT_ALARM è stata rifiutata sul dispositivo';

  @override
  String get databaseMigrationFailureDescription =>
      'Si è verificato un problema durante la creazione o l’aggiornamento del database. Di solito si risolve eliminando e ricreando i record.';

  @override
  String get curveSmoothness => 'Smussatura curva';

  @override
  String get actionBack => 'Indietro';

  @override
  String get atLeastOneTab => 'Devi mantenere almeno una scheda';

  @override
  String get invalidTabSettings => 'Impostazioni delle schede non valide.';

  @override
  String get noSettingsFound => 'Nessuna impostazione trovata';

  @override
  String nothingMatchesSearch(String query) {
    return 'Nessun risultato per “$query”.';
  }

  @override
  String get appearanceDescription => 'Tema, colori e stile dell’interfaccia';

  @override
  String get dataManagementDescription =>
      'Importa, esporta e gestisci i dati di allenamento';

  @override
  String get formatsDescription => 'Formati di date, numeri e misure';

  @override
  String get plansSettingsDescription =>
      'Valori predefiniti e comportamento delle schede di allenamento';

  @override
  String get tabsDescription =>
      'Scegli e organizza le schede di navigazione principali';

  @override
  String get timersDescription =>
      'Durata, suono e comportamento del timer di recupero';

  @override
  String get workoutsDescription =>
      'Monitoraggio esercizi e preferenze di allenamento';

  @override
  String get completeSetForChart =>
      'Completa una serie di questo esercizio per creare il grafico.';

  @override
  String get dateRange => 'Intervallo date';

  @override
  String get stopDate => 'Data di fine';

  @override
  String get dataPoints => 'Punti dati';

  @override
  String get completeSetsForProgress =>
      'Completa alcune serie per creare il grafico dei progressi.';

  @override
  String get relativeStrength => 'Forza relativa';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selezionati',
      one: '1 selezionato',
    );
    return '$_temp0';
  }

  @override
  String get completeSetsForHistory =>
      'Completa alcune serie per vedere qui la cronologia di questo esercizio.';

  @override
  String get completeSetForFirstGraph =>
      'Completa una serie per creare il primo grafico dell’esercizio.';

  @override
  String nothingMatchesGraphSearch(String query) {
    return 'Nessun risultato per “$query”. Puoi crearlo come nuovo esercizio.';
  }

  @override
  String addNamed(String name) {
    return 'Aggiungi “$name”';
  }

  @override
  String deleteGraphRecordsConfirmation(int count) {
    return 'Verranno eliminati $count record. Vuoi continuare?';
  }

  @override
  String shareWorkout(String summary) {
    return 'Ho appena fatto $summary';
  }

  @override
  String get updateConflict => 'Conflitto di aggiornamento';

  @override
  String updateConflictDescription(int count) {
    return 'Il nuovo nome esiste già per $count record. Vuoi continuare?';
  }

  @override
  String get unitsConflict => 'Conflitto di unità';

  @override
  String unitsConflictDescription(String unit) {
    return 'Non tutti i record usano la stessa unità. Tutte le unità verranno convertite in $unit. Vuoi continuare?';
  }

  @override
  String get durationLabel => 'Durata';

  @override
  String get inclineLabel => 'Pendenza';

  @override
  String get paceDistanceTime => 'Passo (distanza / tempo)';

  @override
  String get adjustedPace => 'Passo corretto';

  @override
  String get addPlan => 'Aggiungi scheda';

  @override
  String get planDetails => 'Dettagli scheda';

  @override
  String get exercisesLabel => 'Esercizi';

  @override
  String get addExerciseToPlan => 'Aggiungi un esercizio a questa scheda.';

  @override
  String nothingMatchesExerciseSearch(String query) {
    return 'Nessun risultato per “$query”. Puoi aggiungerlo come nuovo esercizio.';
  }

  @override
  String get selectDays => 'Seleziona giorni';

  @override
  String get selectExercises => 'Seleziona esercizi';

  @override
  String get todayLabel => 'Oggi';

  @override
  String get setDetails => 'Dettagli serie';

  @override
  String get themeLabel => 'Tema';

  @override
  String get pureBlackAmoledDescription => 'Usa nero puro sui display AMOLED';

  @override
  String get systemColorScheme => 'Colori di sistema';

  @override
  String get systemColorSchemeDescription =>
      'Usa il colore principale del dispositivo nell’app';

  @override
  String get showImagesDescription =>
      'Scegli e mostra immagini nella pagina cronologia';

  @override
  String get showGlobalProgress => 'Mostra progresso globale';

  @override
  String get showGlobalProgressDescription =>
      'Aggiungi un grafico che mostra i progressi per categoria';

  @override
  String get peekGraphDescription =>
      'Mostra il primo grafico a linee nella pagina dei grafici';

  @override
  String get inputStyleDescription => 'Stile visivo dei campi di testo';

  @override
  String get automaticBackupNotificationBody =>
      'Alpha eseguirà automaticamente ogni giorno il backup di dati e immagini nella cartella selezionata.';

  @override
  String get backupSettingsChannel => 'Impostazioni backup';

  @override
  String get backupSettingsChannelDescription =>
      'Notifiche relative ai backup automatici';

  @override
  String get backupChannelName => 'Canale backup';

  @override
  String get backupChannelDescription =>
      'Backup automatici di dati e immagini di Alpha';

  @override
  String get backupCompletedTitle => 'Dati e immagini salvati';

  @override
  String get backupFailurePathNotSet =>
      'Backup non riuscito: percorso di backup non impostato. I backup automatici sono stati disattivati.';

  @override
  String get backupFailureDirectoryUnavailable =>
      'Backup non riuscito: impossibile accedere alla cartella di backup. I backup automatici sono stati disattivati.';

  @override
  String get backupFailureCreateFile =>
      'Backup non riuscito: impossibile creare il file di backup. I backup automatici sono stati disattivati.';

  @override
  String get backupFailureAppFilesUnavailable =>
      'Backup non riuscito: impossibile accedere alla cartella dei file dell’app. I backup automatici sono stati disattivati.';

  @override
  String get backupFailureDatabaseMissing =>
      'Backup non riuscito: file del database non trovato. I backup automatici sono stati disattivati.';

  @override
  String get backupFailureOutputUnavailable =>
      'Backup non riuscito: impossibile aprire il flusso di output. I backup automatici sono stati disattivati.';

  @override
  String get backupFailureUnknown =>
      'Backup non riuscito. I backup automatici sono stati disattivati.';

  @override
  String get appPermissionsDescription =>
      'Controlla gli accessi richiesti dalle funzioni attive';

  @override
  String get longDateFormatDescription => 'Usato quando c’è spazio sufficiente';

  @override
  String shortDateFormat(String example) {
    return 'Formato data breve ($example)';
  }

  @override
  String get shortDateFormatDescription =>
      'Per gli spazi ridotti (linee dei grafici)';

  @override
  String get warmupSetsDescription =>
      'Le serie di riscaldamento non avviano timer di recupero';

  @override
  String get setsPerExerciseDescription =>
      'Numero predefinito di serie per ogni esercizio in una scheda';

  @override
  String get planTrailingDisplay => 'Info laterali della scheda';

  @override
  String get planTrailingDisplayDescription =>
      'Informazioni mostrate a destra nell’elenco e nella vista della scheda';

  @override
  String get restTimersDescription =>
      'Allarme che parte dopo aver completato una serie';

  @override
  String get vibrateDescription => 'Fai vibrare i timer di recupero';

  @override
  String get enableSoundDescription =>
      'Riproduci un suono per i timer di recupero';

  @override
  String get keepScreenOnDescription =>
      'Mantieni lo schermo acceso durante i timer di recupero';

  @override
  String get keepRingingDescription =>
      'Ripeti il suono e la vibrazione dell\'allarme finché non lo annulli';

  @override
  String get restDurationDescription =>
      'Tempo prima che scatti l’allarme di recupero';

  @override
  String get globalDefault => 'Predefinito globale';

  @override
  String get alarmSoundDescription =>
      'Suono riprodotto al termine di un timer di recupero';

  @override
  String get progressBarPosition => 'Posizione barra di avanzamento';

  @override
  String get progressBarPositionDescription =>
      'Dove mostrare la barra di avanzamento dei timer di recupero';

  @override
  String get perExerciseRestTimes => 'Tempi di recupero per esercizio';

  @override
  String get perExerciseRestTimesDescription =>
      'Questi esercizi hanno tempi di recupero personalizzati';

  @override
  String get audioFeaturesUnavailable =>
      'Le funzioni audio non sono disponibili';

  @override
  String get groupHistoryDescription =>
      'Raggruppa le voci della cronologia per giorno';

  @override
  String get showUnitsDescription =>
      'Mostra km/mi e kg/lb in grafici, cronologia e schede';

  @override
  String get showBodyWeightDescription =>
      'Attiva o disattiva il monitoraggio del peso corporeo';

  @override
  String get showCategoriesDescription =>
      'Attiva o disattiva le categorie di allenamento';

  @override
  String get showNotesDescription =>
      'Registra i dettagli della serie in un campo di testo';

  @override
  String get positiveReinforcement => 'Rinforzo positivo';

  @override
  String get positiveNotificationsDescription =>
      'Mostra messaggi motivazionali quando stabilisci un nuovo record';

  @override
  String get positiveMessagesEnabled =>
      'I messaggi motivazionali appariranno così!';

  @override
  String get recordEncouragement01 => 'Ottimo lavoro! Sei incredibile.';

  @override
  String get recordEncouragement02 =>
      'Grande! I tuoi progressi sono d’ispirazione.';

  @override
  String get recordEncouragement03 => 'Mi inchino...';

  @override
  String get recordEncouragement04 => 'Cos’è? Un nuovo record!';

  @override
  String get recordEncouragement05 => 'Incredibile! Sei un’ispirazione.';

  @override
  String get recordEncouragement06 => 'Wow. Grande.';

  @override
  String get recordEncouragement07 => 'Sempre più forte, eh?';

  @override
  String get recordEncouragement08 => 'Sì. Stai diventando davvero forte.';

  @override
  String get recordEncouragement09 => 'Fantastico. Incredibile.';

  @override
  String get recordEncouragement10 => 'Arnie sarebbe fiero.';

  @override
  String get recordEncouragement11 => 'Ronnie C ti guarda soddisfatto.';

  @override
  String get recordEncouragement12 => 'YEAH! LIGHTWEIGHT, BABY!!!!!!!';

  @override
  String get recordEncouragement13 =>
      'È un nuovo record? Sapevo che ce l’avresti fatta.';

  @override
  String get recordEncouragement14 => 'Ottimo lavoro! Sono fiero di te.';

  @override
  String get recordEncouragement15 => 'Sì! Leggerissimo!';

  @override
  String get recordEncouragement16 => 'Continua così! Ottimi progressi.';

  @override
  String get recordEncouragement17 => 'Stai andando alla grande.';

  @override
  String get recordEncouragement18 => 'Questo è il mio campione!';

  @override
  String get recordEncouragement19 => 'Continua così.';

  @override
  String get recordEncouragement20 => 'Stai diventando davvero forte.';

  @override
  String get recordEncouragement21 => 'Potente.';

  @override
  String get recordEncouragement22 => 'Che potenza!';

  @override
  String get recordEncouragement23 => 'Sono fiero di te.';

  @override
  String get recordEncouragement24 => 'Continua con questo ottimo lavoro.';

  @override
  String get recordEncouragement25 =>
      'A testa alta! Hai appena stabilito un nuovo record.';

  @override
  String get recordEncouragement26 =>
      'Nuovo record! Sei andato oltre ogni volta precedente!';

  @override
  String get recordEncouragement27 => 'Sì! È un record.';

  @override
  String get recordEncouragement28 => 'Wow! Nuovo record!';

  @override
  String get recordEncouragement29 => 'Davvero ottimo.';

  @override
  String get durationEstimationDescription =>
      'Prova a prevedere la durata del cardio';

  @override
  String get showGraphXAxisToggle => 'Mostra selettore asse X';

  @override
  String get showGraphXAxisToggleDescription =>
      'Mostra nei grafici il selettore dell’asse X basato sul tempo';

  @override
  String get showGraphLimitDescription =>
      'Mostra il cursore del limite nei grafici';

  @override
  String get defaultTimeBasedXAxis => 'Asse X temporale predefinito';

  @override
  String get defaultTimeBasedXAxisDescription =>
      'Usa per impostazione predefinita un asse X basato sul tempo nei grafici';

  @override
  String get createFirstTrainingPlan =>
      'Crea la tua prima scheda di allenamento per iniziare.';

  @override
  String nothingMatchesPlanSearch(String query) {
    return 'Nessun risultato per “$query”. Puoi crearlo come nuova scheda.';
  }

  @override
  String get createPlan => 'Crea scheda';

  @override
  String createNamedPlan(String name) {
    return 'Crea “$name”';
  }

  @override
  String setNumber(int number) {
    return 'Serie $number';
  }

  @override
  String get tabStart => 'Inizio';

  @override
  String get tabTraining => 'Allenamento';

  @override
  String get tabExercises => 'Esercizi';

  @override
  String get tabProfile => 'Profilo';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String dayStreak(int count) {
    return '$count giorni di fila';
  }

  @override
  String weekStreak(int count) {
    return '$count settimane di fila';
  }

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get bodyWeightChart => 'Peso corporeo';

  @override
  String get strengthChart => 'Forza';

  @override
  String get weeklyVolumeChart => 'Volume settimanale';

  @override
  String get noChartData => 'Dati ancora insufficienti';

  @override
  String get newTemplate => 'Nuovo modello';

  @override
  String get templateLimit => 'Puoi salvare fino a 7 modelli.';

  @override
  String get templatesEmpty => 'Questo modello non ha ancora esercizi.';

  @override
  String get allMuscles => 'Tutti';

  @override
  String get noHistory => 'Nessuno storico';

  @override
  String bestOneRepMax(String value) {
    return '1RM stimato $value kg';
  }

  @override
  String bestLoad(String value) {
    return 'Carico migliore $value kg';
  }

  @override
  String get profileName => 'Nome';

  @override
  String get heightCm => 'Altezza (cm)';

  @override
  String get ageOptional => 'Età (facoltativa)';

  @override
  String get goals => 'Obiettivi';

  @override
  String get bodyData => 'Dati corporei';

  @override
  String get addBodyWeight => 'Aggiungi peso';

  @override
  String get weightKg => 'Peso (kg)';

  @override
  String get aiCoaching => 'Coaching IA';

  @override
  String get apiKey => 'Chiave API';

  @override
  String get apiKeyStoredLocally =>
      'Salvata solo su questo telefono. Non è ancora usata.';

  @override
  String get profileSaved => 'Profilo salvato';

  @override
  String get noTrainingThisDay => 'Niente registrato in questo giorno';

  @override
  String targetSets(int count) {
    return '$count serie';
  }

  @override
  String repRangeLabel(String range) {
    return '$range rip';
  }

  @override
  String get repMinLabel => 'Rip da';

  @override
  String get repMaxLabel => 'Rip a';

  @override
  String get exerciseDatabaseCreditTitle => 'Libreria esercizi';

  @override
  String get exerciseDatabaseCreditBody =>
      'Nomi da free-exercise-db di yuhonas, Unlicense (pubblico dominio). Alpha ha aggiunto nomi e alias.';

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
  String get finishWorkoutAsk => 'Chiudere questo allenamento?';

  @override
  String get finishWorkoutBody =>
      'La sessione viene salvata e il modello resta com’è.';

  @override
  String get discardWorkoutAsk => 'Scartare questo allenamento?';

  @override
  String get discardWorkoutBody =>
      'Le serie registrate di questa sessione vengono eliminate.';

  @override
  String get noRest => 'Nessuna pausa';

  @override
  String get restWheelTitle => 'Pausa';

  @override
  String get deleteTemplateAsk => 'Eliminare questo modello?';

  @override
  String deleteTemplateBody(String name) {
    return 'Eliminare «$name»? Gli allenamenti salvati restano.';
  }

  @override
  String get warmupAction => 'Riscaldamento';

  @override
  String get warmupMark => 'W';

  @override
  String get confirmAddExercise => 'Aggiungi esercizio';

  @override
  String get tabOverview => 'Panoramica';

  @override
  String get tabHistory => 'Cronologia';

  @override
  String get tabHowTo => 'Esecuzione';

  @override
  String get primaryMuscleLabel => 'Muscolo principale';

  @override
  String get secondaryMuscleLabel => 'Muscoli secondari';

  @override
  String get equipmentLabel => 'Attrezzo';

  @override
  String get heaviestWeight => 'Peso più alto';

  @override
  String get estimatedOneRm => '1RM stimato';

  @override
  String get volumeChart => 'Volume di allenamento';

  @override
  String get recordsTitle => 'Migliori risultati';

  @override
  String get weekGoal => 'Obiettivo settimanale';

  @override
  String weekGoalProgress(int done, int goal) {
    return '$done di $goal';
  }

  @override
  String startWorkoutNamed(String name) {
    return 'Inizia allenamento · $name';
  }

  @override
  String get musclesThisWeek => 'Muscoli di questa settimana';

  @override
  String get progressHeading => 'Progressi';

  @override
  String get lastEightWeeks => 'Ultime otto settimane';

  @override
  String get chooseProfile => 'Scegli un profilo';

  @override
  String get createProfileAction => 'Crea profilo';

  @override
  String get plateCalculator => 'Calcolo dei dischi';

  @override
  String get barbellCalc => 'Bilanciere';

  @override
  String get cableCalc => 'Cavi';

  @override
  String get extraWeight => 'Peso extra';

  @override
  String get barWeightLabel => 'Peso del bilanciere';

  @override
  String get plateSetLabel => 'Dischi per lato';

  @override
  String get cableStepLabel => 'Passo della pila';

  @override
  String get chooseGym => 'Scegli la palestra';

  @override
  String get gymsTitle => 'Palestre';

  @override
  String get newGym => 'Nuova palestra';

  @override
  String get progressionHelp => 'Aiuto alla progressione';

  @override
  String progressionAsk(String name, String weight, int reps) {
    return '$name: la prossima volta $weight kg e ripartire da $reps ripetizioni?';
  }

  @override
  String get actionAccept => 'Accetta';

  @override
  String get actionReject => 'Rifiuta';

  @override
  String get importExportTitle => 'Importa ed esporta i dati';

  @override
  String get importWorkouts => 'Importa allenamenti';

  @override
  String get importMeasurements => 'Importa misurazioni';

  @override
  String get exportAlphaData => 'Esporta i dati Alpha';

  @override
  String get importPreviewTitle => 'Anteprima importazione';

  @override
  String importSummary(int workouts, int exercises) {
    return '$workouts allenamenti, $exercises esercizi';
  }

  @override
  String get templatesDetected => 'Modelli rilevati';

  @override
  String get renameLabel => 'Rinomina';

  @override
  String get mapExercise => 'Abbina esercizio';

  @override
  String get checkForUpdates => 'Cerca aggiornamenti';

  @override
  String get upToDate => 'Sei aggiornato';

  @override
  String get updateCheckFailed =>
      'Il controllo degli aggiornamenti non è riuscito';

  @override
  String get licensesTitle => 'Licenze';

  @override
  String get flexifyMitNotice =>
      'Flexify è pubblicato con licenza MIT. Copyright Brandon Dick.';

  @override
  String get exerciseDbNotice =>
      'Ogni esercizio indica la propria fonte e licenza.';

  @override
  String get sourceLabel => 'Fonte';

  @override
  String get tipsLabel => 'Consigli';

  @override
  String get imageSourceLabel => 'Fonte immagine';

  @override
  String get imageLicenseLabel => 'Licenza immagine';

  @override
  String get muscleUpperChest => 'Petto alto';

  @override
  String get muscleFrontShoulder => 'Spalla anteriore';

  @override
  String get muscleSideShoulder => 'Spalla laterale';

  @override
  String get muscleRearShoulder => 'Spalla posteriore';

  @override
  String get muscleLatissimus => 'Gran dorsale';

  @override
  String get muscleUpperBack => 'Schiena alta';

  @override
  String get muscleTrapez => 'Trapezi';

  @override
  String get muscleLowerBack => 'Schiena bassa';

  @override
  String get muscleForearms => 'Avambracci';

  @override
  String get muscleRectus => 'Retto dell addome';

  @override
  String get muscleObliques => 'Obliqui addominali';

  @override
  String get muscleQuadriceps => 'Quadricipiti';

  @override
  String get muscleAdductors => 'Adduttori';

  @override
  String get muscleAbductors => 'Abduttori';

  @override
  String get muscleHipFlexors => 'Flessori dell anca';

  @override
  String get alternativesLabel => 'Alternative';

  @override
  String get mechanicLabel => 'Meccanica';

  @override
  String get aiCoachTitle => 'Coach IA';

  @override
  String get aiProviderLabel => 'Fornitore';

  @override
  String get aiOffNotice =>
      'Il coach resta spento finché non salvi la tua chiave.';

  @override
  String get coachHint => 'Chiedi al coach';

  @override
  String get voiceInput => 'Input vocale';

  @override
  String voiceUnderstood(String text) {
    return 'Capito: $text';
  }

  @override
  String get speechFailed => 'L’input vocale non è riuscito';

  @override
  String get confirmVoiceSet => 'Applicare questa serie?';

  @override
  String get periodSession => 'Questo allenamento';

  @override
  String get muscleMapTitle => 'Mappa muscolare';

  @override
  String get frontView => 'Davanti';

  @override
  String get backView => 'Dietro';

  @override
  String quoteKeepGoing(int done, int goal) {
    return '$done sessioni su $goal questa settimana. Continua.';
  }

  @override
  String quoteRemaining(int count) {
    return 'Restano $count sessioni questa settimana.';
  }

  @override
  String get quotePullDay =>
      'Giorno di trazione. Schiena e bicipiti sono pronti.';

  @override
  String get quotePushDay => 'Giorno di spinta. Petto, spalle e tricipiti.';

  @override
  String get quoteLegDay =>
      'Giorno delle gambe. Quadricipiti, femorali e glutei.';

  @override
  String versionAndLicenses(String version) {
    return 'Versione $version · Licenze';
  }

  @override
  String get liveWorkoutLabel => 'Allenamento in corso';

  @override
  String get muscleChest => 'Petto';

  @override
  String get muscleShoulders => 'Spalle';

  @override
  String get muscleBiceps => 'Bicipiti';

  @override
  String get muscleTriceps => 'Tricipiti';

  @override
  String get muscleAbs => 'Addominali';

  @override
  String get muscleQuads => 'Quadricipiti';

  @override
  String get muscleCalves => 'Polpacci';

  @override
  String get muscleTraps => 'Trapezi';

  @override
  String get muscleBack => 'Schiena';

  @override
  String get muscleGlutes => 'Glutei';

  @override
  String get muscleHams => 'Femorali';

  @override
  String get weekGoalManual => 'Imposta tu l’obiettivo settimanale';

  @override
  String get sessionsPerWeek => 'Sessioni a settimana';

  @override
  String get gymNameHint => 'Nome della palestra';

  @override
  String get coachProfileNote => 'Nota del tuo coach';

  @override
  String get openPackageLicenses => 'Apri le licenze dei pacchetti';

  @override
  String get lengthUnitLabel => 'Lunghezza del corpo';

  @override
  String get centimetersShort => 'Centimetri (cm)';

  @override
  String get inchesShort => 'Pollici (in)';

  @override
  String get heightInches => 'Altezza (pollici)';

  @override
  String get welcomeToAlpha => 'Benvenuto in Alpha';

  @override
  String get createProfileButton => 'Crea profilo';

  @override
  String get onboardingWeightHint => 'Peso corporeo, facoltativo';

  @override
  String get familyLabel => 'Famiglia';

  @override
  String get gripLabel => 'Presa';

  @override
  String get positionLabel => 'Posizione';

  @override
  String get movementLabel => 'Movimento';

  @override
  String get unilateralLabel => 'Unilaterale';

  @override
  String get otherVariants => 'Altre varianti';

  @override
  String get sideLeft => 'Sinistra';

  @override
  String get sideRight => 'Destra';

  @override
  String get createCustomExercise => 'Crea esercizio';

  @override
  String get editCustomExercise => 'Modifica esercizio';

  @override
  String get deleteCustomExercise => 'Elimina esercizio';

  @override
  String get deleteCustomExerciseBody =>
      'Eliminare questo esercizio? Gli allenamenti passati restano nello storico.';

  @override
  String get customExerciseName => 'Nome';

  @override
  String get customExerciseFamily => 'Id famiglia';

  @override
  String get createAsCustomExercise => 'Crea come esercizio personale';

  @override
  String get customExerciseInvalid =>
      'Scegli un nome, i muscoli e un attrezzo.';

  @override
  String get motionPress => 'Spinta';

  @override
  String get motionPull => 'Trazione';

  @override
  String get motionLegs => 'Gambe/anche';

  @override
  String get motionCore => 'Addome';

  @override
  String get motionCardio => 'Cardio';

  @override
  String get mechanicCompound => 'Multiarticolare';

  @override
  String get mechanicIsolation => 'Isolamento';

  @override
  String get ownExerciseSource => 'Esercizio personale';

  @override
  String get notSpecified => '–';

  @override
  String get resumeWorkout => 'Riprendi l\'allenamento';

  @override
  String get importBackupZip => 'Importa backup (.zip)';

  @override
  String importSetSummary(int workouts, int sets) {
    return '$workouts allenamenti, $sets serie';
  }

  @override
  String importDateErrorCount(int count) {
    return '$count righe hanno una data illeggibile.';
  }

  @override
  String importUnmatchedNames(String names) {
    return 'Nessuna corrispondenza: $names';
  }

  @override
  String importTemplatesSkipped(String names) {
    return 'Non create, limite dei modelli raggiunto: $names';
  }

  @override
  String importApplying(int done, int total) {
    return '$done di $total';
  }

  @override
  String get customExerciseMovementRequired => 'Scegli un movimento.';

  @override
  String get setRemoved => 'Serie rimossa';

  @override
  String get exerciseRemovedUndo => 'Esercizio rimosso';

  @override
  String get exerciseSwappedUndo => 'Esercizio sostituito';

  @override
  String get saveRestInTemplate => 'Salva anche nel modello';

  @override
  String get deleteGymTitle => 'Eliminare la palestra?';

  @override
  String get deleteGymBody =>
      'Gli allenamenti collegati a questa palestra restano. Si elimina solo la palestra.';

  @override
  String get renameGym => 'Rinomina palestra';

  @override
  String get cleanupImports => 'Pulisci le voci importate';

  @override
  String cleanupImportsPreview(int workouts, int templates) {
    return '$workouts allenamenti importati e $templates modelli saranno rimossi. Gli allenamenti inseriti a mano restano.';
  }

  @override
  String get cleanupImportsEmpty => 'Niente da pulire.';

  @override
  String get cleanupImportsDone => 'Voci importate rimosse.';

  @override
  String measurementsImported(int count) {
    return '$count misurazioni importate.';
  }
}
