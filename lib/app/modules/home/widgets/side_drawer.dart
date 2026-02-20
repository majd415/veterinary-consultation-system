import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../theme/app_colors.dart';
import '../../auth/auth_controller.dart';
import '../../../utils/image_helper.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() {
                  final controller = Get.find<AuthController>();
                  return Container(
                    padding: EdgeInsets.all(
                      controller.profilePhotoUrl.isNotEmpty ? 0 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: controller.profilePhotoUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              ImageHelper.getImageUrl(
                                    controller.profilePhotoUrl.value,
                                  ) ??
                                  '',
                            ),
                          )
                        : const Icon(
                            Icons.pets,
                            color: AppColors.primary,
                            size: 50,
                          ),
                  );
                }),
                const SizedBox(width: 15),
                Expanded(
                  child: Obx(() {
                    final controller = Get.find<AuthController>();
                    return Text(
                      controller.userName.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('home'.tr),
            onTap: () {
              Get.back();
              Get.offNamed(Routes.HOME);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('profile'.tr),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.PROFILE);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('settings'.tr),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.SETTINGS);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'logout'.tr,
              style: const TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
          ),
        ],
      ),
    );
  }
}
