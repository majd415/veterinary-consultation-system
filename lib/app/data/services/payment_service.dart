import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'api_service.dart';

class PaymentService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<PaymentService> init() async {
    await _setupStripe();
    return this;
  }

  Future<void> _setupStripe() async {
    try {
      final response = await _apiService.getStripePublishableKey();
      if (response.statusCode == 200) {
        final String key = response.body['publishable_key'];
        if (key.isNotEmpty) {
          Stripe.publishableKey = key;
          await Stripe.instance.applySettings();
          print('Stripe successfully initialized with key: $key');
        } else {
          print('WARNING: Stripe publishable key is empty in the database!');
        }
      } else {
        print(
          'ERROR: Failed to fetch Stripe key. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error initializing Stripe: $e');
    }
  }

  Future<String?> makePayment({
    required double amount,
    String currency = 'USD',
    required String merchantDisplayName,
  }) async {
    try {
      // 1. Create Payment Intent on backend
      final response = await _apiService.createPaymentIntent(amount, currency);

      if (response.statusCode != 200) {
        Get.snackbar(
          'Error',
          'Failed to create payment session: ${response.body['error'] ?? 'Unknown error'}',
        );
        return null; // Return null on failure
      }

      final String clientSecret = response.body['clientSecret'];
      final String transactionId =
          response.body['id']; // Capture Transaction ID

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.system,
          allowsDelayedPaymentMethods: true,
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
                address: AddressCollectionMode.never,
                email: CollectionMode.always,
                name: CollectionMode.always,
                phone: CollectionMode.never,
              ),
        ),
      );

      // 3. Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      return transactionId; // Return ID on success
    } on StripeException catch (e) {
      if (e.error.code == 'Canceled') {
        print('Payment canceled by user');
      } else {
        Get.snackbar(
          'Payment Error',
          e.error.localizedMessage ?? 'An error occurred during payment',
        );
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
      return null;
    }
  }
}
