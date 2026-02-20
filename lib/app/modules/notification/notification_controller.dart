import 'package:get/get.dart';
import '../../data/services/api_service.dart';
import '../../data/services/notification_service.dart';

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      data: json['data'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class NotificationController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var unreadCount = 0.obs;
  int currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    Get.find<NotificationService>().fetchUnreadCount();
  }

  Future<void> fetchNotifications({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else {
      if (isLoading.value) return;
      isLoading.value = true;
      currentPage = 1;
      notifications.clear();
    }

    try {
      final response = await _apiService.getNotifications(page: currentPage);
      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<NotificationModel> fetched = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();

        notifications.addAll(fetched);

        hasMore.value = response.body['next_page_url'] != null;
        if (hasMore.value) {
          currentPage++;
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiService.markNotificationAsRead(id.toString());
      // Update local state to avoid full refresh
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = notifications[index];
        notifications[index] = NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          data: n.data,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
        );
      }
      // Update unread count after marking as read
      fetchUnreadCount();
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    // Optional backend call if implemented, or just iterate locally
    for (var n in notifications) {
      if (n.readAt == null) {
        markAsRead(n.id);
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Clear badge by resetting unread count when notifications view opens
    unreadCount.value = 0;
    // Optionally mark all as read in background (without waiting)
    markAllAsRead();
  }
}
