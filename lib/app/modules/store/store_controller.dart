import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/payment_service.dart';

class StoreController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var products = <Product>[].obs;
  var cart = <Product>[].obs;
  var categories = <Map<String, dynamic>>[].obs;
  var recentOrders = <dynamic>[].obs;

  var selectedCategoryId = 'all'.obs;
  var searchQuery = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts();
    fetchOrders();
  }

  void fetchCategories() async {
    try {
      final response = await _apiService.getProductCategories();
      if (response.status.isOk) {
        final List<dynamic> data = response.body;
        // Helper to get localized string
        String getLocalized(dynamic val) {
          if (val is Map) {
            final locale = Get.locale?.languageCode ?? 'en';
            return val[locale] ?? val['en'] ?? val.values.first ?? '';
          }
          return val.toString();
        }

        categories.value = data.map((e) {
          return {'id': e['id'].toString(), 'name': getLocalized(e['name'])};
        }).toList();

        // Add "All" category manually
        categories.insert(0, {'id': 'all', 'name': 'see_all'.tr});
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void fetchProducts() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getProducts(
        categoryId: selectedCategoryId.value,
        search: searchQuery.value,
      );
      if (response.status.isOk) {
        final List<dynamic> data = response.body;
        products.value = data.map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrders() async {
    try {
      final response = await _apiService.getOrders();
      if (response.status.isOk) {
        recentOrders.assignAll(response.body);
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  void selectCategory(String id) {
    selectedCategoryId.value = id;
    fetchProducts();
  }

  void search(String query) {
    searchQuery.value = query;
    fetchProducts();
  }

  void addToCart(Product product) {
    cart.add(product);
    Get.snackbar('Added to Cart', '${product.name} added to cart');
  }

  void removeFromCart(Product product) {
    cart.remove(product);
  }

  Future<void> createOrder({
    required List<Product> items,
    required double totalAmount,
    required String shippingName,
    required String shippingAddress,
    required String shippingPhone,
  }) async {
    isLoading.value = true;
    try {
      // 1. Process Stripe Payment
      final paymentService = Get.find<PaymentService>();
      final transactionId = await paymentService.makePayment(
        amount: totalAmount,
        merchantDisplayName: 'DogPro Store',
      );

      if (transactionId == null) {
        isLoading.value = false;
        return;
      }

      // 2. Create Order on Backend
      bool allSuccess = true;
      for (var item in items) {
        final response = await _apiService.createOrder({
          'product_id': item.id,
          'shipping_name': shippingName,
          'shipping_address': shippingAddress,
          'shipping_phone': shippingPhone,
          'total_amount': item.price,
          'transaction_id': transactionId,
          'payment_method': 'stripe',
          'currency': 'USD',
        });

        if (!response.status.isOk) {
          allSuccess = false;
          print('Order failed for ${item.name}: ${response.body}');
        }
      }

      if (allSuccess) {
        Get.back(); // Close checkout view
        Get.snackbar('Success', 'Order placed successfully!');
        if (items == cart) {
          cart.clear();
        }
        await fetchOrders();
      } else {
        Get.snackbar(
          'Minor Error',
          'Payment cleared, but some internal order records failed. Please contact support.',
        );
      }
    } catch (e) {
      print('Error during checkout: $e');
      Get.snackbar('Error', 'Failed to complete checkout');
    } finally {
      isLoading.value = false;
    }
  }

  double get totalPrice => cart.fold(0, (sum, item) => sum + item.price);
}
