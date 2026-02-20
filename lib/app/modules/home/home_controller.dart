import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/api_service.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_colors.dart';
import '../../data/services/notification_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var bottomNavIndex = 0.obs;
  var sliderIndex = 0.obs;
  // Use the global service count
  RxInt get notificationCount => Get.find<NotificationService>().unreadCount;
  var isSliderLoading = true.obs;

  final RxList<String> sliderImages = <String>[].obs;

  var appLogo = ''.obs;
  final RxList<Map<String, dynamic>> featuredProducts =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSliderOffers();
    fetchTopRatedItems();
    fetchAppLogo();
  }

  Future<void> fetchSliderOffers() async {
    isSliderLoading.value = true;
    try {
      final response = await _apiService.getSliderOffers();
      if (response.status.isOk && response.body != null) {
        final List<dynamic> data = response.body;
        sliderImages.clear();
        for (var item in data) {
          if (item['image_url'] != null) {
            sliderImages.add(item['image_url']);
          }
        }
      }
    } catch (e) {
      print('Error fetching slider offers: $e');
    } finally {
      // Fallback if empty
      if (sliderImages.isEmpty) {
        sliderImages.addAll([
          'assets/images/slider_hotel.png',
          'assets/images/food.png',
          'assets/images/shampoo.png',
          'assets/images/toy.png',
        ]);
      }
      isSliderLoading.value = false;
    }
  }

  Future<void> fetchTopRatedItems() async {
    try {
      final response = await _apiService.getTopRatedItems();
      if (response.status.isOk) {
        final List<dynamic> data = response.body;
        print('DEBUG: Top Rated Data count: ${data.length}');
        featuredProducts.value = data.map((item) {
          return {
            'name': item['name'], // Store raw map for dynamic translation
            'image': item['image'],
            'rating': item['rating'],
            'type': item['type'], // Store raw map if translatable
          };
        }).toList();
        print('DEBUG: Featured Products count: ${featuredProducts.length}');
      }
    } catch (e) {
      print('Error fetching top rated: $e');
    }
  }

  Future<void> fetchAppLogo() async {
    try {
      final response = await _apiService.getSettings(key: 'app_logo');
      if (response.status.isOk) {
        final data = response.body;
        if (data != null && data['value'] != null) {
          appLogo.value = data['value'];
        }
      }
    } catch (e) {
      print('Error fetching logo: $e');
    }
  }

  List<HomeCategory> get categories => [
    HomeCategory(
      title: 'vet_chat'.tr,
      icon: Icons.chat_bubble_outline,
      color: AppColors.primary,
      route: Routes.VET_LIST,
    ),
    HomeCategory(
      title: 'grooming'.tr,
      icon: Icons.content_cut_outlined,
      color: Colors.orange,
      route: Routes.GROOMING,
    ),
    HomeCategory(
      title: 'hotel'.tr,
      icon: Icons.hotel_outlined,
      color: Colors.purple,
      route: Routes.HOTEL,
    ),
    HomeCategory(
      title: 'store'.tr,
      icon: Icons.storefront_outlined,
      color: Colors.blue,
      route: Routes.STORE,
    ),
  ];

  final List<Map<String, dynamic>> storeCategories = [
    {'name': 'dog_food', 'icon': Icons.pets, 'route': Routes.STORE},
    {'name': 'cat_food', 'icon': Icons.pets_outlined, 'route': Routes.STORE},
    {'name': 'bird_food', 'icon': Icons.flutter_dash, 'route': Routes.STORE},
    {'name': 'health', 'icon': Icons.medical_services, 'route': Routes.STORE},
  ];

  void onSliderPageChanged(int index, CarouselPageChangedReason reason) {
    sliderIndex.value = index;
  }

  void changeBottomNavIndex(int index) {
    bottomNavIndex.value = index;
    if (index == 1) {
      Get.toNamed(Routes.VET_LIST);
    } else if (index == 2) {
      Get.toNamed(Routes.STORE);
    } else if (index == 3) {
      Get.toNamed(Routes.PROFILE);
    }
  }
}

class HomeCategory {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  HomeCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}
