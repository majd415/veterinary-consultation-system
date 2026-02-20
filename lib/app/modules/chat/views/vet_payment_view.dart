import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../chat_controller.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/payment_service.dart';

class VetPaymentView extends StatefulWidget {
  const VetPaymentView({super.key});

  @override
  State<VetPaymentView> createState() => _VetPaymentViewState();
}

class _VetPaymentViewState extends State<VetPaymentView> {
  final ChatController controller = Get.find<ChatController>();
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
        final vetPrice = prices.firstWhere(
          (p) => p['service_key'] == 'vet_chat',
          orElse: () => null,
        );
        if (vetPrice != null) {
          setState(() {
            servicePrice = double.parse(vetPrice['price'].toString());
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
    final args = Get.arguments as Map<String, dynamic>?;
    final isInstant = args?['isInstant'] ?? false;
    final vet = args?['vet'] as Map<String, dynamic>?;

    // Fallback if price fetch fails
    final displayPrice = servicePrice > 0
        ? servicePrice
        : (isInstant ? 1.0 : (vet?['fee'] ?? 1.0));

    return Scaffold(
      appBar: AppBar(title: Text('vet_payment'.tr), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    isInstant ? Icons.bolt : Icons.person,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isInstant
                              ? 'instant_consultation'.tr
                              : (vet?['name'] ?? 'vet_consultation'.tr),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          isInstant
                              ? 'notify_all_vets'.tr
                              : (vet?['specialty'] ?? 'specialist'.tr),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isLoadingPrice)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      '\$${displayPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'dynamic_pricing'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text('pricing_desc'.tr, style: theme.textTheme.bodySmall),
            const SizedBox(height: 32),

            // Payment Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'secure_checkout'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'stripe_security_desc'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isProcessing || isLoadingPrice
                          ? null
                          : () => _handleStripePayment(
                              isInstant,
                              vet,
                              displayPrice,
                            ),
                      icon: isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.credit_card),
                      label: Text(
                        isProcessing ? 'processing'.tr : 'pay_stripe'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'powered_stripe'.tr,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStripePayment(
    bool isInstant,
    Map<String, dynamic>? vet,
    double amount,
  ) async {
    setState(() => isProcessing = true);

    final transactionId = await _paymentService.makePayment(
      amount: amount,
      merchantDisplayName: 'DogPro Services',
    );

    if (transactionId != null && mounted) {
      if (isInstant) {
        await controller.completeInstantConsultationPayment(
          transactionId: transactionId,
        );
      } else if (vet != null) {
        controller.completeVetChatPayment(vet, transactionId: transactionId);
      } else {
        Get.snackbar('error'.tr, 'invalid_vet'.tr);
      }
    }

    if (mounted) {
      setState(() => isProcessing = false);
    }
  }
}
