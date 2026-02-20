import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  var currentPage = 0.obs;

  final List<OnboardingItem> items = [
    OnboardingItem(
      title: 'welcome_title',
      description: 'welcome_desc',
      imageAsset: 'assets/images/onboarding1.png',
    ),
    OnboardingItem(
      title: 'expert_vets_title',
      description: 'expert_vets_desc',
      imageAsset: 'assets/images/onboarding2.png',
    ),
    OnboardingItem(
      title: 'premium_store_title',
      description: 'premium_store_desc',
      imageAsset: 'assets/images/onboarding3.png',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.offAllNamed(Routes.ROLE_SELECTION);
    }
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String imageAsset;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}
