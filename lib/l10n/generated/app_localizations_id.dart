// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Alpha';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageDescription => 'Pilih bahasa yang digunakan Alpha';

  @override
  String get languageSystemDefault => 'Default sistem';

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
  String get navHistory => 'Riwayat';

  @override
  String get navPlans => 'Rencana';

  @override
  String get navGraphs => 'Grafik';

  @override
  String get navTimer => 'Pewaktu';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get errorLabel => 'Galat';

  @override
  String get tabContentError => 'Konten tab tidak dapat dibuat.';

  @override
  String get cannotHideAllTabs => 'Tidak bisa menyembunyikan semuanya!';

  @override
  String removeTabQuestion(String tab) {
    return 'Hapus tab $tab?';
  }

  @override
  String get restoreTabFromSettings =>
      'Anda dapat menambahkannya kembali nanti dari pengaturan.';

  @override
  String removedTab(String tab) {
    return 'Tab $tab dihapus';
  }

  @override
  String newVersion(String version) {
    return 'Versi baru $version';
  }

  @override
  String get changes => 'Perubahan';

  @override
  String get searchHint => 'Cari...';

  @override
  String get deleteSelected => 'Hapus yang dipilih';

  @override
  String get confirmDelete => 'Konfirmasi penghapusan';

  @override
  String deleteRecordsConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Anda yakin ingin menghapus $count catatan? Tindakan ini tidak dapat dibatalkan.',
      one:
          'Anda yakin ingin menghapus 1 catatan? Tindakan ini tidak dapat dibatalkan.',
    );
    return '$_temp0';
  }

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionDiscard => 'Buang';

  @override
  String get unsavedChanges => 'Perubahan belum disimpan';

  @override
  String get discardUnsavedChanges => 'Buang perubahan yang belum disimpan?';

  @override
  String get actionDelete => 'Hapus';

  @override
  String get actionRemove => 'Hapus';

  @override
  String get actionEdit => 'Sunting';

  @override
  String get actionShare => 'Bagikan';

  @override
  String get clearSelection => 'Hapus pilihan';

  @override
  String get clearSearch => 'Hapus pencarian';

  @override
  String get showMenu => 'Tampilkan menu';

  @override
  String get selectAll => 'Pilih semua';

  @override
  String get weightLabel => 'Berat';

  @override
  String get filter => 'Penyaring';

  @override
  String get filters => 'Penyaring';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get repsLabel => 'Repetisi';

  @override
  String get repsFilter => 'Filter repetisi';

  @override
  String get weightFilter => 'Filter berat';

  @override
  String get greaterThan => 'Lebih besar dari';

  @override
  String get lessThan => 'Kurang dari';

  @override
  String get startDate => 'Tanggal mulai';

  @override
  String get endDate => 'Tanggal akhir';

  @override
  String get actionClear => 'Bersihkan';

  @override
  String get actionOk => 'Oke';

  @override
  String get actionClose => 'Tutup';

  @override
  String get sortBy => 'Urutkan menurut';

  @override
  String get dateNewest => 'Tanggal (terbaru)';

  @override
  String get dateOldest => 'Tanggal (tertua)';

  @override
  String get nameLabel => 'Nama';

  @override
  String get missingPermissions => 'Izin tidak lengkap';

  @override
  String get restTimersPermissionsMissing =>
      'Pewaktu istirahat aktif, tetapi izin yang diperlukan belum diberikan.';

  @override
  String get restTimersPermissionsOptional =>
      'Jika Anda menonaktifkan pewaktu istirahat, izin ini tidak diperlukan.';

  @override
  String get restTimers => 'Pewaktu istirahat';

  @override
  String get disableBatteryOptimizations => 'Nonaktifkan optimasi baterai';

  @override
  String get batteryOptimizationWarning =>
      'Kemajuan mungkin akan berhenti jika optimasi baterai tetap berjalan.';

  @override
  String get scheduleExactAlarm => 'Jadwalkan alarm tepat waktu';

  @override
  String get exactAlarmWarning =>
      'Alarm tidak dapat akurat jika ini dinonaktifkan.';

  @override
  String get postNotifications => 'Kirim notifikasi';

  @override
  String get notificationBarDescription =>
      'Kemajuan pewaktu dikirim ke bilah notifikasi';

  @override
  String get invalidPermissions => 'Izin tidak valid';

  @override
  String get insufficientTimerPermissionsConfirmation =>
      'Pewaktu istirahat diaktifkan tanpa izin yang memadai. Anda yakin?';

  @override
  String get actionConfirm => 'Konfirmasi';

  @override
  String get appAccess => 'Akses aplikasi';

  @override
  String get appAccessDescription =>
      'Diperlukan untuk pewaktu dan notifikasi yang diaktifkan.';

  @override
  String get notifications => 'Pemberitahuan';

  @override
  String get timerProgressAndRestAlerts =>
      'Kemajuan pewaktu dan peringatan istirahat';

  @override
  String get enabledNotificationsDescription => 'Notifikasi yang Anda aktifkan';

  @override
  String get backgroundActivity => 'Aktivitas latar belakang';

  @override
  String get backgroundActivityDescription =>
      'Jaga agar pewaktu tetap andal di latar belakang';

  @override
  String get exactAlarms => 'Alarm tepat waktu';

  @override
  String get exactAlarmsDescription =>
      'Beri tahu tepat saat pewaktu istirahat berakhir';

  @override
  String get noAdditionalAndroidAccessNeeded =>
      'Tidak diperlukan akses Android tambahan untuk pengaturan Anda saat ini.';

  @override
  String get actionDone => 'Selesai';

  @override
  String get allowed => 'Diizinkan';

  @override
  String get actionAllow => 'Izinkan';

  @override
  String get backupLabel => 'Cadangan';

  @override
  String get databaseLabel => 'Basis data';

  @override
  String get deleteRecords => 'Hapus catatan';

  @override
  String get deleteAllGraphsConfirmation =>
      'Anda yakin ingin menghapus semua grafik? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get deleteAllPlansConfirmation =>
      'Anda yakin ingin menghapus semua rencana? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get deleteDatabaseConfirmation =>
      'Anda yakin ingin menghapus basis data Anda? Tindakan ini tidak dapat dibatalkan dan akan menghapus seluruh data Anda.';

  @override
  String get importData => 'Impor data';

  @override
  String get exportData => 'Ekspor data';

  @override
  String get actionReport => 'Laporkan';

  @override
  String get graphDataImported => 'Data grafik diimpor dengan sukses!';

  @override
  String get plansImported => 'Rencana diimpor dengan sukses';

  @override
  String failedToImportDatabase(String error) {
    return 'Gagal mengimpor basis data: $error';
  }

  @override
  String get backupArchiveMissingDatabase =>
      'Arsip cadangan tidak berisi basis data Alpha.';

  @override
  String failedToImportGraphs(String error) {
    return 'Gagal mengimpor grafik: $error';
  }

  @override
  String failedToImportPlans(String error) {
    return 'Gagal mengimpor rencana: $error';
  }

  @override
  String get selectedFileDoesNotExist => 'Berkas yang dipilih tidak ada';

  @override
  String get couldNotReadFileData => 'Data berkas tidak dapat dibaca';

  @override
  String get databaseImportWebUnsupported =>
      'Impor basis data di web memerlukan migrasi data manual. Ekspor data Anda sebagai berkas CSV lalu impor berkas tersebut.';

  @override
  String get csvFileEmpty => 'Berkas CSV kosong';

  @override
  String get csvNeedsDataRow =>
      'Berkas CSV harus memuat setidaknya satu baris data';

  @override
  String csvRowInsufficientColumns(int row, int count) {
    return 'Baris $row tidak memiliki kolom yang cukup: $count';
  }

  @override
  String invalidCsvValue(String field, int row, String value) {
    return 'Nilai $field tidak valid dalam baris $row: $value';
  }

  @override
  String invalidCsvDataType(String field, int row, String type) {
    return 'Tipe data $field tidak valid dalam baris $row: $type';
  }

  @override
  String expectedIntegerPlanId(String value) {
    return 'ID rencana harus berupa bilangan bulat, tetapi diperoleh \"$value\"';
  }

  @override
  String get unitLabel => 'Satuan';

  @override
  String get kilogramsUnit => 'Kilogram (kg)';

  @override
  String get poundsUnit => 'Pon (lb)';

  @override
  String get stoneUnit => 'Stone (st)';

  @override
  String get stoneUnitShort => 'st';

  @override
  String get kilometersUnit => 'Kilometer (km)';

  @override
  String get milesUnit => 'Mil (mi)';

  @override
  String get metersUnit => 'Meter (m)';

  @override
  String get kilocaloriesUnit => 'Kilokalori (kcal)';

  @override
  String get enterWeight => 'Masukkan berat';

  @override
  String get requiredField => 'Wajib diisi';

  @override
  String get invalidNumber => 'Nomor tidak valid';

  @override
  String get previousWeight => 'Berat sebelumnya';

  @override
  String get imageLabel => 'Gambar';

  @override
  String get longPressToDelete => 'Tekan lama untuk menghapus';

  @override
  String get imageError => 'Kesalahan gambar';

  @override
  String get actionSave => 'Simpan';

  @override
  String get aboutTitle => 'Tentang';

  @override
  String get donate => 'Donasi';

  @override
  String get helpSupportProject => 'Bantu mendukung proyek ini';

  @override
  String get whatsNewAbout => 'Apa yang baru?';

  @override
  String get whatsNewTitle => 'Apa yang baru?';

  @override
  String get seeReleaseNotes => 'Lihat catatan rilis kami';

  @override
  String get versionLabel => 'Versi';

  @override
  String get authorLabel => 'Penulis';

  @override
  String get privacyPolicy => 'Kebijakan privasi';

  @override
  String get privacyPolicyDescription => 'Cara Alpha menangani data Anda';

  @override
  String get licenseLabel => 'Lisensi';

  @override
  String get sourceCode => 'Kode sumber';

  @override
  String get sourceCodeDescription => 'Lihat di GitHub';

  @override
  String get leaveReview => 'Beri ulasan';

  @override
  String get leaveReviewDescription => 'Beri nilai Alpha di Play Store';

  @override
  String get reportBug => 'Laporkan bug';

  @override
  String get reportBugDescription => 'Buka tiket di GitHub';

  @override
  String get failedMigrations => 'Migrasi gagal';

  @override
  String get errorMessageLabel => 'Pesan galat:';

  @override
  String get createIssue => 'Buat isu';

  @override
  String get addExercise => 'Tambah latihan';

  @override
  String get cardio => 'Kardio';

  @override
  String get strength => 'Kekuatan';

  @override
  String get options => 'Opsi';

  @override
  String get periodDay => 'Hari';

  @override
  String get periodWeek => 'Minggu';

  @override
  String get periodMonth => 'Bulan';

  @override
  String get periodYear => 'Tahun';

  @override
  String noDataFor(String name) {
    return 'Belum ada data untuk $name';
  }

  @override
  String get noDataYet => 'Belum ada data';

  @override
  String get exerciseNotes => 'Catatan latihan';

  @override
  String get notesForExercise => 'Catatan untuk latihan ini';

  @override
  String get useTimeBasedXAxis => 'Gunakan sumbu X berbasis waktu';

  @override
  String updateAllNamed(String name) {
    return 'Perbarui semua $name';
  }

  @override
  String get newName => 'Nama baru';

  @override
  String get restMinutes => 'Menit istirahat';

  @override
  String get restSeconds => 'Detik istirahat';

  @override
  String get globalProgress => 'Kemajuan global';

  @override
  String get curveLineGraphs => 'Lengkungkan grafik garis';

  @override
  String get curveLineGraphsDescription =>
      'Gambar garis grafik sebagai kurva halus';

  @override
  String noHistoryFor(String name) {
    return 'Belum ada riwayat untuk $name';
  }

  @override
  String get cancelSelection => 'Batalkan pilihan';

  @override
  String get editSelected => 'Sunting yang dipilih';

  @override
  String get newExercise => 'Latihan baru';

  @override
  String get noGraphsFound => 'Tidak ada grafik';

  @override
  String get searchGraphs => 'Cari grafik…';

  @override
  String get actionAdd => 'Tambah';

  @override
  String get actionUpdate => 'Perbarui';

  @override
  String get hideGlobalProgress => 'Sembunyikan kemajuan global';

  @override
  String get chartGroupedByCategory =>
      'Grafik yang dikelompokkan berdasarkan kategori';

  @override
  String get noExercisesFound => 'Tidak ada latihan';

  @override
  String get savePlan => 'Simpan rencana';

  @override
  String get titleOptional => 'Judul (opsional)';

  @override
  String get searchExercises => 'Cari gerakan';

  @override
  String get warmupSets => 'Set pemanasan';

  @override
  String get workingSetsMax => 'Set kerja (maks: 20)';

  @override
  String get actionUndo => 'Urungkan';

  @override
  String get actionSwap => 'Tukar';

  @override
  String get daily => 'Harian';

  @override
  String get weekly => 'Mingguan';

  @override
  String get monthly => 'Bulanan';

  @override
  String get yearly => 'Tahunan';

  @override
  String get unexpectedError => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get loadingExercises => 'Memuat latihan…';

  @override
  String get noPlansYet => 'Belum ada rencana.';

  @override
  String get noMatchingPlans => 'Tidak ada rencana yang cocok';

  @override
  String get newPlan => 'Rencana baru';

  @override
  String get searchPlans => 'Cari rencana…';

  @override
  String get noExercisesYet => 'Belum ada latihan.';

  @override
  String get editPlan => 'Sunting rencana';

  @override
  String get saveSet => 'Simpan set';

  @override
  String get minutesLabel => 'Menit';

  @override
  String get minutesShort => 'mnt';

  @override
  String get secondsLabel => 'Detik';

  @override
  String get distanceLabel => 'Jarak';

  @override
  String get inclinePercent => 'Kemiringan %';

  @override
  String weightWithUnit(String unit) {
    return 'Berat ($unit)';
  }

  @override
  String get useBodyWeight => 'Gunakan berat badan';

  @override
  String get noWeightEnteredYet => 'Belum ada berat yang dimasukkan';

  @override
  String get notesLabel => 'Catatan';

  @override
  String get swapWorkout => 'Tukar latihan';

  @override
  String get addSet => 'Tambah set';

  @override
  String get deleteSet => 'Hapus set';

  @override
  String get oneRepMaxEstimate => 'Maksimum 1 repetisi (perkiraan)';

  @override
  String get valueLabel => 'Nilai';

  @override
  String amountWithUnit(String unit) {
    return 'Jumlah ($unit)';
  }

  @override
  String distanceWithUnit(String unit) {
    return 'Jarak ($unit)';
  }

  @override
  String get bodyWeightLabel => 'Berat badan';

  @override
  String bodyWeightWithUnit(String unit) {
    return 'Berat badan ($unit)';
  }

  @override
  String get categoryHelper => 'Pilih kategori yang ada atau ketik yang baru.';

  @override
  String get manageCategories => 'Kelola kategori';

  @override
  String get manageCategoriesDescription =>
      'Buat, ubah nama, gabung atau hapus kategori';

  @override
  String get newCategory => 'Kategori baru';

  @override
  String get renameCategory => 'Ubah nama kategori';

  @override
  String get mergeCategory => 'Gabung ke kategori lain';

  @override
  String get noCategories => 'Belum ada kategori';

  @override
  String get categoryNameRequired => 'Masukkan nama kategori';

  @override
  String categoryUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Digunakan oleh $count entri',
      one: 'Digunakan oleh 1 entri',
      zero: 'Tidak digunakan oleh entri apa pun',
    );
    return '$_temp0';
  }

  @override
  String deleteCategoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus kategori ini dan keluarkan dari $count entri?',
      one: 'Hapus kategori ini dan keluarkan dari 1 entri?',
      zero: 'Hapus kategori ini?',
    );
    return '$_temp0';
  }

  @override
  String get createdDate => 'Tanggal dibuat';

  @override
  String editSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Edit $count set',
      one: 'Edit 1 set',
    );
    return '$_temp0';
  }

  @override
  String get noEntriesYet => 'Belum ada entri';

  @override
  String get historyEmptyMessage =>
      'Selesaikan satu set atau tambahkan satu secara manual untuk memulai riwayat Anda.';

  @override
  String deleteSetConfirmation(String name) {
    return 'Anda yakin ingin menghapus $name?';
  }

  @override
  String deleteEntriesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Anda yakin ingin menghapus $count entri?',
      one: 'Anda yakin ingin menghapus 1 entri?',
    );
    return '$_temp0';
  }

  @override
  String get searchHistory => 'Cari riwayat...';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeLight => 'Terang';

  @override
  String get pureBlackAmoled => 'Hitam murni (AMOLED)';

  @override
  String get showImages => 'Tampilkan gambar';

  @override
  String get peekGraph => 'Pratinjau grafik';

  @override
  String get inputStyleLine => 'Baris';

  @override
  String get inputStyleOutlined => 'Tergaris';

  @override
  String get inputStyleFilled => 'Terisi';

  @override
  String get inputStyle => 'Gaya masukan';

  @override
  String get appearance => 'Tampilan';

  @override
  String get automaticBackupsEnabled => 'Pencadangan otomatis diaktifkan';

  @override
  String get automaticBackup => 'Pencadangan otomatis';

  @override
  String get appPermissions => 'Izin aplikasi';

  @override
  String get shareDatabase => 'Bagikan basis data';

  @override
  String get dataManagement => 'Pengelolaan data';

  @override
  String get strengthUnit => 'Satuan kekuatan';

  @override
  String get lastEntry => 'Entri terakhir';

  @override
  String get cardioUnit => 'Satuan kardio';

  @override
  String longDateFormat(String format) {
    return 'Format tanggal panjang ($format)';
  }

  @override
  String get formats => 'Format';

  @override
  String get setsPerExerciseMax => 'Set per latihan (maks: 20)';

  @override
  String get countLabel => 'Jumlah';

  @override
  String get ratioLabel => 'Rasio';

  @override
  String get reorder => 'Urutkan ulang';

  @override
  String get none => 'Tidak ada';

  @override
  String get monday => 'Senin';

  @override
  String get examplePlanExercises => 'Bench press, squat, dan deadlift';

  @override
  String get tabs => 'Tab';

  @override
  String get swipeBetweenTabs => 'Geser antar-tab';

  @override
  String get vibrate => 'Getar';

  @override
  String get enableSound => 'Aktifkan suara';

  @override
  String get keepScreenOn => 'Biarkan layar menyala';

  @override
  String get keepRinging => 'Terus berdering';

  @override
  String get alarmSound => 'Suara alarm';

  @override
  String get top => 'Atas';

  @override
  String get bottom => 'Bawah';

  @override
  String get removeCustomTimer =>
      'Hapus pewaktu khusus (gunakan default global)';

  @override
  String get timers => 'Pewaktu';

  @override
  String get timerSettings => 'Pengaturan pewaktu';

  @override
  String get groupHistory => 'Kelompokkan riwayat';

  @override
  String get showUnits => 'Tampilkan satuan';

  @override
  String get showBodyWeight => 'Tampilkan berat badan';

  @override
  String get showCategories => 'Tampilkan kategori';

  @override
  String get showNotes => 'Tampilkan catatan';

  @override
  String get durationEstimation => 'Perkiraan durasi';

  @override
  String get showGraphLimit => 'Tampilkan batas grafik';

  @override
  String get defaultGraphMetric => 'Metrik grafik default';

  @override
  String get bestWeight => 'Berat terbaik';

  @override
  String get bestReps => 'Repetisi terbaik';

  @override
  String get oneRepMax => 'Maksimum 1 repetisi';

  @override
  String get volume => 'Volume latihan';

  @override
  String get paceCardio => 'Laju (kardio)';

  @override
  String get distanceCardio => 'Jarak (kardio)';

  @override
  String get defaultGraphPeriod => 'Periode grafik default';

  @override
  String get defaultGraphLimit => 'Batas grafik default';

  @override
  String get workouts => 'Latihan';

  @override
  String get actionStop => 'Berhenti';

  @override
  String get timerFinishedToast => 'Pewaktu selesai!';

  @override
  String get stopTimer => 'Hentikan pewaktu';

  @override
  String get actionPause => 'Jeda';

  @override
  String get startStopwatch => 'Mulai stopwatch';

  @override
  String get actionStart => 'Mulai';

  @override
  String get actionRestart => 'Mulai ulang';

  @override
  String get addOneMinute => '+1 menit';

  @override
  String get addOneMinuteNotification => 'Tambah 1 menit';

  @override
  String get restTimer => 'Pewaktu istirahat';

  @override
  String get timerUp => 'Waktu habis';

  @override
  String get openNotification => 'Buka notifikasi';

  @override
  String get timerChannelName => 'Kanal pewaktu';

  @override
  String get timerChannelDescription =>
      'Menampilkan kemajuan pewaktu istirahat.';

  @override
  String get timerFinishedChannelName => 'Kanal pewaktu selesai';

  @override
  String get timerFinishedChannelDescription =>
      'Memutar alarm saat pewaktu istirahat selesai.';

  @override
  String get timerFinished => 'Pewaktu selesai';

  @override
  String get batteryOptimizationRequestUnavailable =>
      'Permintaan untuk mengabaikan pengoptimalan baterai tidak tersedia di perangkat Anda.';

  @override
  String get exactAlarmRequestUnavailable =>
      'Permintaan SCHEDULE_EXACT_ALARM ditolak pada perangkat Anda.';

  @override
  String get databaseMigrationFailureDescription =>
      'Terjadi kesalahan saat membuat atau memperbarui basis data. Biasanya hal ini dapat diperbaiki dengan menghapus lalu memulihkan catatan Anda.';

  @override
  String get curveSmoothness => 'Kehalusan kurva';

  @override
  String get actionBack => 'Kembali';

  @override
  String get atLeastOneTab => 'Anda memerlukan setidaknya satu tab';

  @override
  String get invalidTabSettings => 'Pengaturan tab tidak valid.';

  @override
  String get noSettingsFound => 'Tidak ada pengaturan yang ditemukan';

  @override
  String nothingMatchesSearch(String query) {
    return 'Tidak ada yang cocok dengan \"$query\".';
  }

  @override
  String get appearanceDescription => 'Tema, warna, dan tampilan antarmuka';

  @override
  String get dataManagementDescription =>
      'Impor, ekspor, dan kelola data latihan Anda';

  @override
  String get formatsDescription => 'Format tanggal, angka, dan pengukuran';

  @override
  String get plansSettingsDescription =>
      'Default dan perilaku untuk rencana latihan';

  @override
  String get tabsDescription => 'Pilih dan atur tab navigasi utama';

  @override
  String get timersDescription => 'Durasi istirahat, suara, dan perilaku';

  @override
  String get workoutsDescription => 'Preferensi pelacakan latihan dan gerakan';

  @override
  String get completeSetForChart =>
      'Selesaikan satu set untuk latihan ini agar grafik dapat dibuat.';

  @override
  String get dateRange => 'Rentang tanggal';

  @override
  String get stopDate => 'Tanggal akhir';

  @override
  String get dataPoints => 'Titik data';

  @override
  String get completeSetsForProgress =>
      'Selesaikan beberapa set untuk membuat grafik kemajuan Anda.';

  @override
  String get relativeStrength => 'Kekuatan relatif';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
      one: '1 dipilih',
    );
    return '$_temp0';
  }

  @override
  String get completeSetsForHistory =>
      'Selesaikan beberapa set untuk melihat riwayat latihan ini di sini.';

  @override
  String get completeSetForFirstGraph =>
      'Selesaikan satu set untuk membuat grafik latihan pertama Anda.';

  @override
  String nothingMatchesGraphSearch(String query) {
    return 'Tidak ada yang cocok dengan “$query”. Anda dapat membuatnya sebagai latihan baru.';
  }

  @override
  String addNamed(String name) {
    return 'Tambahkan “$name”';
  }

  @override
  String deleteGraphRecordsConfirmation(int count) {
    return 'Ini akan menghapus $count catatan. Anda yakin?';
  }

  @override
  String shareWorkout(String summary) {
    return 'Saya baru saja melakukan $summary';
  }

  @override
  String get updateConflict => 'Konflik pembaruan';

  @override
  String updateConflictDescription(int count) {
    return 'Nama baru Anda sudah digunakan oleh $count catatan. Anda yakin?';
  }

  @override
  String get unitsConflict => 'Konflik satuan';

  @override
  String unitsConflictDescription(String unit) {
    return 'Tidak semua catatan Anda menggunakan satuan yang sama. Semua satuan akan dikonversi ke $unit. Anda yakin?';
  }

  @override
  String get durationLabel => 'Durasi';

  @override
  String get inclineLabel => 'Kemiringan';

  @override
  String get paceDistanceTime => 'Laju (jarak / waktu)';

  @override
  String get adjustedPace => 'Laju yang disesuaikan';

  @override
  String get addPlan => 'Tambah rencana';

  @override
  String get planDetails => 'Rincian rencana';

  @override
  String get exercisesLabel => 'Latihan';

  @override
  String get addExerciseToPlan => 'Tambahkan latihan ke rencana ini.';

  @override
  String nothingMatchesExerciseSearch(String query) {
    return 'Tidak ada yang cocok dengan “$query”. Anda dapat menambahkannya sebagai latihan baru.';
  }

  @override
  String get selectDays => 'Pilih hari';

  @override
  String get selectExercises => 'Pilih latihan';

  @override
  String get todayLabel => 'Hari ini';

  @override
  String get setDetails => 'Detail set';

  @override
  String get themeLabel => 'Tema';

  @override
  String get pureBlackAmoledDescription =>
      'Gunakan warna hitam murni untuk layar AMOLED';

  @override
  String get systemColorScheme => 'Skema warna sistem';

  @override
  String get systemColorSchemeDescription =>
      'Gunakan warna utama perangkat Anda untuk aplikasi';

  @override
  String get showImagesDescription =>
      'Pilih atau tampilkan gambar di halaman Riwayat';

  @override
  String get showGlobalProgress => 'Tampilkan kemajuan global';

  @override
  String get showGlobalProgressDescription =>
      'Tambahkan entri grafik yang memetakan kemajuan Anda berdasarkan kategori';

  @override
  String get peekGraphDescription =>
      'Tampilkan grafik garis pertama di halaman Grafik';

  @override
  String get inputStyleDescription => 'Gaya visual kolom input teks';

  @override
  String get automaticBackupNotificationBody =>
      'Alpha akan mencadangkan data dan gambar Anda secara otomatis ke folder yang dipilih setiap hari.';

  @override
  String get backupSettingsChannel => 'Pengaturan cadangan';

  @override
  String get backupSettingsChannelDescription =>
      'Notifikasi yang menjelaskan pencadangan otomatis';

  @override
  String get backupChannelName => 'Kanal cadangan';

  @override
  String get backupChannelDescription =>
      'Pencadangan otomatis data dan gambar Alpha';

  @override
  String get backupCompletedTitle => 'Data dan gambar berhasil dicadangkan';

  @override
  String get backupFailurePathNotSet =>
      'Pencadangan gagal: lokasi cadangan belum diatur. Pencadangan otomatis dinonaktifkan.';

  @override
  String get backupFailureDirectoryUnavailable =>
      'Pencadangan gagal: direktori cadangan tidak dapat diakses. Pencadangan otomatis dinonaktifkan.';

  @override
  String get backupFailureCreateFile =>
      'Pencadangan gagal: berkas cadangan tidak dapat dibuat. Pencadangan otomatis dinonaktifkan.';

  @override
  String get backupFailureAppFilesUnavailable =>
      'Pencadangan gagal: direktori berkas aplikasi tidak dapat diakses. Pencadangan otomatis dinonaktifkan.';

  @override
  String get backupFailureDatabaseMissing =>
      'Pencadangan gagal: berkas basis data tidak ditemukan. Pencadangan otomatis dinonaktifkan.';

  @override
  String get backupFailureOutputUnavailable =>
      'Pencadangan gagal: aliran keluaran tidak dapat dibuka. Pencadangan otomatis dinonaktifkan.';

  @override
  String get backupFailureUnknown =>
      'Pencadangan gagal. Pencadangan otomatis dinonaktifkan.';

  @override
  String get appPermissionsDescription =>
      'Tinjau akses yang diperlukan oleh fitur yang Anda aktifkan';

  @override
  String get longDateFormatDescription =>
      'Digunakan saat ruang tersedia cukup luas';

  @override
  String shortDateFormat(String example) {
    return 'Format tanggal pendek ($example)';
  }

  @override
  String get shortDateFormatDescription =>
      'Digunakan saat ruang terbatas (garis grafik)';

  @override
  String get warmupSetsDescription =>
      'Set pemanasan tidak memiliki pewaktu istirahat';

  @override
  String get setsPerExerciseDescription =>
      'Jumlah latihan default dalam sebuah rencana';

  @override
  String get planTrailingDisplay => 'Tampilan sisi kanan rencana';

  @override
  String get planTrailingDisplayDescription =>
      'Informasi yang ditampilkan di sisi kanan daftar pada tampilan Rencana dan detail rencana';

  @override
  String get restTimersDescription =>
      'Alarm yang berbunyi setelah menyelesaikan satu set';

  @override
  String get vibrateDescription => 'Apakah pewaktu istirahat harus bergetar?';

  @override
  String get enableSoundDescription =>
      'Apakah pewaktu istirahat harus memutar suara?';

  @override
  String get keepScreenOnDescription =>
      'Biarkan layar menyala selama pewaktu istirahat';

  @override
  String get keepRingingDescription =>
      'Ulangi suara alarm dan getaran sampai Anda membatalkannya';

  @override
  String get restDurationDescription =>
      'Berapa lama sebelum alarm istirahat berbunyi?';

  @override
  String get globalDefault => 'Default global';

  @override
  String get alarmSoundDescription =>
      'Musik yang diputar saat pewaktu istirahat berakhir';

  @override
  String get progressBarPosition => 'Posisi bilah kemajuan';

  @override
  String get progressBarPositionDescription =>
      'Di mana bilah kemajuan pewaktu istirahat ditempatkan?';

  @override
  String get perExerciseRestTimes => 'Waktu istirahat per latihan';

  @override
  String get perExerciseRestTimesDescription =>
      'Latihan ini memiliki durasi istirahat khusus';

  @override
  String get audioFeaturesUnavailable => 'Fitur audio tidak tersedia';

  @override
  String get groupHistoryDescription =>
      'Gabungkan entri riwayat berdasarkan hari';

  @override
  String get showUnitsDescription =>
      'Tampilkan km/mi dan kg/lb pada grafik, riwayat, dan rencana';

  @override
  String get showBodyWeightDescription =>
      'Aktifkan atau nonaktifkan pelacakan berat badan';

  @override
  String get showCategoriesDescription =>
      'Aktifkan atau nonaktifkan kategori latihan';

  @override
  String get showNotesDescription =>
      'Catat detail angkatan Anda dalam kolom teks';

  @override
  String get positiveReinforcement => 'Penguatan positif';

  @override
  String get positiveNotificationsDescription =>
      'Tampilkan pesan positif saat rekor baru tercapai';

  @override
  String get positiveMessagesEnabled =>
      'Pesan positif kini akan tampil seperti ini!';

  @override
  String get recordEncouragement01 => 'Kerja bagus! Kamu luar biasa.';

  @override
  String get recordEncouragement02 =>
      'Mantap, jagoan! Kemajuanmu menginspirasi.';

  @override
  String get recordEncouragement03 => 'Aku berlutut...';

  @override
  String get recordEncouragement04 => 'Apa itu? Rekor baru!';

  @override
  String get recordEncouragement05 =>
      'Luar biasa! Kamu benar-benar menginspirasi.';

  @override
  String get recordEncouragement06 => 'Wow. Mantap.';

  @override
  String get recordEncouragement07 => 'Makin kuat, ya?';

  @override
  String get recordEncouragement08 => 'Ya. Kamu makin besar dan kuat.';

  @override
  String get recordEncouragement09 => 'Hebat. Luar biasa.';

  @override
  String get recordEncouragement10 => 'Arnie pasti bangga.';

  @override
  String get recordEncouragement11 => 'Ronnie C melihatmu dengan bangga.';

  @override
  String get recordEncouragement12 => 'YEAH! RINGAN BANGET, BABY!!!!!!!';

  @override
  String get recordEncouragement13 => 'Rekor baru? Sudah kuduga kamu bisa.';

  @override
  String get recordEncouragement14 => 'Kerja bagus! Aku bangga padamu.';

  @override
  String get recordEncouragement15 => 'YEAH BABY! Ringan banget!';

  @override
  String get recordEncouragement16 => 'Teruskan! Kemajuanmu hebat.';

  @override
  String get recordEncouragement17 => 'Kamu melakukannya dengan sangat baik.';

  @override
  String get recordEncouragement18 => 'Nah, begitu dong!';

  @override
  String get recordEncouragement19 => 'Teruskan.';

  @override
  String get recordEncouragement20 => 'Kamu makin kuat.';

  @override
  String get recordEncouragement21 => 'Kuat.';

  @override
  String get recordEncouragement22 => 'Kuat sekali!';

  @override
  String get recordEncouragement23 => 'Aku bangga padamu.';

  @override
  String get recordEncouragement24 => 'Pertahankan kerja hebat ini.';

  @override
  String get recordEncouragement25 =>
      'Berdiri tegak! Kamu baru saja mencetak rekor baru.';

  @override
  String get recordEncouragement26 =>
      'Rekor baru! Kamu baru saja melampaui pencapaian sebelumnya!';

  @override
  String get recordEncouragement27 => 'Yap! Itu rekor.';

  @override
  String get recordEncouragement28 => 'Wow! Rekor baru!';

  @override
  String get recordEncouragement29 => 'Bagus sekali.';

  @override
  String get durationEstimationDescription =>
      'Coba perkirakan durasi kardio Anda';

  @override
  String get showGraphXAxisToggle => 'Tampilkan tombol sumbu X grafik';

  @override
  String get showGraphXAxisToggleDescription =>
      'Tampilkan tombol sumbu X berbasis waktu pada grafik';

  @override
  String get showGraphLimitDescription =>
      'Tampilkan penggeser batas pada grafik';

  @override
  String get defaultTimeBasedXAxis => 'Sumbu X berbasis waktu secara default';

  @override
  String get defaultTimeBasedXAxisDescription =>
      'Gunakan sumbu X berbasis waktu secara default pada grafik';

  @override
  String get createFirstTrainingPlan =>
      'Buat rencana latihan pertama Anda untuk memulai.';

  @override
  String nothingMatchesPlanSearch(String query) {
    return 'Tidak ada yang cocok dengan “$query”. Anda dapat membuatnya sebagai rencana baru.';
  }

  @override
  String get createPlan => 'Buat rencana';

  @override
  String createNamedPlan(String name) {
    return 'Buat \"$name\"';
  }

  @override
  String setNumber(int number) {
    return 'Set ke-$number';
  }

  @override
  String get tabStart => 'Mulai';

  @override
  String get tabTraining => 'Latihan';

  @override
  String get tabExercises => 'Gerakan';

  @override
  String get tabProfile => 'Profil';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String dayStreak(int count) {
    return '$count hari berturut-turut';
  }

  @override
  String weekStreak(int count) {
    return '$count minggu berturut-turut';
  }

  @override
  String get thisWeek => 'Minggu ini';

  @override
  String get bodyWeightChart => 'Berat badan';

  @override
  String get strengthChart => 'Kekuatan';

  @override
  String get weeklyVolumeChart => 'Volume mingguan';

  @override
  String get noChartData => 'Data masih kurang';

  @override
  String get newTemplate => 'Templat baru';

  @override
  String get templateLimit => 'Kamu bisa menyimpan hingga 7 templat.';

  @override
  String get templatesEmpty => 'Templat ini belum berisi gerakan.';

  @override
  String get allMuscles => 'Semua';

  @override
  String get noHistory => 'Belum ada riwayat';

  @override
  String bestOneRepMax(String value) {
    return '1RM perkiraan $value kg';
  }

  @override
  String bestLoad(String value) {
    return 'Beban terbaik $value kg';
  }

  @override
  String get profileName => 'Nama';

  @override
  String get heightCm => 'Tinggi (cm)';

  @override
  String get ageOptional => 'Usia (opsional)';

  @override
  String get goals => 'Tujuan';

  @override
  String get bodyData => 'Data tubuh';

  @override
  String get addBodyWeight => 'Tambah berat';

  @override
  String get weightKg => 'Berat (kg)';

  @override
  String get aiCoaching => 'Pelatihan AI';

  @override
  String get apiKey => 'Kunci API';

  @override
  String get apiKeyStoredLocally =>
      'Hanya tersimpan di ponsel ini. Belum dipakai.';

  @override
  String get profileSaved => 'Profil disimpan';

  @override
  String get noTrainingThisDay => 'Tidak ada catatan pada hari ini';

  @override
  String targetSets(int count) {
    return '$count set';
  }

  @override
  String repRangeLabel(String range) {
    return '$range rep';
  }

  @override
  String get repMinLabel => 'Rep dari';

  @override
  String get repMaxLabel => 'Rep sampai';

  @override
  String get exerciseDatabaseCreditTitle => 'Pustaka gerakan';

  @override
  String get exerciseDatabaseCreditBody =>
      'Nama dari free-exercise-db oleh yuhonas, Unlicense (domain publik). Alpha menambahkan nama dan alias.';

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
  String get finishWorkoutAsk => 'Selesaikan latihan ini?';

  @override
  String get finishWorkoutBody => 'Sesi disimpan dan templat tidak berubah.';

  @override
  String get discardWorkoutAsk => 'Buang latihan ini?';

  @override
  String get discardWorkoutBody => 'Set yang tercatat pada sesi ini dihapus.';

  @override
  String get noRest => 'Tanpa istirahat';

  @override
  String get restWheelTitle => 'Istirahat';

  @override
  String get deleteTemplateAsk => 'Hapus templat ini?';

  @override
  String deleteTemplateBody(String name) {
    return 'Hapus “$name”? Latihan tersimpan tetap ada.';
  }

  @override
  String get warmupAction => 'Pemanasan';

  @override
  String get warmupMark => 'W';

  @override
  String get confirmAddExercise => 'Tambah gerakan';

  @override
  String get tabOverview => 'Ringkasan';

  @override
  String get tabHistory => 'Riwayat';

  @override
  String get tabHowTo => 'Cara';

  @override
  String get primaryMuscleLabel => 'Otot utama';

  @override
  String get secondaryMuscleLabel => 'Otot pendukung';

  @override
  String get equipmentLabel => 'Peralatan';

  @override
  String get heaviestWeight => 'Beban terberat';

  @override
  String get estimatedOneRm => '1RM perkiraan';

  @override
  String get volumeChart => 'Volume latihan';

  @override
  String get recordsTitle => 'Rekor';

  @override
  String get weekGoal => 'Target minggu';

  @override
  String weekGoalProgress(int done, int goal) {
    return '$done dari $goal';
  }

  @override
  String startWorkoutNamed(String name) {
    return 'Mulai latihan · $name';
  }

  @override
  String get musclesThisWeek => 'Otot minggu ini';

  @override
  String get progressHeading => 'Kemajuan';

  @override
  String get lastEightWeeks => 'Delapan minggu terakhir';

  @override
  String get chooseProfile => 'Pilih profil';

  @override
  String get createProfileAction => 'Buat profil';

  @override
  String get plateCalculator => 'Kalkulator piringan';

  @override
  String get barbellCalc => 'Barbel';

  @override
  String get cableCalc => 'Menara kabel';

  @override
  String get extraWeight => 'Beban tambahan';

  @override
  String get barWeightLabel => 'Berat batang';

  @override
  String get plateSetLabel => 'Piringan per sisi';

  @override
  String get cableStepLabel => 'Langkah tumpukan';

  @override
  String get chooseGym => 'Pilih gym';

  @override
  String get gymsTitle => 'Daftar gym';

  @override
  String get newGym => 'Gym baru';

  @override
  String get progressionHelp => 'Bantuan progresi';

  @override
  String progressionAsk(String name, String weight, int reps) {
    return '$name: lain kali $weight kg dan mulai lagi dari $reps repetisi?';
  }

  @override
  String get actionAccept => 'Terima';

  @override
  String get actionReject => 'Tolak';

  @override
  String get importExportTitle => 'Impor dan ekspor data';

  @override
  String get importWorkouts => 'Impor latihan';

  @override
  String get importMeasurements => 'Impor pengukuran';

  @override
  String get exportAlphaData => 'Ekspor data Alpha';

  @override
  String get importPreviewTitle => 'Pratinjau impor';

  @override
  String importSummary(int workouts, int exercises) {
    return '$workouts latihan, $exercises gerakan';
  }

  @override
  String get templatesDetected => 'Templat yang terdeteksi';

  @override
  String get renameLabel => 'Ganti nama';

  @override
  String get mapExercise => 'Cocokkan gerakan';

  @override
  String get checkForUpdates => 'Periksa pembaruan';

  @override
  String get upToDate => 'Kamu sudah yang terbaru';

  @override
  String get updateCheckFailed => 'Pemeriksaan pembaruan gagal';

  @override
  String get licensesTitle => 'Lisensi';

  @override
  String get flexifyMitNotice =>
      'Flexify diterbitkan di bawah lisensi MIT. Copyright Brandon Dick.';

  @override
  String get exerciseDbNotice =>
      'Setiap latihan mencantumkan sumber dan lisensinya.';

  @override
  String get sourceLabel => 'Sumber';

  @override
  String get tipsLabel => 'Saran';

  @override
  String get imageSourceLabel => 'Sumber gambar';

  @override
  String get imageLicenseLabel => 'Lisensi gambar';

  @override
  String get muscleUpperChest => 'Dada atas';

  @override
  String get muscleFrontShoulder => 'Bahu depan';

  @override
  String get muscleSideShoulder => 'Bahu samping';

  @override
  String get muscleRearShoulder => 'Bahu belakang';

  @override
  String get muscleLatissimus => 'Latissimus';

  @override
  String get muscleUpperBack => 'Punggung atas';

  @override
  String get muscleTrapez => 'Trapesius';

  @override
  String get muscleLowerBack => 'Punggung bawah';

  @override
  String get muscleForearms => 'Lengan bawah';

  @override
  String get muscleRectus => 'Otot perut lurus';

  @override
  String get muscleObliques => 'Otot perut miring';

  @override
  String get muscleQuadriceps => 'Paha depan';

  @override
  String get muscleAdductors => 'Adduktor';

  @override
  String get muscleAbductors => 'Abduktor';

  @override
  String get muscleHipFlexors => 'Fleksor pinggul';

  @override
  String get alternativesLabel => 'Alternatif';

  @override
  String get aiCoachTitle => 'Pelatih AI';

  @override
  String get aiProviderLabel => 'Penyedia';

  @override
  String get aiOffNotice =>
      'Pelatih tetap mati sampai kamu menyimpan kunci sendiri.';

  @override
  String get coachHint => 'Tanya pelatih';

  @override
  String get voiceInput => 'Masukan suara';

  @override
  String voiceUnderstood(String text) {
    return 'Tertangkap: $text';
  }

  @override
  String get speechFailed => 'Masukan suara gagal';

  @override
  String get confirmVoiceSet => 'Terapkan set ini?';

  @override
  String get periodSession => 'Latihan ini';

  @override
  String get muscleMapTitle => 'Peta otot';

  @override
  String get frontView => 'Depan';

  @override
  String get backView => 'Belakang';

  @override
  String quoteKeepGoing(int done, int goal) {
    return '$done dari $goal sesi minggu ini. Lanjutkan.';
  }

  @override
  String quoteRemaining(int count) {
    return 'Sisa $count sesi minggu ini.';
  }

  @override
  String get quotePullDay => 'Hari tarik. Punggung dan bisep siap.';

  @override
  String get quotePushDay => 'Hari dorong. Dada, bahu, dan trisep.';

  @override
  String get quoteLegDay => 'Hari kaki. Paha, hamstring, dan bokong.';

  @override
  String versionAndLicenses(String version) {
    return 'Versi $version · Lisensi';
  }

  @override
  String get liveWorkoutLabel => 'Latihan berlangsung';

  @override
  String get muscleChest => 'Dada';

  @override
  String get muscleShoulders => 'Bahu';

  @override
  String get muscleBiceps => 'Bisep';

  @override
  String get muscleTriceps => 'Trisep';

  @override
  String get muscleAbs => 'Perut';

  @override
  String get muscleQuads => 'Paha depan';

  @override
  String get muscleCalves => 'Betis';

  @override
  String get muscleTraps => 'Trapesius';

  @override
  String get muscleBack => 'Punggung';

  @override
  String get muscleGlutes => 'Bokong';

  @override
  String get muscleHams => 'Paha belakang';

  @override
  String get weekGoalManual => 'Atur target minggu sendiri';

  @override
  String get sessionsPerWeek => 'Sesi per minggu';

  @override
  String get gymNameHint => 'Nama gym';

  @override
  String get coachProfileNote => 'Catatan pelatih';

  @override
  String get openPackageLicenses => 'Buka lisensi paket';

  @override
  String get lengthUnitLabel => 'Panjang tubuh';

  @override
  String get centimetersShort => 'Sentimeter (cm)';

  @override
  String get inchesShort => 'Inci (in)';

  @override
  String get heightInches => 'Tinggi (inci)';

  @override
  String get welcomeToAlpha => 'Selamat datang di Alpha';

  @override
  String get createProfileButton => 'Buat profil';

  @override
  String get onboardingWeightHint => 'Berat badan, opsional';
}
