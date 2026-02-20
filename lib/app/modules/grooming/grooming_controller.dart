import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/api_service.dart';
import '../../data/utils/loading_overlay.dart';

class GroomingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var pickupDate = DateTime.now().obs;
  var deliveryDate = DateTime.now().add(const Duration(hours: 2)).obs;
  var pickupTime = TimeOfDay.now().obs;
  var deliveryTime = TimeOfDay.now().plus(minutes: 120).obs;

  final clientNameController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final animalTypeController = TextEditingController();

  var numAnimals = 1.obs;
  var isBookingLoading = false.obs;
  var bookings = <dynamic>[].obs;

  // Backwards compatibility
  RxList<dynamic> get appointments => bookings;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  void incrementAnimals() => numAnimals.value++;
  void decrementAnimals() {
    if (numAnimals.value > 1) numAnimals.value--;
  }

  Future<void> fetchBookings() async {
    isBookingLoading.value = true;
    try {
      final response = await _apiService.getGroomingBookings();
      if (response.status.isOk) {
        bookings.assignAll(response.body);
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    } finally {
      isBookingLoading.value = false;
    }
  }

  Future<void> createBooking(Map<String, dynamic> data) async {
    LoadingOverlay.show();
    try {
      final response = await _apiService.storeGroomingBooking(data);
      if (response.status.isOk) {
        Get.snackbar('Success', 'Grooming service booked successfully!');
        _clearFields();
        await fetchBookings();
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Error', 'Failed to create booking');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      LoadingOverlay.hide();
    }
  }

  // For payment view
  void addAppointment({required String transactionId}) {
    final bookingData = {
      'pickup_date': pickupDate.value.toIso8601String().split('T')[0],
      'pickup_time':
          '${pickupTime.value.hour.toString().padLeft(2, '0')}:${pickupTime.value.minute.toString().padLeft(2, '0')}',
      'delivery_date': deliveryDate.value.toIso8601String().split('T')[0],
      'delivery_time':
          '${deliveryTime.value.hour.toString().padLeft(2, '0')}:${deliveryTime.value.minute.toString().padLeft(2, '0')}',
      'client_name': clientNameController.text,
      'client_phone': clientPhoneController.text,
      'num_animals': numAnimals.value,
      'animal_type': animalTypeController.text,
      'transaction_id': transactionId,
      'payment_method': 'stripe',
      'amount': (50.0 * numAnimals.value), // Approximation or calculated price
      'currency': 'USD',
    };
    createBooking(bookingData);
  }

  void updateAppointment(String id, Map<String, dynamic> data) {
    updateBooking(int.parse(id), data);
  }

  void selectPickupDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickupDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      pickupDate.value = picked;
      if (deliveryDate.value.isBefore(picked)) {
        deliveryDate.value = picked.add(const Duration(hours: 2));
      }
    }
  }

  void selectDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: deliveryDate.value,
      firstDate: pickupDate.value,
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      deliveryDate.value = picked;
    }
  }

  void selectPickupTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: pickupTime.value,
    );
    if (picked != null) {
      pickupTime.value = picked;
    }
  }

  void selectDeliveryTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: deliveryTime.value,
    );
    if (picked != null) {
      deliveryTime.value = picked;
    }
  }

  void proceedToPayment() {
    if (clientNameController.text.isEmpty ||
        clientPhoneController.text.isEmpty ||
        animalTypeController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    // Passing booking data to payment view
    Get.toNamed(
      '/grooming_payment',
      arguments: {
        'pickup_date': pickupDate.value.toIso8601String().split('T')[0],
        'pickup_time':
            '${pickupTime.value.hour.toString().padLeft(2, '0')}:${pickupTime.value.minute.toString().padLeft(2, '0')}',
        'delivery_date': deliveryDate.value.toIso8601String().split('T')[0],
        'delivery_time':
            '${deliveryTime.value.hour.toString().padLeft(2, '0')}:${deliveryTime.value.minute.toString().padLeft(2, '0')}',
        'client_name': clientNameController.text,
        'client_phone': clientPhoneController.text,
        'num_animals': numAnimals.value,
        'animal_type': animalTypeController.text,
      },
    );
  }

  Future<void> updateBooking(int id, Map<String, dynamic> data) async {
    LoadingOverlay.show();
    try {
      final response = await _apiService.updateGroomingBooking(
        id.toString(),
        data,
      );
      if (response.status.isOk) {
        await fetchBookings();
        LoadingOverlay.hide();
        Get.back();
        Get.snackbar('Success', 'Booking updated successfully!');
      } else {
        LoadingOverlay.hide();
        Get.snackbar('Error', 'Failed to update booking');
      }
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  void _clearFields() {
    clientNameController.clear();
    clientPhoneController.clear();
    animalTypeController.clear();
    numAnimals.value = 1;
  }
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay plus({int minutes = 0}) {
    final totalMinutes = hour * 60 + minute + minutes;
    return TimeOfDay(hour: totalMinutes ~/ 60 % 24, minute: totalMinutes % 60);
  }
}
