// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'QuizAIPro';

  @override
  String get loading => 'Yuklanmoqda...';

  @override
  String get retry => 'Qayta urining';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get save => 'Saqlash';

  @override
  String get delete => 'O\'chirish';

  @override
  String get confirm => 'Tasdiqlash';

  @override
  String get back => 'Orqaga';

  @override
  String get done => 'Tayyor';

  @override
  String get next => 'Keyingi';

  @override
  String get skip => 'O\'tkazib yuborish';

  @override
  String get errorGeneric => 'Xatolik yuz berdi. Qayta urining.';

  @override
  String get errorNetwork => 'Internet aloqasi yo\'q.';

  @override
  String get errorUnauthorized => 'Sessiya tugadi. Qayta kiring.';

  @override
  String get errorRateLimited => 'Ko\'p so\'rovlar yuborildi. Bir oz kuting.';

  @override
  String get authWelcomeTitle => 'AI bilan aqlli o\'rganing';

  @override
  String get authWelcomeSubtitle => 'Sizga moslashadigan AI-kartochkalar.';

  @override
  String get authLogin => 'Kirish';

  @override
  String get authRegister => 'Hisob yaratish';

  @override
  String get authContinueWithGoogle => 'Google orqali kirish';

  @override
  String get authContinueWithApple => 'Apple orqali kirish';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Parol';

  @override
  String get authForgotPassword => 'Parolni unutdingizmi?';

  @override
  String get authLogout => 'Chiqish';

  @override
  String get authLoginTitle => 'Xush kelibsiz';

  @override
  String get authLoginSubtitle => 'O\'qishni davom ettirish uchun kiring';

  @override
  String get authRegisterTitle => 'Hisob yaratish';

  @override
  String get authRegisterSubtitle => 'AI o\'rganish yo\'lingizni boshlang';

  @override
  String get authUsername => 'Foydalanuvchi nomi';

  @override
  String get authUsernamePlaceholder => 'sizning_nikingiz';

  @override
  String get authEmailPlaceholder => 'sizning@email.com';

  @override
  String get authIdentifier => 'Email yoki login';

  @override
  String get authIdentifierPlaceholder => 'email yoki foydalanuvchi nomi';

  @override
  String get authPasswordPlaceholder => 'Kamida 8 ta belgi';

  @override
  String get authConfirmPassword => 'Parolni tasdiqlang';

  @override
  String get authConfirmPasswordPlaceholder => 'Parolni takrorlang';

  @override
  String get authPasswordHintLogin => 'Parolingiz';

  @override
  String get authConfirmPasswordRequired => 'Iltimos, parolni tasdiqlang';

  @override
  String get authGetStarted => 'Boshlash';

  @override
  String get authAlreadyHaveAccount => 'Hisobim allaqachon bor';

  @override
  String get authOrContinueWith => 'yoki davom eting';

  @override
  String get authSignIn => 'Kirish';

  @override
  String get authCreateAccount => 'Hisob yaratish';

  @override
  String get authNoAccount => 'Hisobingiz yo\'qmi? ';

  @override
  String get authSignUp => 'Ro\'yxatdan o\'tish';

  @override
  String get authHaveAccount => 'Hisobingiz bormi? ';

  @override
  String get authSignInLink => 'Kirish';

  @override
  String get authTermsNotice =>
      'Hisob yaratib, siz\nFoydalanish shartlari va Maxfiylik siyosatiga rozisiz.';

  @override
  String get authPasswordStrengthWeak => 'Zaif';

  @override
  String get authPasswordStrengthFair => 'O\'rta';

  @override
  String get authPasswordStrengthStrong => 'Kuchli';

  @override
  String get authPasswordStrengthVeryStrong => 'Juda kuchli';

  @override
  String validationRequired(String field) {
    return '$field majburiy';
  }

  @override
  String get validationEmail => 'To\'g\'ri email kiriting';

  @override
  String get validationPasswordMin =>
      'Parol kamida 8 ta belgidan iborat bo\'lishi kerak';

  @override
  String get validationPasswordsNoMatch => 'Parollar mos kelmadi';

  @override
  String get validationUsernameMin =>
      'Foydalanuvchi nomi kamida 3 ta belgi bo\'lishi kerak';

  @override
  String get validationUsernameMax =>
      'Foydalanuvchi nomi ko\'pi bilan 20 ta belgi bo\'lishi kerak';

  @override
  String get validationUsernameChars =>
      'Faqat harflar, raqamlar va pastki chiziq';

  @override
  String get errorUnexpected => 'Kutilmagan xatolik yuz berdi.';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navLibrary => 'Kutubxona';

  @override
  String get navDiscover => 'Bozor';

  @override
  String get navArena => 'Arena';

  @override
  String get navProfile => 'Profil';

  @override
  String get arenaComingSoon => 'Arena — tez orada';

  @override
  String get profileComingSoon => 'Profil — tez orada';

  @override
  String get homeComingSoon => 'Bosh sahifa — tez orada';

  @override
  String get discoverTitle => 'Kashf etish';

  @override
  String get discoverComingSoon => 'Kashf etish — tez orada';

  @override
  String get duelComingSoon => 'Duel — tez orada';

  @override
  String get liveTestComingSoon => 'Jonli test — tez orada';

  @override
  String get notificationsComingSoon => 'Bildirishnomalar — tez orada';

  @override
  String homeStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString kunlik seriya';
  }

  @override
  String get dashboardStreakDay => 'kunlik seriya';

  @override
  String dashboardStreakBest(int count) {
    return 'Eng yaxshi: $count kun';
  }

  @override
  String get dashboardStreakToday => 'Bugun';

  @override
  String get dashboardStreakDone => 'Bajarildi!';

  @override
  String dashboardCardsLeft(int count) {
    return '$count ta karta qoldi';
  }

  @override
  String homeDueCards(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString ta kartochka takrorlash kerak';
  }

  @override
  String get studyStart => 'O\'qishni boshlash';

  @override
  String studyCardOf(int current, int total) {
    return '$current / $total';
  }

  @override
  String get tutorAskPlaceholder => 'Mavzu bo\'yicha savol bering...';

  @override
  String get settingsTheme => 'Mavzu';

  @override
  String get settingsThemeLight => 'Yorug\'';

  @override
  String get settingsThemeDark => 'Qorong\'u';

  @override
  String get settingsThemeSystem => 'Tizim';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get settingsDailyGoal => 'Kunlik maqsad';

  @override
  String settingsDailyGoalCards(int count) {
    return 'Kuniga $count ta kartochka';
  }

  @override
  String get dashboardGreetingMorning => 'Xayrli tong,';

  @override
  String get dashboardGreetingAfternoon => 'Xayrli kun,';

  @override
  String get dashboardGreetingEvening => 'Xayrli kech,';

  @override
  String get dashboardDailyGoal => 'Kunlik maqsad';

  @override
  String get dashboardDailyGoalCompleted => 'Maqsadga erishdingiz!';

  @override
  String get dashboardRetention => 'Eslab qolish';

  @override
  String get dashboardRetentionForecast => 'bir haftadan keyin';

  @override
  String get dashboardRetentionFading => 'so\'nmoqda';

  @override
  String get dashboardRetentionInfo =>
      'Eslab qolish — o\'rganganingizning qancha qismini hozir eslayotganingizni ko\'rsatadi; buni FSRS algoritmi har bir karta xotira barqarorligi va oxirgi takrordan o\'tgan vaqt bo\'yicha hisoblaydi. «Bir haftadan keyin» — takrorlamasangiz bo\'ladigan prognoz. «So\'nmoqda» — siz unutib borayotgan kartalar; avval ularni takrorlash uchun kartani bosing.';

  @override
  String get dashboardReadyToStudy => 'O\'rganishga tayyor';

  @override
  String get dashboardAllCaughtUp => 'Hammasi tugallandi! 🎉';

  @override
  String dashboardXpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String dashboardXpToNextLevel(int xp, int nextLevel) {
    return '$nextLevel-daraja uchun $xp XP';
  }

  @override
  String dashboardLevelBadge(int level) {
    return '$level-daraja';
  }

  @override
  String get dashboardOverdue => 'muddati o\'tgan';

  @override
  String get dashboardStartStudying => 'Boshlash';

  @override
  String get dashboardQuickActions => 'Tezkor amallar';

  @override
  String get dashboardActionStudy => 'O\'qish';

  @override
  String get dashboardActionDiscover => 'Bozor';

  @override
  String get dashboardActionAiTutor => 'Murabbiy';

  @override
  String get dashboardActionAiStudio => 'Studiya';

  @override
  String get dashboardRecentActivity => 'So\'nggi faollik';

  @override
  String get dashboardActivityEmpty =>
      'Hozircha faollik yo\'q. O\'qishni boshlang!';

  @override
  String dashboardActivitySummary(int count, String time) {
    return '$count ta karta · $time';
  }

  @override
  String dashboardTimeAgoMinutes(int minutes) {
    return '$minutes daq oldin';
  }

  @override
  String dashboardTimeAgoHours(int hours) {
    return '$hours soat oldin';
  }

  @override
  String dashboardTimeAgoDays(int days) {
    return '$days kun oldin';
  }

  @override
  String dashboardXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get dashboardActivityTypeStudy => 'Mashg\'ulot sessiyasi';

  @override
  String get dashboardActivityTypeTest => 'Test yakunlandi';

  @override
  String get dashboardActivityTypeDuel => 'Duel';

  @override
  String get dashboardActivityTypeAiTutor => 'AI O\'qituvchi sessiyasi';

  @override
  String get marketplaceTitle => 'Bozor';

  @override
  String get marketplaceTabExplore => 'Ko\'rish';

  @override
  String get marketplaceTabCollections => 'To\'plamlar';

  @override
  String get marketplaceTabPaths => 'Yo\'llar';

  @override
  String get marketplaceSearchHint => 'Dastalar qidirish...';

  @override
  String get marketplaceFilterSort => 'Saralash';

  @override
  String get marketplaceFilterDifficulty => 'Daraja';

  @override
  String get marketplaceFilterProOnly => 'Faqat Pro-dastalar';

  @override
  String get marketplaceFilterApply => 'Qo\'llash';

  @override
  String get marketplaceFilterReset => 'Tiklash';

  @override
  String get marketplaceFilterAllSubjects => 'Barcha mavzular';

  @override
  String get marketplaceNoDecks => 'Dasta topilmadi. Filtrlarni o\'zgartiring.';

  @override
  String get marketplaceNoCollections => 'Hozircha to\'plamlar yo\'q.';

  @override
  String get marketplaceNoPaths => 'Hozircha o\'quv yo\'llari yo\'q.';

  @override
  String get marketplaceEnroll => 'Yozilganlar';

  @override
  String get marketplaceDeckAbout => 'Dasta haqida';

  @override
  String get marketplaceDeckPreview => 'Kartochkalarni ko\'rish';

  @override
  String get marketplaceDeckClone => 'Kutubxonaga qo\'shish';

  @override
  String get marketplaceDeckAlreadyCloned => 'Allaqachon kutubxonangizda';

  @override
  String get marketplaceCards => 'Kartochkalar';

  @override
  String get marketplaceRating => 'Reyting';

  @override
  String get marketplaceReviews => 'Sharhlar';

  @override
  String get marketplaceRateThis => 'Toplamni baholang';

  @override
  String get marketplaceReviewHint => 'Taassurotingizni yozing (ixtiyoriy)';

  @override
  String get marketplaceSubmitReview => 'Yuborish';

  @override
  String get marketplaceUpdateReview => 'Yangilash';

  @override
  String get marketplaceReportReview => 'Shikoyat';

  @override
  String get marketplaceNoReviews =>
      'Hozircha sharhlar yo\'q — birinchi bo\'ling!';

  @override
  String get marketplaceNoRatings => 'Baholar yo\'q';

  @override
  String get marketplaceYou => 'Siz';

  @override
  String get marketplaceClones => 'Nusxalar';

  @override
  String get marketplaceLikes => 'Yoqtirishlar';

  @override
  String get marketplaceCardFront => 'Old tomon';

  @override
  String get marketplaceCardBack => 'Orqa tomon';

  @override
  String get marketplaceSearchIdle =>
      'Dastalar, mavzular yoki mualliflarni qidiring.';

  @override
  String get marketplaceSearchEmpty =>
      'Hech narsa topilmadi. Boshqa so\'rov kiriting.';

  @override
  String get marketplaceSortPopular => 'Ommabop';

  @override
  String get marketplaceSortNewest => 'Yangi';

  @override
  String get marketplaceSortRating => 'Yuqori reytingli';

  @override
  String get marketplaceSortAlphabetical => 'A–Z';

  @override
  String marketplaceCardCount(int count) {
    return '$count ta karta';
  }

  @override
  String marketplaceDeckCount(int count) {
    return '$count ta dasta';
  }

  @override
  String marketplaceHours(int hours) {
    return '${hours}s';
  }

  @override
  String get marketplaceProBadge => 'PRO';

  @override
  String get libraryTitle => 'Mening kutubxonam';

  @override
  String get libraryTabDecks => 'Dastalar';

  @override
  String get libraryTabCollections => 'To\'plamlar';

  @override
  String get libraryTabFavorites => 'Sevimlilar';

  @override
  String get librarySearchHint => 'Kutubxonada qidirish...';

  @override
  String get libraryRecentDecks => 'Yaqinda o\'rganilganlar';

  @override
  String get librarySortTitle => 'Saralash';

  @override
  String get librarySortDateAdded => 'Qo\'shilgan sana';

  @override
  String get librarySortName => 'Nomi (A–Z)';

  @override
  String get librarySortRecent => 'Yaqinda o\'rganilganlar';

  @override
  String get librarySortCardCount => 'Kartochkalar soni';

  @override
  String get librarySortDueCards => 'Takrorlash kerak';

  @override
  String get libraryFilter => 'Filtr';

  @override
  String get libraryFilterApply => 'Qo\'llash';

  @override
  String get libraryFilterReset => 'Tiklash';

  @override
  String get libraryFilterDifficulty => 'Daraja';

  @override
  String get libraryFilterArchived => 'Arxivlanganlarni ko\'rsatish';

  @override
  String get libraryFilterDueOnly => 'Faqat takrorlash kerak';

  @override
  String get libraryFilterDifficultyAny => 'Har qanday';

  @override
  String get libraryFilterDifficultyBeginner => 'Boshlang\'ich';

  @override
  String get libraryFilterDifficultyIntermediate => 'O\'rta';

  @override
  String get libraryFilterDifficultyAdvanced => 'Murakkab';

  @override
  String get libraryNoDecks => 'Hozircha dasta yo\'q. Bozordan klon qiling.';

  @override
  String get libraryNoCollections => 'Hozircha to\'plamlar yo\'q.';

  @override
  String get libraryNoFavorites =>
      'Hozircha sevimlilar yo\'q. Dastani sevimlilarga qo\'shing.';

  @override
  String get libraryActionStudy => 'O\'qish';

  @override
  String get libraryActionFavorite => 'Sevimlilarga qo\'shish';

  @override
  String get libraryActionUnfavorite => 'Sevimlilardan olib tashlash';

  @override
  String get libraryActionArchive => 'Arxivlash';

  @override
  String get libraryActionUnarchive => 'Arxivdan chiqarish';

  @override
  String get libraryActionDelete => 'O\'chirish';

  @override
  String get libraryFavoriteAdded => 'Sevimlilarga qo\'shildi';

  @override
  String get libraryFavoriteRemoved => 'Sevimlilardan olib tashlandi';

  @override
  String get libraryArchived => 'Dasta arxivlandi';

  @override
  String get libraryUnarchived => 'Dasta arxivdan chiqarildi';

  @override
  String get libraryDeleted => 'Dasta o\'chirildi';

  @override
  String get libraryDeleteTitle => 'Dastani o\'chirish';

  @override
  String libraryDeleteConfirm(String title) {
    return '\"$title\" ni o\'chirmoqchimisiz? Bu amalni bekor qilib bo\'lmaydi.';
  }

  @override
  String get librarySearchIdle => 'Kutubxonangizni qidirish uchun yozing.';

  @override
  String get librarySearchEmpty => 'Kutubxonangizda dasta topilmadi.';

  @override
  String libraryDueCount(int count) {
    return '$count ta takrorlash';
  }

  @override
  String get libraryDeckDetailDue => 'Takrorlanadigan';

  @override
  String get libraryDeckDetailTest => 'Test';

  @override
  String get libraryDeckDetailNotFound => 'Dasta topilmadi';

  @override
  String get libraryDeckDetailNoCards => 'Bu dastada hozircha kartalar yo\'q.';

  @override
  String get commonEdit => 'Tahrirlash';

  @override
  String get commonGotIt => 'Tushunarli';

  @override
  String get libraryDeckEditTooltip => 'Toplamni tahrirlash';

  @override
  String get libraryDeckDeleteTooltip => 'Toplamni o\'chirish';

  @override
  String get libraryDeckAddCard => 'Qo\'shish';

  @override
  String get cardTileQuizChip => 'Test';

  @override
  String get cardTileFlashcardChip => 'Fleshkarta';

  @override
  String get cardTileShowOptions => 'Variantlar';

  @override
  String get cardTileHideOptions => 'Variantlarni yashirish';

  @override
  String get cardTileShowAnswer => 'Javobni ko\'rsatish';

  @override
  String get cardTileHideAnswer => 'Javobni yashirish';

  @override
  String get cardTileExplanation => 'IZOH';

  @override
  String get deckNoTestsTitle => 'Bu toplamda testlar yo\'q';

  @override
  String get deckNoTestsBody =>
      'Test topshirish uchun javob variantli (A, B, C…) kartalar qo\'shing.';

  @override
  String get deckNoFlashcardsTitle => 'Bu toplamda fleshkartalar yo\'q';

  @override
  String get deckNoFlashcardsBody =>
      'Bu toplamni o\'rganishni boshlash uchun fleshkartalar qo\'shing.';

  @override
  String get deckDeleteTitle => 'Toplam o\'chirilsinmi?';

  @override
  String get deckDeleteBody =>
      'Toplam va uning barcha kartalari butunlay o\'chiriladi.';

  @override
  String get deckDeleteFailed => 'Toplamni o\'chirib bo\'lmadi';

  @override
  String get cardDeleteTitle => 'Karta o\'chirilsinmi?';

  @override
  String get cardDeleteBody => 'Bu amalni qaytarib bo\'lmaydi.';

  @override
  String get cardDeleteFailed => 'Kartani o\'chirib bo\'lmadi';

  @override
  String get libraryNewDeckFab => 'Toplam';

  @override
  String get cardEditorTitleNew => 'Yangi savol';

  @override
  String get cardEditorTitleEdit => 'Savolni tahrirlash';

  @override
  String get cardEditorQuestionLabel => 'Savol';

  @override
  String get cardEditorQuestionHint => 'Savol kiriting…';

  @override
  String get cardEditorOptionsLabel => 'Javob variantlari';

  @override
  String get cardEditorMarkCorrect => 'To\'g\'ri variantni belgilang';

  @override
  String get cardEditorAddOption => 'Variant qo\'shish';

  @override
  String cardEditorMaxOptions(int count) {
    return 'Ko\'pi bilan $count';
  }

  @override
  String cardEditorOptionHint(String letter) {
    return 'Variant $letter';
  }

  @override
  String get cardEditorExplanationLabel => 'Izoh (ixtiyoriy)';

  @override
  String get cardEditorExplanationHint => 'Nega bu javob to\'g\'ri…';

  @override
  String get cardEditorErrorQuestion => 'Savol kiriting';

  @override
  String cardEditorErrorMinOptions(int count) {
    return 'Kamida $count ta variant qo\'shing';
  }

  @override
  String get cardEditorErrorMarkCorrect =>
      'To\'g\'ri variantni belgilang (u bo\'sh bo\'lmasligi kerak)';

  @override
  String get cardEditorErrorSave => 'Saqlab bo\'lmadi. Aloqani tekshiring.';

  @override
  String get deckEditorTitleNew => 'Yangi toplam';

  @override
  String get deckEditorErrorName => 'Toplam nomini kiriting';

  @override
  String get deckEditorNameLabel => 'Nomi';

  @override
  String get deckEditorColorLabel => 'To\'plam rangi';

  @override
  String get deckEditorNameHint => 'Masalan: O\'zbekiston tarixi';

  @override
  String get deckEditorDescLabel => 'Tavsif (ixtiyoriy)';

  @override
  String get deckEditorCreate => 'Yaratish';

  @override
  String levelXpToNext(int xp, int level) {
    return '$level-darajagacha $xp XP';
  }

  @override
  String get levelUpNewLevel => 'YANGI DARAJA!';

  @override
  String get levelUpEncouragement =>
      'Ajoyib ketyapsiz! Keyingi bosqichni ochish uchun shu ruhda davom eting.';

  @override
  String get levelUpGreat => 'ZO\'R';

  @override
  String get levelJourneyLoadError => 'Darajalar shkalasini yuklab bo\'lmadi.';

  @override
  String get levelJourneyRewardsRoad => 'MUKOFOTLAR YO\'LI';

  @override
  String levelJourneyMilestone(int level) {
    return '$level-daraja bosqichi';
  }

  @override
  String get levelJourneyXpHistory => 'XP TARIXI';

  @override
  String get levelJourneyXpHistoryEmpty => 'XP tarixi bo\'sh.';

  @override
  String levelJourneyLevel(int level) {
    return '$level-daraja';
  }

  @override
  String levelJourneyXpRemaining(int xp) {
    return '$xp XP qoldi';
  }

  @override
  String get levelJourneyTiers => 'DARAJALAR';

  @override
  String get levelJourneyTiersSubtitle =>
      'Daraja oshiring — yangi darajalarni oching';

  @override
  String get levelJourneyYouAreHere => 'SIZ SHU YERDA';

  @override
  String levelJourneyFromLevel(Object level) {
    return '$level-darajadan';
  }

  @override
  String get levelJourneyNextGoal => 'KEYINGI MAQSAD';

  @override
  String levelJourneyToLevel(Object level) {
    return '$level-darajagacha';
  }

  @override
  String get levelJourneyAllRewards =>
      'Barcha mukofotlar ochildi — siz cho\'qqidasiz!';

  @override
  String get levelTierBronze => 'Bronza';

  @override
  String get levelTierSilver => 'Kumush';

  @override
  String get levelTierGold => 'Oltin';

  @override
  String get levelTierPlatinum => 'Platina';

  @override
  String get levelTierMaster => 'Usta';

  @override
  String get levelTierLegend => 'Afsona';

  @override
  String get flashcardsAgain => 'Qayta';

  @override
  String get flashcardsHard => 'Qiyin';

  @override
  String get flashcardsGood => 'Yaxshi';

  @override
  String get flashcardsEasy => 'Oson';

  @override
  String get flashcardsCardFlip => 'Javobni ko\'rsatish';

  @override
  String get flashcardsCardFront => 'Old tomon';

  @override
  String get flashcardsCardBack => 'Orqa tomon';

  @override
  String get flashcardsModeSmart => 'Aqlli aralash';

  @override
  String get flashcardsModeNew => 'Yangi';

  @override
  String get flashcardsModeReview => 'Takrorlash';

  @override
  String get flashcardsModeDifficult => 'Qiyin';

  @override
  String get flashcardsModeFavorite => 'Sevimlilar';

  @override
  String get flashcardsModeFading => 'So\'nayotgan';

  @override
  String get flashcardsLoadError => 'Kartochkalarni yuklab bo\'lmadi';

  @override
  String get flashcardsQuit => 'Sessiyani tugatish';

  @override
  String get flashcardsQuitConfirm => 'Bu o\'quv sessiyasini tugatmoqchimisiz?';

  @override
  String get flashcardsQuitYes => 'Tugatish';

  @override
  String get flashcardsQuitNo => 'Davom etish';

  @override
  String get flashcardsSessionComplete => 'Sessiya tugadi!';

  @override
  String get flashcardsSessionStats => 'Natijalaringiz';

  @override
  String get flashcardsCardsStudied => 'O\'rganilgan kartochkalar';

  @override
  String get flashcardsNewCards => 'Yangi';

  @override
  String get flashcardsReviewCards => 'Takrorlash';

  @override
  String get flashcardsRetention => 'Eslab qolish';

  @override
  String get flashcardsTimeSpent => 'Sarflangan vaqt';

  @override
  String get flashcardsStudyAgain => 'Qayta o\'rganish';

  @override
  String get flashcardsBackToLibrary => 'Kutubxonaga qaytish';

  @override
  String get testsSetupTitle => 'Test sozlamalari';

  @override
  String get testsSetupSubtitle => 'Test parametrlarini sozlang';

  @override
  String get testsQuestionCount => 'Savollar soni';

  @override
  String get testsCountAll => 'Barchasi';

  @override
  String get testsShuffle => 'Savollarni aralashtirish';

  @override
  String get testsTimedMode => 'Vaqt rejimi';

  @override
  String get testsSecondsPerQuestion => 'Savol uchun soniyalar';

  @override
  String get testsStart => 'Testni boshlash';

  @override
  String get testsSubmit => 'Testni topshirish';

  @override
  String get testsNext => 'Keyingi';

  @override
  String get testsPrevious => 'Oldingi';

  @override
  String get testsQuitTitle => 'Testdan chiqish?';

  @override
  String get testsQuitMessage => 'Natijalar yo\'qoladi. Ishonchingiz komilmi?';

  @override
  String get testsQuitCancel => 'Bekor qilish';

  @override
  String get testsQuitConfirm => 'Chiqish';

  @override
  String get testsResultsTitle => 'Test natijalari';

  @override
  String get testsScoreExcellent => 'A\'lo!';

  @override
  String get testsScoreGreat => 'Zo\'r!';

  @override
  String get testsScoreGood => 'Yaxshi harakat';

  @override
  String get testsScorePractice => 'Mashq qilishda davom eting';

  @override
  String get testsScoreStudy => 'Ko\'proq o\'rganish kerak';

  @override
  String get testsCorrect => 'To\'g\'ri';

  @override
  String get testsWrong => 'Noto\'g\'ri';

  @override
  String get testsDuration => 'Vaqt';

  @override
  String get testsWeakAreas => 'Zaif tomonlar';

  @override
  String get testsReviewAnswers => 'Javoblarni ko\'rish';

  @override
  String get testsTryAgain => 'Qayta urinish';

  @override
  String get testsViewHistory => 'Test tarixini ko\'rish';

  @override
  String get testsReviewTitle => 'Javoblarni ko\'rish';

  @override
  String get testsDiagnoseButton => 'Nega xato qildim?';

  @override
  String get testsDiagnoseLoading => 'Tahlil qilinmoqda…';

  @override
  String get testsDiagnoseWhyWrong => 'Javobing nega noto\'g\'ri';

  @override
  String get testsDiagnoseWhyCorrect => 'To\'g\'ri javob nega to\'g\'ri';

  @override
  String get testsDiagnoseMisconception => 'Ehtimoliy xato tushuncha';

  @override
  String get testsDiagnoseTip => 'Qanday eslab qolish';

  @override
  String get testsDiagnoseError =>
      'Xatoni tahlil qilib bo\'lmadi. Keyinroq urining.';

  @override
  String get testsFollowupButton => 'Mustahkamlash: o\'xshash savol';

  @override
  String get testsFollowupCorrect => 'To\'g\'ri!';

  @override
  String get testsFollowupWrong => 'Noto\'g\'ri';

  @override
  String get testsFollowupError => 'Savol yaratib bo\'lmadi. Keyinroq urining.';

  @override
  String get testsHistoryTitle => 'Test tarixi';

  @override
  String get testsHistoryEmpty => 'Hali testlar yo\'q';

  @override
  String get testsHistoryEmptySubtitle =>
      'Natijalarni ko\'rish uchun test topshing';

  @override
  String get testsLoadError => 'Savollarni yuklashda xato';

  @override
  String get testsNoQuestions => 'Bu dastada test uchun savollar yo\'q.';

  @override
  String get testsHistoryLoadError => 'Tarixni yuklashda xato';

  @override
  String get testsRetry => 'Qayta urinish';

  @override
  String testsCorrectOfTotal(int correct, int total) {
    return '$total savoldan $correct ta to\'g\'ri';
  }

  @override
  String testsReviewQuestionOf(int current, int total) {
    return '$current-savol, $total tadan';
  }

  @override
  String testsSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String testsMinutesSecondsShort(int minutes, int seconds) {
    return '${minutes}d ${seconds}s';
  }

  @override
  String testsScoreFraction(int correct, int total) {
    return '$correct / $total to\'g\'ri';
  }

  @override
  String get tutorTitle => 'AI O\'qituvchi';

  @override
  String get tutorNewConversation => 'Yangi suhbat';

  @override
  String get tutorConversationTitle => 'Suhbat sarlavhasi';

  @override
  String get tutorCreate => 'Yaratish';

  @override
  String get tutorRenameTitle => 'Suhbatni qayta nomlash';

  @override
  String get tutorRename => 'Qayta nomlash';

  @override
  String get tutorNewTitle => 'Yangi nom';

  @override
  String get tutorDeleteTitle => 'Suhbatni o\'chirish?';

  @override
  String get tutorDeleteMessage =>
      'Bu suhbat va barcha xabarlar butunlay o\'chiriladi.';

  @override
  String get tutorPin => 'Mahkamlash';

  @override
  String get tutorUnpin => 'Mahkamlashni bekor qilish';

  @override
  String get tutorDelete => 'O\'chirish';

  @override
  String get tutorPinnedSection => 'Mahkamlangan';

  @override
  String get tutorConversationsSection => 'Suhbatlar';

  @override
  String get tutorEmpty => 'Hali suhbatlar yo\'q';

  @override
  String get tutorEmptySubtitle => 'AI o\'qituvchi bilan suhbat boshlang';

  @override
  String get tutorSearch => 'Suhbatlarni qidirish…';

  @override
  String tutorNoResults(String query) {
    return '\"$query\" bo\'yicha natija yo\'q';
  }

  @override
  String get tutorWithDeckContext => 'Dek konteksti bilan';

  @override
  String get tutorAskAnything => 'Har narsani so\'rang!';

  @override
  String get tutorWelcomeSubtitle =>
      'Men tushunchalarni tushuntira olaman, savollar bera olaman yoki kartochkalarni tushunishga yordam bera olaman.';

  @override
  String get tutorInputHint => 'AI o\'qituvchidan so\'rang…';

  @override
  String get tutorCopied => 'Buferga nusxalandi';

  @override
  String get tutorConnectionLost => 'Ulanish uzildi. Qayta urinib ko\'ring.';

  @override
  String get tutorLoadError => 'Suhbatlarni yuklab bo\'lmadi';

  @override
  String get tutorRetry => 'Qayta urinish';

  @override
  String get aiStudioTitle => 'AI Studiya';

  @override
  String get aiStudioTabGenerate => 'Yaratish';

  @override
  String get aiStudioTabFindAnswers => 'Javob topish';

  @override
  String get aiStudioHistory => 'Tarix';

  @override
  String get aiStudioSourceTopic => 'Mavzu';

  @override
  String get aiStudioSourceText => 'Matn';

  @override
  String get aiStudioSourcePdf => 'PDF';

  @override
  String get aiStudioTopicLabel => 'Mavzu';

  @override
  String get aiStudioTopicHint =>
      'Masalan: Fransuz inqilobi, Matematika, Inson tanasi…';

  @override
  String get aiStudioTextLabel => 'Matningizni yoping (kamida 50 belgi)';

  @override
  String get aiStudioTextHint =>
      'Maqola, darslik parchasi yoki istalgan matnni kiriting…';

  @override
  String get aiStudioPdfLabel => 'PDF yuklash';

  @override
  String get aiStudioPdfChoose => 'PDF faylni tanlang';

  @override
  String get aiStudioPdfReady => 'PDF tayyor';

  @override
  String get aiStudioCardCountLabel => 'Kartochkalar soni';

  @override
  String get aiStudioQualityLabel => 'Sifat';

  @override
  String get aiStudioQualityFast => 'Tez';

  @override
  String get aiStudioQualityBalanced => 'Muvozanatli';

  @override
  String get aiStudioQualityPremium => 'Premium';

  @override
  String get aiStudioQualityFastDescription => '~15 son';

  @override
  String get aiStudioQualityBalancedDescription => '~30 son';

  @override
  String get aiStudioQualityPremiumDescription => '~60 son · eng yaxshi sifat';

  @override
  String get aiStudioGenerate => 'Yaratish';

  @override
  String get aiStudioGenerating => 'Yaratilmoqda…';

  @override
  String get aiStudioFindAnswersHint =>
      'Masalan: Birinchi jahon urushining sababi nima?';

  @override
  String get aiStudioFindAnswersLabel => 'Istalgan savol bering';

  @override
  String get aiStudioAiAnswer => 'AI javobi';

  @override
  String get aiStudioKeyPoints => 'Asosiy fikrlar';

  @override
  String get aiProgressTitle => 'Yaratilmoqda…';

  @override
  String aiProgressFrom(String source) {
    return '$source dan yaratilmoqda';
  }

  @override
  String aiProgressQuality(int count, String quality) {
    return '$count kartochka · $quality sifat';
  }

  @override
  String get aiProgressFailed =>
      'Yaratish muvaffaqiyatsiz bo\'ldi. Qayta urinib ko\'ring.';

  @override
  String get aiProgressGoBack => 'Orqaga';

  @override
  String get aiResultsTitle => 'kartochka yaratildi';

  @override
  String get aiResultsTitleDefault => 'Natijalar';

  @override
  String aiResultsSelected(int selected, int total) {
    return '$total dan $selected tanlandi';
  }

  @override
  String get aiResultsSelectAll => 'Hammasini tanlash';

  @override
  String get aiResultsDeselectAll => 'Tanlovni bekor qilish';

  @override
  String get aiResultsNew => 'Yangi';

  @override
  String get aiResultsSaveToDeck => 'Dastaga saqlash';

  @override
  String get aiResultsCardsSaved => 'ta kartochka saqlandi!';

  @override
  String get aiResultsEmpty => 'Kartochkalar yaratilmadi.';

  @override
  String get aiResultsEmptySubtitle =>
      'Boshqa mavzu sinab ko\'ring yoki ko\'proq matn qo\'shing.';

  @override
  String get aiResultsTryAgain => 'Qayta urinish';

  @override
  String get aiHistoryTitle => 'Yaratish tarixi';

  @override
  String get aiHistoryEmpty => 'Hali yaratishlar yo\'q';

  @override
  String get aiHistoryEmptySubtitle =>
      'Kartochka yaratish tarixingiz bu yerda ko\'rinadi.';

  @override
  String aiSaveToDeck(int count) {
    return '$count ta kartochkani saqlash…';
  }

  @override
  String get aiSaveCreateNew => 'Yangi dasta yaratish';

  @override
  String get aiSaveDeckName => 'Dasta nomi';

  @override
  String get aiSaveSaveCards => 'Kartochkalarni saqlash';

  @override
  String get aiExplainTitle => 'AI tushuntirishi';

  @override
  String get aiExplainQuestion => 'Savol';

  @override
  String get aiExplainAnswer => 'Javob';

  @override
  String get aiExplainExplanation => 'Tushuntirish';

  @override
  String get aiExplainLoading => 'AI bu tushunchani tushuntirmoqda…';

  @override
  String get aiExplainRetry => 'Qayta urinish';

  @override
  String aiStudioCharCount(int count) {
    return '$count belgi';
  }

  @override
  String aiStudioCharCountNeedMore(int count, int more) {
    return '$count belgi (yana $more ta kerak)';
  }

  @override
  String get aiStudioStatusFailed => 'Xato';

  @override
  String get aiStudioStatusCancelled => 'Bekor qilindi';

  @override
  String get aiStudioStatusPending => 'Kutilmoqda';

  @override
  String get aiStudioStatusProcessing => 'Jarayonda';

  @override
  String aiStudioCardsCount(int count) {
    return '$count kartochka';
  }

  @override
  String get aiSaveErrorNoName => 'Dasta nomini kiriting.';

  @override
  String get aiSaveErrorNoDeck => 'Avval dastani tanlang.';

  @override
  String get streakEvolutionRoadmap => 'Evolyutsiya xaritasi';

  @override
  String get streakMilestoneAchievements => 'Seriyalar yutuqlari';

  @override
  String get streakConsistencyHistory => 'Faollik tarixi (oxirgi 30 kun)';

  @override
  String get streakClaimedRewardsHistory => 'Mukofotlar tarixi';

  @override
  String get streakActiveBadge => 'FAOL';

  @override
  String get streakMaximized => 'Afsonaviy daraxt to\'liq o\'sdi! 👑';

  @override
  String get streakNoRewards => 'Mukofotlar hali olinmagan.';

  @override
  String streakDaysRemaining(int count, String stage) {
    return '$stage bosqichigacha $count kun qoldi';
  }

  @override
  String streakGrowthStage(String stage) {
    return 'O\'sish bosqichi: $stage';
  }

  @override
  String streakCurrentDays(int count) {
    return '$count kunlik faol seriya';
  }

  @override
  String streakDayCount(int count) {
    return '$count kunlik seriya';
  }

  @override
  String get streakStageSeed => 'Urug\'';

  @override
  String get streakStageSprout => 'Nihol';

  @override
  String get streakStageYoungTree => 'Yosh daraxt';

  @override
  String get streakStageBloomingTree => 'Gullayotgan daraxt';

  @override
  String get streakStageAncientTree => 'Qadimiy daraxt';

  @override
  String get streakStageLegendaryTree => 'Afsonaviy daraxt';

  @override
  String get streakStageEternalTree => 'Abadiyat daraxti';

  @override
  String streakLastReward(String reward) {
    return 'Oxirgi mukofot: $reward';
  }

  @override
  String streakNextReward(String reward) {
    return 'Keyingi mukofot: $reward';
  }

  @override
  String get streakNoLastReward => 'Oxirgi mukofot: Yo\'q';

  @override
  String get streakMaxReward => 'Keyingi mukofot: Yo\'q (Maks. daraja)';

  @override
  String streakProgressDays(Object current, Object pct, Object target) {
    return '$current / $target kun ($pct%)';
  }

  @override
  String get streakTreeGrewTitle => 'Daraxtingiz o\'sdi!';

  @override
  String streakTreeGrewBody(String stage) {
    return 'Yangi bosqich: $stage. Shunday davom eting — har kuni kiring!';
  }

  @override
  String get streakTreeIntroTitle => 'Daraxtingiz o\'smoqda';

  @override
  String get streakTreeIntroBody =>
      'Har kuni kiring va maqsadingizni bajaring — daraxtingiz urug\'dan Abadiyat daraxtigacha o\'sadi.';

  @override
  String get streakTreeIntroCta => 'Batafsil';
}
