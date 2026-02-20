import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  var isDarkMode = false.obs;
  var currentLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    currentLanguage.value = prefs.getString('language') ?? 'en';

    // Apply theme
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme(bool value) async {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void changeLanguage(String lang) async {
    currentLanguage.value = lang;
    Get.updateLocale(Locale(lang));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }
}
