import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../hotel_controller.dart';

class HotelReservationDetailsView extends StatefulWidget {
  const HotelReservationDetailsView({super.key});

  @override
  State<HotelReservationDetailsView> createState() =>
      _HotelReservationDetailsViewState();
}

class _HotelReservationDetailsViewState
    extends State<HotelReservationDetailsView> {
  // Helper to calculate totals
  void _calculateTotals() {
    final days = checkOutDate.difference(checkInDate).inDays;
    totalDays = days > 0 ? days : 1;
    totalCost = totalDays * 50.0;
  }

  final controller = Get.find<HotelController>();
  late Map<String, dynamic> booking;

  late TextEditingController ownerNameController;
  late TextEditingController ownerPhoneController;

  late DateTime checkInDate;
  late DateTime checkOutDate;
  late TimeOfDay checkInTime;
  late TimeOfDay checkOutTime;
  late int totalDays;
  late double totalCost;
  late int numPets;
  late String selectedPetType;

  @override
  void initState() {
    super.initState();
    booking = Get.arguments;

    ownerNameController = TextEditingController(
      text: booking['owner_name'] ?? '',
    );
    ownerPhoneController = TextEditingController(
      text: booking['owner_phone'] ?? '',
    );

    // Parse dates
    checkInDate = DateTime.parse(booking['check_in_date']);
    checkOutDate = DateTime.parse(booking['check_out_date']);

    // Parse times
    final checkInParts = booking['check_in_time'].toString().split(':');
    checkInTime = TimeOfDay(
      hour: int.parse(checkInParts[0]),
      minute: int.parse(checkInParts[1]),
    );

    final checkOutParts = booking['check_out_time'].toString().split(':');
    checkOutTime = TimeOfDay(
      hour: int.parse(checkOutParts[0]),
      minute: int.parse(checkOutParts[1]),
    );

    totalDays = booking['total_days'] ?? 1;

    // Parse total_cost - backend may return string or number
    final costValue = booking['total_cost'];
    if (costValue is String) {
      totalCost = double.tryParse(costValue) ?? 50.0;
    } else if (costValue is num) {
      totalCost = costValue.toDouble();
    } else {
      totalCost = 50.0;
    }

    numPets = booking['num_pets'] ?? 1;

    // Handle translatable pet_type
    final petType = booking['pet_type'];
    if (petType is Map) {
      selectedPetType = petType['en'] ?? petType['ar'] ?? 'Dog';
    } else {
      selectedPetType = petType?.toString() ?? 'Dog';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Reservation',
          style: TextStyle(color: AppColors.text),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPicker(
              context,
              title: 'Check-In Date',
              value: Text(
                checkInDate.toString().split(' ')[0],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: checkInDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    checkInDate = picked;
                    if (checkOutDate.isBefore(picked)) {
                      checkOutDate = picked.add(const Duration(days: 1));
                    }
                    _calculateTotals();
                  });
                }
              },
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildPicker(
              context,
              title: 'Check-In Time',
              value: Text(
                checkInTime.format(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: checkInTime,
                );
                if (picked != null) setState(() => checkInTime = picked);
              },
              icon: Icons.access_time,
            ),
            const SizedBox(height: 16),
            _buildPicker(
              context,
              title: 'Check-Out Date',
              value: Text(
                checkOutDate.toString().split(' ')[0],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: checkOutDate,
                  firstDate: checkInDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    checkOutDate = picked;
                    _calculateTotals();
                  });
                }
              },
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 16),
            _buildPicker(
              context,
              title: 'Check-Out Time',
              value: Text(
                checkOutTime.format(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: checkOutTime,
                );
                if (picked != null) setState(() => checkOutTime = picked);
              },
              icon: Icons.access_time_outlined,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: ownerNameController,
              decoration: InputDecoration(
                labelText: 'Owner Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ownerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Owner Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Days:'),
                      Row(
                        children: [
                          Text(
                            '$totalDays',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Cost:'),
                      Text(
                        '\$${totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pet Type'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: controller.petTypes.map((type) {
                      final isSelected = selectedPetType == type;
                      return GestureDetector(
                        child: Chip(
                          label: Text(type),
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : Colors.grey[200],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Update Reservation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(
    BuildContext context, {
    required String title,
    required Widget value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                value,
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    final id = booking['id'];
    final data = {
      'check_in_date': checkInDate.toIso8601String().split('T')[0],
      'check_in_time':
          '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}',
      'check_out_date': checkOutDate.toIso8601String().split('T')[0],
      'check_out_time':
          '${checkOutTime.hour.toString().padLeft(2, '0')}:${checkOutTime.minute.toString().padLeft(2, '0')}',
      'owner_name': ownerNameController.text,
      'owner_phone': ownerPhoneController.text,
      'num_pets': numPets,
      'pet_type': selectedPetType,
      'total_days': totalDays,
      'total_cost': totalCost,
    };

    controller.updateBooking(id, data);
  }
}
