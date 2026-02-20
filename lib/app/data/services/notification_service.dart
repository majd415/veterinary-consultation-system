import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modules/chat/chat_controller.dart';
import '../../routes/app_pages.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final ApiService _apiService = Get.find<ApiService>();
  var unreadCount = 0.obs;

  Future<NotificationService> init() async {
    await _initializeLocalNotifications();
    await _requestPermissions();
    await _setupFCM();
    fetchUnreadCount(); // Fetch initial count
    return this;
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.getUnreadNotificationCount();
      if (response.statusCode == 200) {
        unreadCount.value = response.body['unread_count'] ?? 0;
      }
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final Map<String, dynamic> data = jsonDecode(details.payload!);
          _handleNavigation(data);
        }
      },
    );

    if (!kIsWeb) {
      const channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }
  }

  Future<void> _setupFCM() async {
    String? token = await _messaging.getToken();
    print('token correct on first on main notification_services');

    if (kDebugMode) {
      print('FCM Token: $token');
    }
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      // _syncTokenWithBackend(token);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
      }

      // Check if we are currently in the chat room for this message
      bool shouldShowNotification = true;
      try {
        if (Get.currentRoute == Routes.CHAT) {
          final chatController = Get.find<ChatController>();
          final incomingRoomId = message.data['room_id']?.toString();
          if (incomingRoomId != null &&
              chatController.currentChatRoomId == incomingRoomId) {
            shouldShowNotification = false;
            print(
              '🔕 Suppressing notification: User is in chat $incomingRoomId',
            );
          }
        }
      } catch (e) {
        // ChatController might not be in memory, safe to show notification
      }

      if (message.notification != null && shouldShowNotification) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
      _handleNavigation(message.data);
    });
  }

  void _handleNavigation(Map<String, dynamic> data) {
    if (data.containsKey('chat_request_id')) {
      Get.toNamed(
        '/vet-accept',
        parameters: {'chat_request_id': data['chat_request_id'].toString()},
      );
    } else if (data.containsKey('chat_room_id') ||
        data.containsKey('room_id')) {
      final vetId = data['vet_id'];
      final roomId = data['chat_room_id'] ?? data['room_id'];

      // Determine the 'other' user ID (the one we are chatting with)
      // If I am the customer, I chat with vetId. If I am the vet, I chat with customerId.
      // But for simplicity, the ChatView often expects 'vet_id' if we are a user.
      // Let's pass what we have.

      Get.toNamed(
        Routes.CHAT,
        arguments: {
          'chat_room_id': roomId.toString(),
          'name': data['sender_name'] ?? 'Chat',
          'image': data['sender_image'],
          'vet_id': vetId, // Pass vetId as it might be needed
          'created_at': data['created_at'],
        },
      );
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && !kIsWeb) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // channelId
            'High Importance Notifications', // channelName
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<void> _syncTokenWithBackend(String token) async {
    try {
      final ApiService apiService = Get.find<ApiService>();
      await apiService.updateFcmToken(token);
      if (kDebugMode) {
        print('FCM Token synced with backend.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing FCM token: $e');
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}
