import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../theme/app_colors.dart';
import '../chat_controller.dart';
import '../../../utils/image_helper.dart';

class VetListView extends GetView<ChatController> {
  const VetListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('vet_chat'.tr), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.userRole.value == 'user') ...[
                  // Payment Section at Top
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'instant_vet'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.bolt,
                              color: Colors.amber,
                              size: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'instant_vet_desc'.tr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.toNamed(
                              Routes.VET_PAYMENT,
                              arguments: {'isInstant': true},
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                            ),
                            child: Text('pay_start'.tr),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Available Vets Section
                  Text(
                    'available_vets'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (controller.availableVets.isEmpty &&
                      !controller.isLoadingVets.value)
                    Center(child: Text('no_vets'.tr))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.availableVets.length,
                      itemBuilder: (context, index) {
                        final vet = controller.availableVets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              backgroundImage: vet['image'].isNotEmpty
                                  ? NetworkImage(
                                      ImageHelper.getImageUrl(vet['image'])!,
                                    )
                                  : null,
                              child: vet['image'].isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 30,
                                    )
                                  : null,
                            ),
                            title: Text(
                              vet['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vet['specialty']),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    Text(' ${vet['rating']}'),
                                    const SizedBox(width: 12),
                                    Text(
                                      'fee_label'.tr + '${vet['fee']}',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Get.toNamed(
                                  Routes.VET_PAYMENT,
                                  arguments: {'isInstant': false, 'vet': vet},
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                              ),
                              child: Text('chat_button'.tr),
                            ),
                          ),
                        );
                      },
                    ),

                  if (controller.isLoadingVets.value)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  if (controller.hasMoreVets.value &&
                      !controller.isLoadingVets.value)
                    Center(
                      child: TextButton(
                        onPressed: () => controller.fetchVets(loadMore: true),
                        child: Text('load_more'.tr),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],

                // Archived Chats Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.userRole.value == 'vet'
                          ? 'my_consultations'.tr
                          : 'archived_chats'.tr,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.archive_outlined, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                if (controller.archivedChats.isEmpty &&
                    !controller.isLoadingRooms.value)
                  Center(child: Text('no_chat_history'.tr))
                else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.archivedChats.length,
                    itemBuilder: (context, index) {
                      final chat = controller.archivedChats[index];
                      final isUnread = chat['isUnread'] ?? false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isUnread
                              ? AppColors.primary.withOpacity(0.05)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(15),
                          border: isUnread
                              ? Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black26
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                (chat['image'] != null &&
                                    chat['image'].isNotEmpty)
                                ? NetworkImage(
                                    ImageHelper.getImageUrl(chat['image'])!,
                                  )
                                : null,
                            child:
                                (chat['image'] == null || chat['image'].isEmpty)
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            chat['vetName'],
                            style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            chat['lastMessage'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                chat['date'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            controller.unreadCounts[chat['chat_room_id']] = 0;
                            Get.toNamed(
                              Routes.CHAT,
                              arguments: {
                                'name': chat['vetName'],
                                'chat_room_id': chat['chat_room_id'],
                                'image': chat['image'],
                                // CRITICAL: Include vet_id for payment flow when session expires
                                'vet_id': chat['vet_id'],
                                'created_at': chat['created_at'],
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  if (controller.isLoadingRooms.value)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (controller.hasMoreRooms.value &&
                      !controller.isLoadingRooms.value)
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            controller.fetchMyChatRooms(loadMore: true),
                        child: Text('load_more'.tr),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
