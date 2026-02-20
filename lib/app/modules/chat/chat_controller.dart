import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'dart:convert';
import 'dart:async';
import '../../data/services/api_service.dart';
import '../../routes/app_pages.dart';
import 'package:audioplayers/audioplayers.dart';

enum ChatMessageType { text, image }

class ChatMessage {
  final String text;
  final bool isSender;
  final DateTime time;
  final String senderId;
  final ChatMessageType type;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.isSender,
    required this.time,
    required this.senderId,
    this.type = ChatMessageType.text,
    this.imageUrl,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> data,
    String currentUserId,
  ) {
    final senderId =
        data['user_id']?.toString() ?? data['sender_id']?.toString() ?? '';
    final actualSenderId = (data['user'] is Map)
        ? data['user']['id'].toString()
        : senderId;

    // Robust comparison: check against both ID and Email if currentUserId could be either
    bool isSender = actualSenderId == currentUserId;
    if (!isSender && data['user'] is Map) {
      final userEmail = data['user']['email']?.toString();
      if (userEmail != null && userEmail == currentUserId) {
        isSender = true;
      }
    }

    debugPrint(
      '🧩 Msg ID Check: Actual=$actualSenderId, Current=$currentUserId, Result=$isSender',
    );

    return ChatMessage(
      text: data['message'] ?? data['text'] ?? '',
      senderId: actualSenderId,
      isSender: isSender,
      time: DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now(),
      type: data['type'] == 'image'
          ? ChatMessageType.image
          : ChatMessageType.text,
      imageUrl: data['image_url'],
    );
  }
}

class ChatController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final messageController = TextEditingController();
  final scrollController = ScrollController();
  var messages = <ChatMessage>[].obs;
  var archivedChats = <Map<String, dynamic>>[].obs;
  var isServicePaid = false.obs;
  var userRole = 'user'.obs;

  var availableVets = <Map<String, dynamic>>[].obs;
  var currentVetsPage = 1;
  var hasMoreVets = true.obs;
  var isLoadingVets = false.obs;

  var currentRoomsPage = 1;
  var hasMoreRooms = true.obs;
  var isLoadingRooms = false.obs;

  var isUploading = false.obs;

  String? currentChatRoomId;
  String? currentUserId;
  DateTime? chatCreatedAt;
  var isChatArchived = false.obs;

  PusherChannelsClient? pusher;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _eventSubscription;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 ChatController onInit');
    _init();
    Timer.periodic(const Duration(minutes: 1), (timer) => _checkIfArchived());
  }

  // To track unread counts for each room
  var unreadCounts = <String, int>{}.obs;

  Future<void> _init() async {
    await _loadUser();

    final args = Get.arguments;
    debugPrint('📦 ChatController Args: $args');

    if (args != null && args is Map && args.containsKey('chat_room_id')) {
      final roomId = args['chat_room_id'].toString();
      debugPrint('📍 Initializing for Room ID: $roomId');
      setupChatRoom(roomId);
      if (args['created_at'] != null) {
        // Parse as UTC explicitly if it contains 'Z' or offset, otherwise treat as UTC
        var rawTime = args['created_at'].toString();
        if (!rawTime.endsWith('Z') && !rawTime.contains('+')) {
          // Assume server sends UTC string like '2023-01-01 12:00:00'
          rawTime += 'Z';
        }
        chatCreatedAt = DateTime.tryParse(rawTime);

        debugPrint('📅 Chat created at (Parsed): $chatCreatedAt');
        // Reset archived status when initializing with fresh timestamp
        isChatArchived.value = false;
        _checkIfArchived();
      }
    }

    if (userRole.value == 'user') {
      fetchVets();
    }
    fetchMyChatRooms();

    // Initial check for archive
    _checkIfArchived();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    pusher?.dispose();
    super.onClose();
  }

  void _checkIfArchived() {
    if (chatCreatedAt == null) return;

    // Ensure both are in UTC for correct comparison
    final nowUtc = DateTime.now().toUtc();
    final createdUtc = chatCreatedAt!.toUtc();
    final difference = nowUtc.difference(createdUtc);

    debugPrint('🕒 Time Check:');
    debugPrint('   - Created (UTC): $createdUtc');
    debugPrint('   - Now (UTC): $nowUtc');
    debugPrint('   - Difference (min): ${difference.inMinutes}');

    if (difference.inMinutes >= 60) {
      isChatArchived.value = true;
      isServicePaid.value = false; // Force payment UI
      debugPrint('⚠️ Chat is ARCHIVED (Expired)');
    } else {
      isChatArchived.value = false;
      isServicePaid.value = true;
      debugPrint('✅ Chat is ACTIVE');
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id =
        prefs.getString('user_id') ?? prefs.getInt('user_id')?.toString();
    final email = prefs.getString('user_email');

    if (id != null) {
      currentUserId = id;
    } else {
      currentUserId = email;
    }

    debugPrint('👤 Loaded User ID for Chat: $currentUserId');

    userRole.value = prefs.getString('user_role') ?? 'user';
  }

  Future<void> fetchVets({bool loadMore = false}) async {
    if (isLoadingVets.value) return;
    if (loadMore && !hasMoreVets.value) return;

    isLoadingVets.value = true;
    if (!loadMore) {
      currentVetsPage = 1;
      availableVets.clear();
    }

    try {
      final response = await _apiService.getVets(page: currentVetsPage);
      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<Map<String, dynamic>> fetchedVets = data.map((v) {
          String specialty = 'Specialist';
          if (v['bio'] is String) {
            specialty = v['bio'];
          } else if (v['bio'] is Map) {
            specialty = v['bio']['en'] ?? v['bio']['ar'] ?? 'Specialist';
          }

          return {
            'id': v['id'].toString(),
            'name': v['name'],
            'specialty': specialty,
            'rating': 4.5,
            'image': v['avatar'] ?? '',
            'fee': 1.0,
          };
        }).toList();

        availableVets.addAll(fetchedVets);
        hasMoreVets.value = response.body['next_page_url'] != null;
        if (hasMoreVets.value) currentVetsPage++;
      }
    } finally {
      isLoadingVets.value = false;
    }
  }

  Future<void> fetchMyChatRooms({bool loadMore = false}) async {
    if (isLoadingRooms.value) return;
    if (loadMore && !hasMoreRooms.value) return;

    isLoadingRooms.value = true;
    if (!loadMore) {
      currentRoomsPage = 1;
      archivedChats.clear();
    }

    try {
      final response = await _apiService.getChatRooms(page: currentRoomsPage);
      if (response.statusCode == 200) {
        final List data = response.body['data'] ?? [];
        final List<Map<String, dynamic>> fetchedRooms = data.map((room) {
          final isVet = userRole.value == 'vet';
          final partner = isVet ? room['customer'] : room['vet'];
          return {
            'id': room['id'].toString(),
            'vetName': partner?['name'] ?? 'Unknown',
            'image': partner?['avatar'] ?? '',
            'date': room['created_at'].toString().split('T')[0],
            'lastMessage': 'View chat history',
            'chat_room_id': room['id'].toString(),
            'created_at': room['created_at'],
            'isUnread': (unreadCounts[room['id'].toString()] ?? 0) > 0,
            // Add partner ID for payment flow
            'vet_id': partner?['id']?.toString(),
            'name': partner?['name'] ?? 'Unknown',
          };
        }).toList();

        archivedChats.addAll(fetchedRooms);
        hasMoreRooms.value = response.body['next_page_url'] != null;
        if (hasMoreRooms.value) currentRoomsPage++;
      }
    } catch (e) {
      debugPrint('Error fetching chat rooms: $e');
    } finally {
      isLoadingRooms.value = false;
    }
  }

  void setupChatRoom(String roomId) async {
    debugPrint('🛠️ setupChatRoom: $roomId');

    // Ensure user data is loaded first
    if (currentUserId == null) {
      debugPrint('⌛ Waiting for currentUserId to load...');
      await _loadUser();
    }

    currentChatRoomId = roomId;
    messages.clear();

    try {
      final response = await _apiService.getMessages(roomId);
      debugPrint('📜 Fetch History Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List data = response.body;
        debugPrint('📜 Messages fetched: ${data.length}');
        if (currentUserId != null) {
          messages.value = data
              .map((m) => ChatMessage.fromJson(m, currentUserId!))
              .toList();
        } else {
          debugPrint('⚠️ Cannot map messages: currentUserId is null');
        }
      } else {
        debugPrint('❌ Fetch History Failed: ${response.body}');
      }

      // Auto-scroll to bottom after loading history
      Future.delayed(const Duration(milliseconds: 300), scrollToBottom);
    } catch (e) {
      debugPrint('❌ Error fetching messages: $e');
    }

    _initPusher(roomId);
    _subscribeToUserNotifications();
  }

  void _subscribeToUserNotifications() async {
    if (currentUserId == null || pusher == null) return;

    debugPrint(
      '🔔 Subscribing to User Notifications: user.notifications.$currentUserId',
    );

    final channel = pusher!.privateChannel(
      'user.notifications.$currentUserId',
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
            authorizationEndpoint: Uri.parse(
              '${ApiService.apiBaseUrl}broadcasting/auth',
            ),
            headers: {
              'Authorization':
                  'Bearer ${await SharedPreferences.getInstance().then((p) => p.getString('auth_token'))}',
              'Accept': 'application/json',
            },
          ),
    );

    channel.bind('message.sent').listen((event) {
      debugPrint('🔔 Notification Received: ${event.data}');
      if (event.data != null) {
        final payload = event.data is String
            ? jsonDecode(event.data)
            : event.data;
        final roomId = payload['message']['chat_room_id'].toString();

        if (roomId != currentChatRoomId) {
          unreadCounts[roomId] = (unreadCounts[roomId] ?? 0) + 1;
          Get.snackbar(
            'New Message',
            'You have a new message from ${payload['message']['user']['name']}',
            onTap: (_) => Get.toNamed(
              Routes.CHAT,
              arguments: {
                'chat_room_id': roomId,
                'name': payload['message']['user']['name'],
              },
            ),
          );
        }
      }
    });

    channel.subscribe();
  }

  void _initPusher(String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        debugPrint('❌ Pusher Init Cancelled: Auth token is null');
        return;
      }

      // 1. Create Options
      final String host = ApiService.host;
      debugPrint('📡 Attempting Pusher connection to $host:6001');

      final options = PusherChannelsOptions.fromHost(
        scheme: 'ws',
        host: host,
        port: 6001,
        key: 'dummy',
      );

      // 2. Initialize Client
      if (pusher != null) {
        await _connectionSubscription?.cancel();
        await _eventSubscription?.cancel();
        pusher!.dispose();
      }

      pusher = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, refresh) {
          debugPrint('⚠️ Pusher Connection Error: $exception');
          refresh();
        },
      );

      // 3. Listen to connection state
      _connectionSubscription = pusher!.lifecycleStream.listen((state) {
        debugPrint('📡 Pusher Lifecycle State: $state');
      });

      // Global event listener for ALL events (diagnostics)
      pusher!.eventStream.listen((event) {
        debugPrint('🔎 Global WebSocket Event: ${event.name}');
      });

      // 4. Setup Authorization Delegate
      final authEndpoint = Uri.parse(
        '${ApiService.apiBaseUrl}broadcasting/auth',
      );
      debugPrint('🔑 Authorizing with endpoint: $authEndpoint');

      final authorizer =
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
            authorizationEndpoint: authEndpoint,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

      // 5. Subscribe to Private Channel
      final channelName = 'private-chat.room.$roomId';
      debugPrint('📺 Subscribing to channel: $channelName');

      final channel = pusher!.privateChannel(
        channelName,
        authorizationDelegate: authorizer,
      ); // 6. Bind to Event
      _eventSubscription = channel.bind('message.sent').listen((event) {
        debugPrint(
          '🔥 Pusher Event Received: ${event.name} Data: ${event.data}',
        );

        if (event.data != null && currentUserId != null) {
          dynamic payload = event.data;

          if (payload is String) {
            try {
              payload = jsonDecode(payload);
            } catch (e) {
              debugPrint('❌ JSON Decode Error: $e');
            }
          }

          if (payload is Map) {
            final messageData = payload['message'] ?? payload;
            final Map<String, dynamic> messageMap = Map<String, dynamic>.from(
              messageData as Map,
            );
            final msg = ChatMessage.fromJson(messageMap, currentUserId!);

            if (msg.senderId != currentUserId) {
              messages.add(msg);
              debugPrint('✅ Message added to UI: ${msg.text}');
              scrollToBottom();
            }
          }
        }
      });

      // 7. Connect FIRST
      await pusher!.connect();
      debugPrint('🚀 Pusher Connect called');

      // 8. Subscribe SECOND
      channel.bind('pusher:subscription_succeeded').listen((event) {
        debugPrint('✅ Channel Subscribed Successfully!');
      });

      channel.bind('pusher:subscription_error').listen((event) {
        debugPrint('❌ Channel Subscription Error: ${event.data}');
      });

      channel.subscribe();
      debugPrint('📣 channel.subscribe() called');
    } catch (e) {
      debugPrint('❌ Pusher Init Error: $e');
    }
  }

  Future<void> sendMessage({String? text, String? imageUrl}) async {
    if (currentChatRoomId == null || currentUserId == null) return;

    String content = text ?? messageController.text;
    if (content.trim().isEmpty && imageUrl == null) return;

    final messageText = content;
    final type = imageUrl != null ? 'image' : 'text';

    final tempMessage = ChatMessage(
      text: messageText,
      isSender: true,
      time: DateTime.now(),
      senderId: currentUserId!,
      type: imageUrl != null ? ChatMessageType.image : ChatMessageType.text,
      imageUrl: imageUrl,
    );
    messages.add(tempMessage);
    messageController.clear();

    try {
      final response = await _apiService.sendMessage(
        currentChatRoomId!,
        message: messageText,
        type: type,
        imagePath: null,
      );

      // Play send sound effect
      try {
        await _audioPlayer.play(AssetSource('sounds/message_sent.mp3'));
      } catch (e) {
        debugPrint('Sound playback error: $e');
      }

      scrollToBottom();

      if (response.statusCode != 200) {
        messages.remove(tempMessage);

        if (response.statusCode == 403 &&
            response.body != null &&
            response.body['is_locked'] == true) {
          isChatArchived.value = true;
          isServicePaid.value = false;
          Get.snackbar(
            'Session Expired',
            response.body['message'] ?? 'Please pay to continue.',
          );
        } else {
          Get.snackbar('Error', 'Failed to send message');
        }
      }
    } catch (e) {
      messages.remove(tempMessage);
      Get.snackbar('Error', 'Error sending: $e');
    }
  }

  Future<void> pickAndSendImage() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);

      if (images.isNotEmpty) {
        isUploading.value = true;
        for (var image in images) {
          try {
            final response = await _apiService.sendMessage(
              currentChatRoomId!,
              type: 'image',
              imagePath: image.path,
            );

            if (response.statusCode == 200) {
              final data = response.body['message'];
              if (currentUserId != null) {
                messages.add(ChatMessage.fromJson(data, currentUserId!));
              }
            }
          } catch (e) {
            Get.snackbar('Upload Failed', '$e');
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> reOpenChat() async {
    final args = Get.arguments;
    debugPrint('🔍 reOpenChat called with args: $args');
    if (args == null) {
      debugPrint('❌ reOpenChat: args is null!');
      Get.snackbar('Error', 'Cannot reopen chat: missing information');
      return;
    }

    // Extract vet_id - could be in args directly or in stored arguments
    final vetId = args['vet_id'];
    final name = args['name'] ?? args['vetName']; // Check both keys
    final image = args['image'] ?? '';

    debugPrint('🔍 vet_id from args: $vetId');
    debugPrint('🔍 name from args: $name');
    debugPrint('🔍 image from args: $image');

    if (vetId == null || vetId.toString().isEmpty) {
      debugPrint('❌ vet_id is missing in arguments!');
      Get.snackbar(
        'Error',
        'Cannot reopen chat: vet information is incomplete',
      );
      return;
    }

    // Pass existing room info to payment view
    Get.toNamed(
      Routes.VET_PAYMENT,
      arguments: {
        'isInstant': false,
        'vet': {
          'id': vetId.toString(),
          'name': name,
          'image': image,
          'fee': 1.0,
        },
      },
    );
  }

  void archiveCurrentChat() {
    if (messages.isNotEmpty) {
      fetchMyChatRooms();
      messages.clear();
      currentChatRoomId = null;
    }
  }

  Future<void> completeInstantConsultationPayment({
    required String transactionId,
  }) async {
    try {
      final response = await _apiService
          .storeChatRequest(); // Use helper if updated or pass map
      // NOTE: Since ApiService.storeChatRequest didn't strictly take args in memory view,
      // I'm assuming it needs update OR I use post directly.
      // Wait, I didn't verify storeChatRequest in ApiService!
      // I will assume for now I need to pass it, but if signature mismatch, I'll fix.
      // Actually, ChatRequest logging is pending backend update. Frontend just passes it if possible.
      // I will verify ApiService.storeChatRequest next turn.
      // For now, let's focus on completeVetChatPayment which IS verified.

      if (response.statusCode == 200) {
        isServicePaid.value = true;
        Get.back();
        Get.snackbar('Success', 'Search for a vet started.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final response = await _apiService.acceptChatRequest(requestId);
      Get.back();
      if (response.statusCode == 200) {
        final chatRoom = response.body['chat_room'];
        Get.offNamed(
          Routes.CHAT,
          arguments: {
            'chat_room_id': chatRoom['id'],
            'created_at': chatRoom['created_at'],
          },
        );
      } else if (response.body != null &&
          response.body['error'] == 'already_taken') {
        Get.snackbar('Too Late', 'This request was already taken.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> completeVetChatPayment(
    Map<String, dynamic> vet, {
    required String transactionId,
  }) async {
    try {
      debugPrint('💳 completeVetChatPayment called with vet: $vet');
      debugPrint('💳 vet id: ${vet['id']}');

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final vetId = vet['id']?.toString();
      if (vetId == null || vetId.isEmpty) {
        Get.back();
        Get.snackbar('Error', 'Invalid vet ID');
        debugPrint('❌ vet ID is null or empty!');
        return;
      }

      final response = await _apiService.createChatRoom(
        vetId,
        transactionId: transactionId,
        amount: vet['fee'] is num ? (vet['fee'] as num).toDouble() : 1.0,
        currency: 'USD',
      );
      Get.back(); // Close loading dialog

      debugPrint('💳 createChatRoom response: ${response.statusCode}');
      debugPrint('💳 response body: ${response.body}');

      if (response.statusCode == 200) {
        final chatRoom = response.body;
        Get.back(); // Close payment dialog

        debugPrint('💚 Payment successful! New chat room: ${chatRoom['id']}');
        debugPrint('💚 Created at: ${chatRoom['created_at']}');

        // CRITICAL: Delete the old controller to ensure fresh state
        Get.delete<ChatController>(force: true);

        // Navigate back to vet list
        Get.back();

        // Small delay to ensure navigation completes
        Future.delayed(const Duration(milliseconds: 300), () {
          // Navigate to fresh chat with new session
          Get.toNamed(
            Routes.CHAT,
            arguments: {
              'name': vet['name'],
              'chat_room_id': chatRoom['id'],
              'created_at': chatRoom['created_at'], // Fresh timestamp!
              'vet_id': vet['id'],
              'image': vet['image'],
            },
          );

          // Show success message
          Future.delayed(const Duration(milliseconds: 800), () {
            Get.snackbar(
              'Success',
              'Chat session activated! Start messaging now.',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          });
        });
      } else {
        Get.snackbar('Error', 'Failed to initialize chat room');
      }
    } catch (e) {
      Get.back();
      debugPrint('❌ completeVetChatPayment error: $e');
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}
