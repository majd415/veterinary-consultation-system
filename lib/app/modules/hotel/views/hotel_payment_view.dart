import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../hotel_controller.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/payment_service.dart';
import '../../../routes/app_pages.dart';

class HotelPaymentView extends StatefulWidget {
  const HotelPaymentView({super.key});

  @override
  State<HotelPaymentView> createState() => _HotelPaymentViewState();
}

class _HotelPaymentViewState extends State<HotelPaymentView> {
  final controller = Get.find<HotelController>();
  final ApiService _apiService = Get.find<ApiService>();
  final PaymentService _paymentService = Get.find<PaymentService>();

  double basePricePerDay = 0.0;
  bool isLoadingPrice = true;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchPrice();
  }

  Future<void> _fetchPrice() async {
    try {
      final response = await _apiService.getPaymentPrices();
      if (response.statusCode == 200) {
        final List prices = response.body;
        final priceData =
            prices.firstWhere(
                  (p) => p is Map && p['service_key'] == 'pet_hotel',
                  orElse: () => null,
                )
                as Map<String, dynamic>?;

        if (priceData != null && priceData['price'] != null) {
          setState(() {
            basePricePerDay = double.parse(priceData['price'].toString());
          });
        }
      }
    } catch (e) {
      print('Error fetching price: $e');
    } finally {
      setState(() => isLoadingPrice = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use fetched base price if available, otherwise use controller's logic
    // Actually, controller.totalCost is already calculated.
    // We should ideally update the controller's logic to use the fetched base price.
    // For now, we'll just show the total cost calculated by the controller.

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hotel Payment',
          style: TextStyle(color: AppColors.text),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.text,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reservation Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Stay Cost',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$${controller.totalCost.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price per Day (Dynamic)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      if (isLoadingPrice)
                        const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Text(
                          '\$${(basePricePerDay > 0 ? basePricePerDay : (controller.totalCost.value / (controller.totalDays.value > 0 ? controller.totalDays.value : 1))).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stripe Payment Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lock_person_outlined,
                    color: Colors.blue,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Card Payment with Stripe',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pay safely using your credit or debit card. Protected by 256-bit SSL encryption.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isProcessing ? null : _processStripePayment,
                      icon: isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.credit_card, color: Colors.white),
                      label: Text(
                        isProcessing ? 'Processing...' : 'Secure Checkout',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processStripePayment() async {
    setState(() => isProcessing = true);

    final transactionId = await _paymentService.makePayment(
      amount: controller.totalCost.value,
      merchantDisplayName: 'DogPro Hotel',
    );

    if (transactionId != null && mounted) {
      // Add reservation and navigate to hotel screen
      controller.addReservation(transactionId: transactionId);
      Get.offAllNamed(Routes.HOTEL);
      Get.snackbar('Success', 'Hotel Reservation Confirmed!');
    }

    if (mounted) {
      setState(() => isProcessing = false);
    }
  }
}
