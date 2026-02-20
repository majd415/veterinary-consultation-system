import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../grooming_controller.dart';

class AppointmentDetailsView extends StatefulWidget {
  const AppointmentDetailsView({super.key});

  @override
  State<AppointmentDetailsView> createState() => _AppointmentDetailsViewState();
}

class _AppointmentDetailsViewState extends State<AppointmentDetailsView> {
  final controller = Get.find<GroomingController>();
  late Map<String, dynamic> appointment;

  late TextEditingController clientNameController;
  late TextEditingController clientPhoneController;
  late TextEditingController numAnimalsController;
  late TextEditingController animalTypeController;

  late DateTime pickupDate;
  late DateTime deliveryDate;
  late TimeOfDay pickupTime;
  late TimeOfDay deliveryTime;

  @override
  void initState() {
    super.initState();
    appointment = Get.arguments;

    // Handle both old local format and new backend format
    clientNameController = TextEditingController(
      text: appointment['client_name'] ?? appointment['client'] ?? '',
    );
    clientPhoneController = TextEditingController(
      text: appointment['client_phone'] ?? appointment['phone'] ?? '',
    );
    numAnimalsController = TextEditingController(
      text: (appointment['num_animals'] ?? appointment['animals'] ?? '1')
          .toString(),
    );

    // Handle translatable animal_type
    final animalType = appointment['animal_type'];
    String animalTypeStr = '';
    if (animalType is Map) {
      animalTypeStr = animalType['en'] ?? animalType['ar'] ?? '';
    } else if (animalType is String) {
      animalTypeStr = animalType;
    } else {
      animalTypeStr = appointment['type'] ?? '';
    }
    animalTypeController = TextEditingController(text: animalTypeStr);

    // Parse dates - handle both DateTime objects and string dates
    if (appointment['pickup_date'] != null) {
      pickupDate = appointment['pickup_date'] is DateTime
          ? appointment['pickup_date']
          : DateTime.parse(appointment['pickup_date']);
    } else if (appointment['pickupDate'] != null) {
      pickupDate = appointment['pickupDate'] is DateTime
          ? appointment['pickupDate']
          : DateTime.parse(appointment['pickupDate'].toString());
    } else {
      pickupDate = DateTime.now();
    }

    if (appointment['delivery_date'] != null) {
      deliveryDate = appointment['delivery_date'] is DateTime
          ? appointment['delivery_date']
          : DateTime.parse(appointment['delivery_date']);
    } else if (appointment['deliveryDate'] != null) {
      deliveryDate = appointment['deliveryDate'] is DateTime
          ? appointment['deliveryDate']
          : DateTime.parse(appointment['deliveryDate'].toString());
    } else {
      deliveryDate = DateTime.now();
    }

    // Parse times - handle both TimeOfDay objects and string times
    if (appointment['pickup_time'] != null) {
      if (appointment['pickup_time'] is TimeOfDay) {
        pickupTime = appointment['pickup_time'];
      } else {
        final parts = appointment['pickup_time'].toString().split(':');
        pickupTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } else if (appointment['pickupTime'] != null) {
      pickupTime = appointment['pickupTime'];
    } else {
      pickupTime = TimeOfDay.now();
    }

    if (appointment['delivery_time'] != null) {
      if (appointment['delivery_time'] is TimeOfDay) {
        deliveryTime = appointment['delivery_time'];
      } else {
        final parts = appointment['delivery_time'].toString().split(':');
        deliveryTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } else if (appointment['deliveryTime'] != null) {
      deliveryTime = appointment['deliveryTime'];
    } else {
      deliveryTime = TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Appointment',
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
              title: 'Pickup Date',
              value: Text(
                pickupDate.toString().split(' ')[0],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: pickupDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => pickupDate = picked);
              },
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildPicker(
              context,
              title: 'Pickup Time',
              value: Text(
                pickupTime.format(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: pickupTime,
                );
                if (picked != null) setState(() => pickupTime = picked);
              },
              icon: Icons.access_time,
            ),
            const SizedBox(height: 16),
            _buildPicker(
              context,
              title: 'Delivery Date',
              value: Text(
                deliveryDate.toString().split(' ')[0],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: deliveryDate,
                  firstDate: pickupDate,
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => deliveryDate = picked);
              },
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 16),
            _buildPicker(
              context,
              title: 'Delivery Time',
              value: Text(
                deliveryTime.format(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: deliveryTime,
                );
                if (picked != null) setState(() => deliveryTime = picked);
              },
              icon: Icons.access_time_outlined,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: clientNameController,
              decoration: InputDecoration(
                labelText: 'Client Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: clientPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Client Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: numAnimalsController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'No. of Animals (Locked)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(Icons.pets),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: animalTypeController,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
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
    final id = appointment['id'];
    final data = {
      'pickup_date': pickupDate.toIso8601String().split('T')[0],
      'pickup_time':
          '${pickupTime.hour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}',
      'delivery_date': deliveryDate.toIso8601String().split('T')[0],
      'delivery_time':
          '${deliveryTime.hour.toString().padLeft(2, '0')}:${deliveryTime.minute.toString().padLeft(2, '0')}',
      'client_name': clientNameController.text,
      'client_phone': clientPhoneController.text,
      'num_animals': int.tryParse(numAnimalsController.text) ?? 1,
      'animal_type': animalTypeController.text,
    };

    controller.updateBooking(id, data);
  }
}
