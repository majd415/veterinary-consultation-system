import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.background, Colors.white],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'register'.tr,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Role Toggle
                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.setRole('user'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          controller.selectedRole.value ==
                                              'user'
                                          ? AppColors.primary
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'pet_owner'.tr,
                                        style: TextStyle(
                                          color:
                                              controller.selectedRole.value ==
                                                  'user'
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.setRole('vet'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          controller.selectedRole.value == 'vet'
                                          ? AppColors.primary
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'veterinarian'.tr,
                                        style: TextStyle(
                                          color:
                                              controller.selectedRole.value ==
                                                  'vet'
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Photo Upload Placeholder
                        Obx(
                          () => GestureDetector(
                            onTap: controller.isLoading.value
                                ? null
                                : controller.pickImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                image:
                                    controller.profilePhotoUrl.value.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          controller.profilePhotoUrl.value,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: controller.profilePhotoUrl.value.isEmpty
                                  ? const Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey,
                                      size: 40,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('upload_photo'.tr),
                        const SizedBox(height: 20),

                        TextField(
                          controller: controller.nameController,
                          decoration: InputDecoration(
                            labelText: 'full_name'.tr,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'phone_number'.tr,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'email'.tr,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Obx(
                          () => TextField(
                            controller: controller.passwordController,
                            obscureText: !controller.isPasswordVisible.value,
                            decoration: InputDecoration(
                              labelText: 'password'.tr,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: controller.bioController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'bio'.tr,
                            prefixIcon: const Icon(Icons.info_outline),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.startRegistration,
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text('register'.tr),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
