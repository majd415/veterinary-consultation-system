import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/api_service.dart';
import '../../data/utils/loading_overlay.dart';

class HotelController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var checkInDate = DateTime.now().obs;
  var checkOutDate = DateTime.now().add(const Duration(days: 1)).obs;
  var checkInTime = TimeOfDay.now().obs;
  var checkOutTime = TimeOfDay.now().plus(minutes: 120).obs;

  var selectedPetType = 'Dog'.obs;
  final petTypes = ['Dog', 'Cat', 'Bird', 'Other'];

  final ownerNameController = TextEditingController();
  final ownerPhoneController = TextEditingController();

  var numPets = 1.obs;
  var totalDays = 1.obs;
  var totalCost = 50.0.obs;

  var bookings = <dynamic>[].obs;
  var isBookingLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  void incrementPets() {
    numPets.value++;
    _calculateCost();
  }

  void decrementPets() {
    if (numPets.value > 1) {
      numPets.value--;
      _calculateCost();
    }
  }

  void incrementDays() {
    totalDays.value++;
    _calculateCost();
  }

  void decrementDays() {
    if (totalDays.value > 1) {
      totalDays.value--;
      _calculateCost();
    }
  }

  void _calculateCost() {
    totalCost.value = totalDays.value * numPets.value * 50.0;
  }

  Future<void> fetchBookings() async {
    isBookingLoading.value = true;
    try {
      final response = await _apiService.getHotelBookings();
      if (response.status.isOk) {
        bookings.assignAll(response.body);
      }
    } catch (e) {
      print('Error fetching hotel bookings: $e');
    } finally {
      isBookingLoading.value = false;
    }
  }

  void selectCheckInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: checkInDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      checkInDate.value = picked;
      if (checkOutDate.value.isBefore(picked)) {
        checkOutDate.value = picked.add(const Duration(days: 1));
      }
    }
  }

  void selectCheckOutDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: checkOutDate.value,
      firstDate: checkInDate.value,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      checkOutDate.value = picked;
    }
  }

  void selectCheckInTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: checkInTime.value,
    );
    if (picked != null) {
      checkInTime.value = picked;
    }
  }

  void selectCheckOutTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: checkOutTime.value,
    );
    if (picked != null) {
      checkOutTime.value = picked;
    }
  }

  void setPetType(String type) {
    selectedPetType.value = type;
  }

  void proceedToPayment() {
    if (ownerNameController.text.isEmpty || ownerPhoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    Get.toNamed(
      '/hotel_payment',
      arguments: {
        'check_in_date': checkInDate.value.toIso8601String().split('T')[0],
        'check_in_time':
            '${checkInTime.value.hour.toString().padLeft(2, '0')}:${checkInTime.value.minute.toString().padLeft(2, '0')}',
        'check_out_date': checkOutDate.value.toIso8601String().split('T')[0],
        'check_out_time':
            '${checkOutTime.value.hour.toString().padLeft(2, '0')}:${checkOutTime.value.minute.toString().padLeft(2, '0')}',
        'owner_name': ownerNameController.text,
        'owner_phone': ownerPhoneController.text,
        'num_pets': numPets.value,
        'pet_type': selectedPetType.value,
        'total_days': totalDays.value,
        'total_cost': totalCost.value,
      },
    );
  }

  Future<void> createBooking(Map<String, dynamic> data) async {
    LoadingOverlay.show();
    try {
      final response = await _apiService.storeHotelBooking(data);
      if (response.status.isOk) {
        Get.snackbar('Success', 'Hotel booking created successfully!');
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

  Future<void> updateBooking(int id, Map<String, dynamic> data) async {
    LoadingOverlay.show();
    try {
      final response = await _apiService.updateHotelBooking(
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

  void addReservation({required String transactionId}) {
    final bookingData = {
      'check_in_date': checkInDate.value.toIso8601String().split('T')[0],
      'check_in_time':
          '${checkInTime.value.hour.toString().padLeft(2, '0')}:${checkInTime.value.minute.toString().padLeft(2, '0')}',
      'check_out_date': checkOutDate.value.toIso8601String().split('T')[0],
      'check_out_time':
          '${checkOutTime.value.hour.toString().padLeft(2, '0')}:${checkOutTime.value.minute.toString().padLeft(2, '0')}',
      'owner_name': ownerNameController.text,
      'owner_phone': ownerPhoneController.text,
      'num_pets': numPets.value,
      'pet_type': selectedPetType.value,
      'total_days': totalDays.value,
      'total_cost': totalCost.value,
      'transaction_id': transactionId,
      'payment_method': 'stripe',
      'amount': totalCost.value,
      'currency': 'USD',
    };
    createBooking(bookingData);
  }

  void _clearFields() {
    ownerNameController.clear();
    ownerPhoneController.clear();
    numPets.value = 1;
    totalDays.value = 1;
    selectedPetType.value = 'Dog';
    checkInDate.value = DateTime.now();
    checkOutDate.value = DateTime.now().add(const Duration(days: 1));
    _calculateCost();
  }
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay plus({int minutes = 0}) {
    final totalMinutes = hour * 60 + minute + minutes;
    return TimeOfDay(hour: totalMinutes ~/ 60 % 24, minute: totalMinutes % 60);
  }
}
