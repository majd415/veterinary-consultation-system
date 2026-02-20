import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../grooming_controller.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/payment_service.dart';

class GroomingPaymentView extends StatefulWidget {
  const GroomingPaymentView({super.key});

  @override
  State<GroomingPaymentView> createState() => _GroomingPaymentViewState();
}

class _GroomingPaymentViewState extends State<GroomingPaymentView> {
  final controller = Get.find<GroomingController>();
  final ApiService _apiService = Get.find<ApiService>();
  final PaymentService _paymentService = Get.find<PaymentService>();

  double servicePrice = 0.0;
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
        final priceData = prices.firstWhere(
          (p) => p['service_key'] == 'grooming',
          orElse: () => null,
        );
        if (priceData != null) {
          setState(() {
            servicePrice = double.parse(priceData['price'].toString());
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

    final displayPrice = servicePrice > 0 ? servicePrice : 25.0; // Fallback

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grooming Payment',
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
              'Order Summary',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Professional Grooming',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${controller.numAnimals.value} ${controller.numAnimals.value > 1 ? 'Animals' : 'Animal'} - Complete Shave & Bath',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (isLoadingPrice)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${(displayPrice * controller.numAnimals.value).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        if (controller.numAnimals.value > 1)
                          Text(
                            '\$${displayPrice.toStringAsFixed(2)} each',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
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
                  const Icon(Icons.lock_outline, color: Colors.green, size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'Secure Credit Card Payment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your transaction is encrypted and secured by Stripe. We do not store your card details.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isProcessing || isLoadingPrice
                          ? null
                          : _processStripePayment,
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
                        isProcessing ? 'Processing...' : 'Pay with Stripe',
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
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Trusted by over 1M+ businesses worldwide',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processStripePayment() async {
    setState(() => isProcessing = true);

    final displayPrice = servicePrice > 0 ? servicePrice : 25.0;
    final totalAmount = displayPrice * controller.numAnimals.value;

    final transactionId = await _paymentService.makePayment(
      amount: totalAmount,
      merchantDisplayName: 'DogPro Grooming',
    );

    if (transactionId != null && mounted) {
      // Add appointment and go back
      controller.addAppointment(transactionId: transactionId);
      Get.back();
      Get.snackbar('Success', 'Grooming Appointment Confirmed!');
    }

    if (mounted) {
      setState(() => isProcessing = false);
    }
  }
}
