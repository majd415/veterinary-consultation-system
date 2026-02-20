import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../hotel_controller.dart';

class HotelView extends GetView<HotelController> {
  const HotelView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('hotel'.tr), elevation: 0),
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
                    'book_stay'.tr,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildPicker(
                    context,
                    title: 'check_in_date'.tr,
                    value: Obx(
                      () => Text(
                        controller.checkInDate.value.toString().split(' ')[0],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => controller.selectCheckInDate(context),
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),
                  _buildPicker(
                    context,
                    title: 'check_in_time'.tr,
                    value: Obx(
                      () => Text(
                        controller.checkInTime.value.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => controller.selectCheckInTime(context),
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 16),
                  _buildPicker(
                    context,
                    title: 'check_out_date'.tr,
                    value: Obx(
                      () => Text(
                        controller.checkOutDate.value.toString().split(' ')[0],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => controller.selectCheckOutDate(context),
                    icon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildPicker(
                    context,
                    title: 'check_out_time'.tr,
                    value: Obx(
                      () => Text(
                        controller.checkOutTime.value.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => controller.selectCheckOutTime(context),
                    icon: Icons.access_time_outlined,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: controller.ownerNameController,
                    decoration: InputDecoration(
                      labelText: 'owner_name'.tr,
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.ownerPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'owner_phone'.tr,
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('pet_type'.tr, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 10),
                  Obx(
                    () => Row(
                      children: controller.petTypes.map((type) {
                        final isSelected =
                            controller.selectedPetType.value == type;
                        return GestureDetector(
                          onTap: () => controller.setPetType(type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkSurface
                                        : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.transparent,
                                    ),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                            Text('num_pets'.tr),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: controller.decrementPets,
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppColors.primary,
                                ),
                                Obx(
                                  () => Text(
                                    '${controller.numPets}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: controller.incrementPets,
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('total_days'.tr),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: controller.decrementDays,
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppColors.primary,
                                ),
                                Obx(
                                  () => Text(
                                    '${controller.totalDays}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: controller.incrementDays,
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('total_cost'.tr),
                            Obx(
                              () => Text(
                                '\$${controller.totalCost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                    'recent_reservations'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
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
                            'no_reservations'.tr,
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
                        final checkInDateTime = DateTime.parse(
                          '${booking['check_in_date']} ${booking['check_in_time']}',
                        );
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final isPast = checkInDateTime.isBefore(today);

                        return GestureDetector(
                          onTap: isPast
                              ? null
                              : () => Get.toNamed(
                                  '/hotel-reservation-details',
                                  arguments: booking,
                                ),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isPast ? Colors.red[50] : null,
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
                                  isPast ? Icons.history : Icons.hotel,
                                  color: isPast
                                      ? Colors.red
                                      : AppColors.primary,
                                ),
                              ),
                              title: Text(
                                booking['owner_name'] ?? 'N/A',
                                style: TextStyle(
                                  color: isPast ? Colors.red[700] : null,
                                ),
                              ),
                              subtitle: Text(
                                '${booking['total_days']} Days - ${booking['pet_type']?['en'] ?? booking['pet_type'] ?? ''}',
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
                                    '\$${booking['total_cost']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isPast
                                          ? Colors.red[700]
                                          : AppColors.primary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black26
                  : Colors.black.withValues(alpha: 0.05),
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
                Text(title, style: theme.textTheme.bodySmall),
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
