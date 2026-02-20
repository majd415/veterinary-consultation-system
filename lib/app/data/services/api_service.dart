import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// for android use 10.0.2.2:8081
// in laravel for android : APP_URL=http://10.0.2.2:8081
//php artisan config:clear
// php artisan cache:clear http://127.0.0.1:8081 192.168.1.4
class ApiService extends GetConnect {
  static String host = '192.168.1.8';

  static String get apiBaseUrl {
    return 'http://$host:8081/dog_market_backend/backend/public/api/';
  }

  @override
  void onInit() async {
    // Attempt to detect emulator
    if (Platform.isAndroid) {
      try {
        final interfaces = await NetworkInterface.list();
        for (var interface in interfaces) {
          for (var addr in interface.addresses) {
            if (addr.address.startsWith('10.0.2.')) {
              host = '10.0.2.2';
              print('🤖 ApiService: Emulator detected! Using host: $host');
              break;
            }
          }
        }
      } catch (e) {
        print('⚠️ ApiService: Error detecting emulator: $e');
      }
    }

    httpClient.baseUrl = apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 30);

    httpClient.addRequestModifier<dynamic>((request) async {
      print('--- API REQUEST ---');
      print('URL: ${request.url}');
      print('Method: ${request.method}');
      print('Headers: ${request.headers}');
      request.headers['Accept'] = 'application/json';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      final locale = Get.locale?.languageCode ?? 'en';
      request.headers['X-Language'] = locale;
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      print('--- API RESPONSE ---');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('Error: ${response.statusText}');
      return response;
    });

    super.onInit();
  }

  // Auth Endpoints
  Future<Response> sendCode(String email) =>
      post('auth/send-code', {'email': email});

  Future<Response> verifyCode(String email, String code) =>
      post('auth/verify-code', {'email': email, 'code': code});

  Future<Response> register(Map<String, dynamic> data) =>
      post('auth/register', data);

  Future<Response> login(String email, String password, String role) =>
      post('auth/login', {'email': email, 'password': password, 'role': role});

  Future<Response> forgotPassword(String email) =>
      post('auth/forgot-password', {'email': email});

  Future<Response> resetPassword(String email, String password) =>
      post('auth/reset-password', {'email': email, 'password': password});

  Future<Response> logout() => post('auth/logout', {});

  Future<Response> uploadPhoto(List<int> bytes, String filename) {
    final form = FormData({'photo': MultipartFile(bytes, filename: filename)});
    return post('auth/upload-photo', form);
  }

  Future<Response> updateProfile(Map<String, dynamic> data) =>
      post('auth/update-profile', data);

  Future<Response> getSliderOffers() => get('slider-offers');

  // Grooming
  Future<Response> getGroomingBookings() => get('grooming-bookings');
  Future<Response> storeGroomingBooking(Map<String, dynamic> data) =>
      post('grooming-bookings', data);
  Future<Response> updateGroomingBooking(
    String id,
    Map<String, dynamic> data,
  ) => put('grooming-bookings/$id', data);

  // Hotel
  Future<Response> getHotelBookings() => get('hotel-bookings');
  Future<Response> storeHotelBooking(Map<String, dynamic> data) =>
      post('hotel-bookings', data);
  Future<Response> updateHotelBooking(String id, Map<String, dynamic> data) =>
      put('hotel-bookings/$id', data);
  // Store
  Future<Response> getProductCategories() => get('product-categories');
  Future<Response> getProducts({String? categoryId, String? search}) {
    final Map<String, dynamic> query = {};
    if (categoryId != null && categoryId != 'all') {
      query['category_id'] = categoryId;
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    return get('products', query: query);
  }

  Future<Response> createOrder(Map<String, dynamic> data) =>
      post('orders', data);

  Future<Response> getOrders() => get('orders');

  // Top Rated & Settings
  Future<Response> getTopRatedItems() => get('top-rated-items');
  Future<Response> getSettings({String? key}) {
    if (key != null) {
      return get('settings', query: {'key': key});
    }
    return get('settings');
  }

  // Chat On-Demand
  Future<Response> getChatRequests() => get('chat-requests');
  Future<Response> storeChatRequest() => post('chat-requests', {});
  Future<Response> acceptChatRequest(String id) =>
      post('chat-requests/$id/accept', {});

  Future<Response> getVets({int page = 1}) =>
      get('vets', query: {'page': page.toString()});
  Future<Response> getChatRooms({int page = 1}) =>
      get('chat-rooms', query: {'page': page.toString()});

  Future<Response> getMessages(String roomId) =>
      get('chat-rooms/$roomId/messages');

  Future<Response> sendMessage(
    String roomId, {
    String? message,
    String? type,
    String? imagePath,
  }) {
    final formData = FormData({'message': message, 'type': type ?? 'text'});

    if (imagePath != null) {
      formData.files.add(
        MapEntry('image', MultipartFile(imagePath, filename: 'chat_image.jpg')),
      );
    }

    return post('chat-rooms/$roomId/messages', formData);
  }

  Future<Response> createChatRoom(
    String vetId, {
    String? transactionId,
    double? amount,
    String? currency,
  }) => post('chat-rooms', {
    'vet_id': vetId,
    if (transactionId != null) 'transaction_id': transactionId,
    if (amount != null) 'amount': amount,
    if (currency != null) 'currency': currency,
  });

  // Notifications
  Future<Response> getNotifications({int page = 1}) =>
      get('notifications', query: {'page': page.toString()});

  Future<Response> getUnreadNotificationCount() =>
      get('notifications/unread-count');

  Future<Response> markNotificationAsRead(String id) =>
      post('notifications/$id/read', {});
  Future<Response> updateFcmToken(String token) =>
      post('user/fcm-token', {'fcm_token': token});

  // Payments
  Future<Response> getPaymentPrices() => get('payment/prices');
  Future<Response> getStripePublishableKey() => get('payment/stripe-key');
  Future<Response> createPaymentIntent(double amount, String currency) =>
      post('payment/create-intent', {'amount': amount, 'currency': currency});
}
