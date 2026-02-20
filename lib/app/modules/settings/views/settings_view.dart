import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'appearance'.tr,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Obx(
              () => SwitchListTile(
                title: Text('dark_mode'.tr),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: controller.isDarkMode.value,
                onChanged: controller.toggleTheme,
                activeColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'language'.tr,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _buildLanguageOption(
                  title: 'English',
                  code: 'en',
                  flag: '🇺🇸',
                ),
                const Divider(height: 1),
                _buildLanguageOption(
                  title: 'العربية',
                  code: 'ar',
                  flag: '🇸🇦',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String code,
    required String flag,
  }) {
    return Obx(
      () => RadioListTile<String>(
        title: Text('$flag $title'),
        value: code,
        groupValue: controller.currentLanguage.value,
        onChanged: (value) {
          if (value != null) controller.changeLanguage(value);
        },
        activeColor: AppColors.primary,
      ),
    );
  }
}
