import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../notification_controller.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'notifications'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => controller.markAllAsRead(),
            icon: const Icon(Icons.done_all),
            tooltip: 'mark_all_read'.tr,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: AnimationConfiguration.synchronized(
              duration: const Duration(milliseconds: 1000),
              child: FadeInAnimation(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 80,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'no_notifications'.tr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(),
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount:
                  controller.notifications.length +
                  (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.notifications.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: controller.isLoadingMore.value
                          ? const CircularProgressIndicator()
                          : TextButton(
                              onPressed: () =>
                                  controller.fetchNotifications(loadMore: true),
                              child: Text('load_more'.tr),
                            ),
                    ),
                  );
                }

                final notification = controller.notifications[index];
                final isRead = notification.readAt != null;

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isRead
                                ? Colors.transparent
                                : Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              onTap: () =>
                                  controller.markAsRead(notification.id),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isRead
                                          ? Colors.grey.withOpacity(0.1)
                                          : Colors.blue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      notification.data?['type'] == 'chat'
                                          ? Icons.chat_bubble_outline_rounded
                                          : Icons.notifications_none_rounded,
                                      color: isRead ? Colors.grey : Colors.blue,
                                    ),
                                  ),
                                  if (!isRead)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(
                                    notification.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTime(notification.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, hh:mm a').format(date);
    }
  }
}
