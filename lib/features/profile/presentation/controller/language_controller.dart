import 'dart:ui';

import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/app_storage/app_auth_storage.dart';

import '../../../../component/app_storage/storage_key.dart';
import '../../data/language_model.dart' show Language;

class LanguageController extends GetxController {
  final RxString selectedLanguage = 'en'.obs;

  final RxList<Language> languages = <Language>[
    Language(
      name: 'English',
      code: 'en',
      flagAsset: "assets/images/english.png",
    ),
    Language(
      name: 'Russian',
      code: 'ru',
      flagAsset: 'assets/images/rusia.png',
    ),
    Language(
      name: 'Serbian',
      code: 'sr',
      flagAsset: 'assets/images/serbia.png',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Load the saved language when controller initializes
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    // Get the saved language from storage
    String? savedLanguage = AppAuthStorage().getValue(StorageKey.language) ?? "en";

    if (savedLanguage.isNotEmpty) {
      selectedLanguage.value = savedLanguage;
      print("Loaded saved language: $savedLanguage");
    } else {
      // If no language is saved, default to English and save it
      selectedLanguage.value = 'en';
      AppAuthStorage().setLanguageValue('en');
      print("No saved language found, defaulting to English");
    }
  }

  void selectLanguage(String langCode) {
    selectedLanguage.value = langCode;

    // Update app locale based on selection
    switch (langCode) {
      case 'ru':
        Get.updateLocale(const Locale("ru"));
        AppAuthStorage().setLanguageValue("ru");
        print("Selected Russian: ${AppAuthStorage().getValue(StorageKey.language)}");
        break;
      case 'sr':
        Get.updateLocale(const Locale("sr"));
        AppAuthStorage().setLanguageValue("sr");
        print("Selected Serbian: ${AppAuthStorage().getValue(StorageKey.language)}");
        break;
      default:
        Get.updateLocale(const Locale("en"));
        AppAuthStorage().setLanguageValue("en");
        print("Selected English: ${AppAuthStorage().getValue(StorageKey.language)}");
    }

    // Show confirmation with proper language name
    String languageName = _getLanguageName(langCode);
    /*Get.snackbar(
      'Language Changed',
      'Language changed to $languageName',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );*/
  }

  String _getLanguageName(String langCode) {
    switch (langCode) {
      case 'ru':
        return 'Russian';
      case 'sr':
        return 'Serbian';
      default:
        return 'English';
    }
  }

  bool isSelected(String langCode) {
    return selectedLanguage.value == langCode;
  }

  // Optional: Method to get current language name
  String get currentLanguageName {
    return _getLanguageName(selectedLanguage.value);
  }

  // Optional: Method to get current language object
  Language? get currentLanguage {
    return languages.firstWhereOrNull(
          (language) => language.code == selectedLanguage.value,
    );
  }
}