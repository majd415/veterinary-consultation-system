import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_pages.dart';
import '../../data/services/api_service.dart';

class LanguageController extends GetxController {
  final RxString selectedLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language_code');
    if (savedLang != null) {
      selectedLanguage.value = savedLang;
      Get.updateLocale(Locale(savedLang));
    }
  }

  void selectLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    Get.updateLocale(Locale(languageCode));
  }

  Future<void> confirmLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', selectedLanguage.value);
    await prefs.setBool('is_first_run', false);

    // Sync with backend if user is logged in
    final token = prefs.getString('auth_token');
    if (token != null) {
      try {
        final apiService = Get.find<ApiService>();
        await apiService.updateProfile({'language': selectedLanguage.value});
      } catch (e) {
        print('Error syncing language with backend: $e');
      }
    }

    // Navigate to Onboarding after language selection
    Get.offAllNamed(Routes.ONBOARDING);
  }
}
