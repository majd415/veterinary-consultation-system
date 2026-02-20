import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/image_helper.dart';
import '../home_controller.dart';
import '../widgets/side_drawer.dart';
import '../../notification/notification_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Obx(() {
          if (controller.appLogo.isNotEmpty) {
            final logoPath = controller.appLogo.value;
            if (logoPath.startsWith('assets/')) {
              return Image.asset(
                logoPath,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              );
            } else {
              return Image.network(
                ImageHelper.getImageUrl(logoPath) ?? '',
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              );
            }
          }
          return Image.asset(
            'assets/images/logo.png',
            height: 60,
            fit: BoxFit.contain,
          );
        }),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Get.toNamed(Routes.NOTIFICATION);
                },
              ),
              // Use NotificationController for dynamic unread count
              GetX<NotificationController>(
                init: Get.put(NotificationController()),
                builder: (notifController) {
                  return notifController.unreadCount.value > 0
                      ? Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${notifController.unreadCount.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isSliderLoading.value &&
                  controller.sliderImages.isEmpty) {
                return const SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              return Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 180.0,
                      autoPlay: true,
                      enlargeCenterPage: false,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      viewportFraction: 0.95,
                      onPageChanged: controller.onSliderPageChanged,
                    ),
                    items: controller.sliderImages.map((imagePath) {
                      return Builder(
                        builder: (BuildContext context) {
                          final bool isAsset = imagePath.startsWith('assets/');
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: isAsset
                                    ? AssetImage(imagePath) as ImageProvider
                                    : NetworkImage(
                                        ImageHelper.getImageUrl(imagePath) ??
                                            '',
                                      ),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  // Fallback if image fails to load
                                },
                              ),
                            ),
                            child:
                                imagePath.contains('offer') &&
                                    !imagePath.endsWith('.png')
                                ? Center(
                                    child: Text(
                                      'special_offer'.tr,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: controller.sliderImages.asMap().entries.map((
                      entry,
                    ) {
                      final isActive =
                          controller.sliderIndex.value == entry.key;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 24.0 : 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'sections'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // More services logic if needed
                    },
                    icon: Icon(
                      Get.locale?.languageCode == 'ar'
                          ? Icons.arrow_back
                          : Icons.arrow_forward,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'see_all'.tr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(category.route);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: category.color.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    category.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'shop_by_category'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.STORE),
                    child: Text('see_all'.tr),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: controller.storeCategories.length,
                itemBuilder: (context, index) {
                  final cat = controller.storeCategories[index];
                  return GestureDetector(
                    onTap: () => Get.toNamed(cat['route']),
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(cat['icon'], color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (cat['name'] as String).tr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'top_rated'.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.featuredProducts.length,
                itemBuilder: (context, index) {
                  final item = controller.featuredProducts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          image: item['image'] != null
                              ? DecorationImage(
                                  image: item['image'].startsWith('assets/')
                                      ? AssetImage(item['image'])
                                            as ImageProvider
                                      : NetworkImage(
                                          ImageHelper.getImageUrl(
                                                item['image'],
                                              ) ??
                                              '',
                                        ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item['image'] == null
                            ? const Icon(Icons.star, color: Colors.amber)
                            : null,
                      ),
                      title: Text(
                        _getLocalized(item['name']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      _getLocalized(item['type']),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      Text(
                                        ' ${item['rating']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.bottomNavIndex.value,
          onTap: controller.changeBottomNavIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              label: 'vet_chat'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.storefront),
              label: 'store'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: 'profile'.tr,
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalized(dynamic val) {
    if (val == null) return '';
    if (val is Map) {
      final locale = Get.locale?.languageCode ?? 'en';
      return val[locale] ?? val['en'] ?? val.values.first?.toString() ?? '';
    }
    return val.toString();
  }
}
