import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../grooming_controller.dart';

class GroomingView extends GetView<GroomingController> {
  const GroomingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'grooming'.tr,
          style: const TextStyle(color: AppColors.text),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  Text(
                    'grooming'.tr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildPicker(
                    context,
                    title: 'pickup_date'.tr,
                    value: Obx(
                      () => Text(
                        controller.pickupDate.value.toString().split(' ')[0],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => controller.selectPickupDate(context),
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),
                  _buildPicker(
                    context,
                    title: 'pickup_time'.tr,
                    value: Obx(
                      () => Text(
                        controller.pickupTime.value.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => controller.selectPickupTime(context),
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 16),
                  _buildPicker(
                    context,
                    title: 'delivery_date'.tr,
                    value: Obx(
                      () => Text(
                        controller.deliveryDate.value.toString().split(' ')[0],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => controller.selectDeliveryDate(context),
                    icon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildPicker(
                    context,
                    title: 'delivery_time'.tr,
                    value: Obx(
                      () => Text(
                        controller.deliveryTime.value.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => controller.selectDeliveryTime(context),
                    icon: Icons.access_time_outlined,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: controller.clientNameController,
                    decoration: InputDecoration(
                      labelText: 'client_name'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.clientPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'client_phone'.tr,
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
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: controller.decrementAnimals,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: AppColors.primary,
                              ),
                              Expanded(
                                child: Obx(
                                  () => Text(
                                    '${controller.numAnimals.value}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: controller.incrementAnimals,
                                icon: const Icon(Icons.add_circle_outline),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: controller.animalTypeController,
                          decoration: InputDecoration(
                            labelText: 'animal_type_hint'.tr,
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
                      onPressed: controller.proceedToPayment,
                      child: Text('proceed_payment'.tr),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'recent_appointments'.tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.isBookingLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (controller.bookings.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'no_appointments'.tr,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.bookings.length,
                      itemBuilder: (context, index) {
                        final booking = controller.bookings[index];
                        final pickupDateTime = DateTime.parse(
                          '${booking['pickup_date']} ${booking['pickup_time']}',
                        );
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final isPast = pickupDateTime.isBefore(today);

                        return GestureDetector(
                          onTap: isPast
                              ? null
                              : () => Get.toNamed(
                                  '/appointment_details',
                                  arguments: booking,
                                ),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isPast ? Colors.red[50] : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: isPast
                                  ? BorderSide(color: Colors.red[300]!)
                                  : BorderSide.none,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isPast
                                    ? Colors.red.withValues(alpha: 0.2)
                                    : AppColors.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  isPast ? Icons.history : Icons.check,
                                  color: isPast
                                      ? Colors.red
                                      : AppColors.primary,
                                ),
                              ),
                              title: Text(
                                booking['client_name'] ?? 'N/A',
                                style: TextStyle(
                                  color: isPast
                                      ? Colors.red[700]
                                      : AppColors.text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${booking['pickup_date']} - ${booking['num_animals']} ${booking['animal_type']?['en'] ?? booking['animal_type'] ?? ''}',
                                style: TextStyle(
                                  color: isPast
                                      ? Colors.red[600]
                                      : Colors.grey[600],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    booking['pickup_time'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isPast
                                          ? Colors.red[700]
                                          : AppColors.text,
                                    ),
                                  ),
                                  if (isPast)
                                    Text(
                                      'Past',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
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
}
