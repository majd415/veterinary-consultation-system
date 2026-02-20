import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../store_controller.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';

class StorePaymentView extends StatefulWidget {
  const StorePaymentView({super.key});

  @override
  State<StorePaymentView> createState() => _StorePaymentViewState();
}

class _StorePaymentViewState extends State<StorePaymentView> {
  final controller = Get.find<StoreController>();
  final ApiService _apiService = Get.find<ApiService>();

  double shippingCost = 5.0; // Default fallback
  bool isLoadingShipping = true;

  // Shipping form controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchShippingPrice();
  }

  Future<void> _fetchShippingPrice() async {
    try {
      final response = await _apiService.getPaymentPrices();
      if (response.statusCode == 200) {
        final List prices = response.body;
        final shippingData =
            prices.firstWhere(
                  (p) => p is Map && p['service_key'] == 'shipping',
                  orElse: () => null,
                )
                as Map<String, dynamic>?;

        if (shippingData != null && shippingData['price'] != null) {
          setState(() {
            shippingCost = double.parse(shippingData['price'].toString());
          });
        }
      }
    } catch (e) {
      print('Error fetching shipping price: $e');
    } finally {
      setState(() => isLoadingShipping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final List<Product> items =
        (args['items'] as List<dynamic>?)?.cast<Product>() ?? [];

    final double subtotal = items.fold(0, (sum, item) => sum + item.price);
    final double total = subtotal + shippingCost;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Secure Checkout'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow('Subtotal', subtotal),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shipping (Dynamic)',
                        style: TextStyle(color: Colors.grey),
                      ),
                      if (isLoadingShipping)
                        const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Text(
                          '\$${shippingCost.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Shipping Details
            Text(
              'Shipping Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(nameController, 'Full Name', Icons.person),
            const SizedBox(height: 12),
            _buildTextField(
              addressController,
              'Detailed Address',
              Icons.location_on,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              phoneController,
              'Phone Number',
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 32),

            // Payment Information
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withOpacity(0.5)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Colors.blue,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Stripe Secure Payment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your payment is processed by Stripe. We do not store your credit card information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (nameController.text.isEmpty ||
                                    addressController.text.isEmpty ||
                                    phoneController.text.isEmpty) {
                                  Get.snackbar(
                                    'Missing Information',
                                    'Please fill all shipping details before proceeding.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                controller.createOrder(
                                  items: items,
                                  totalAmount: total,
                                  shippingName: nameController.text,
                                  shippingAddress: addressController.text,
                                  shippingPhone: phoneController.text,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Pay Now with Stripe',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
    );
  }
}
