import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../language_controller.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo Placeholder (or Icon)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.language,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Choose Language',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Select your preferred language',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 50),

              // English Option
              Obx(
                () => _buildLanguageOption(
                  context,
                  title: 'English',
                  code: 'en',
                  isSelected: controller.selectedLanguage.value == 'en',
                ),
              ),

              const SizedBox(height: 16),

              // Arabic Option
              Obx(
                () => _buildLanguageOption(
                  context,
                  title: 'العربية',
                  code: 'ar',
                  isSelected: controller.selectedLanguage.value == 'ar',
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.confirmLanguage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String code,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.selectLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
