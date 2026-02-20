import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../theme/app_colors.dart';
import '../auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.background, Colors.white],
              ),
            ),
          ),
          // Decorative Circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.1),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.pets, size: 80, color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    'welcome'.tr,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Glassmorphism Card
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
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
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

                        // Login Method Toggle
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => controller.setLoginMethod('email'),
                                child: Text(
                                  'email'.tr,
                                  style: TextStyle(
                                    color:
                                        controller.loginMethod.value == 'email'
                                        ? AppColors.primary
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        controller.loginMethod.value == 'email'
                                        ? TextDecoration.underline
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () => controller.setLoginMethod('phone'),
                                child: Text(
                                  'phone'.tr,
                                  style: TextStyle(
                                    color:
                                        controller.loginMethod.value == 'phone'
                                        ? AppColors.primary
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        controller.loginMethod.value == 'phone'
                                        ? TextDecoration.underline
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Inputs
                        Obx(
                          () => controller.loginMethod.value == 'email'
                              ? TextField(
                                  controller: controller.emailController,
                                  decoration: InputDecoration(
                                    labelText: 'email'.tr,
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                  ),
                                )
                              : TextField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'phone_number'.tr,
                                    prefixIcon: const Icon(Icons.phone),
                                  ),
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
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                Get.toNamed(Routes.FORGOT_PASSWORD),
                            child: Text('forgot_password'.tr),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.login,
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text('login'.tr),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'dont_have_account'.tr,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.REGISTER),
                        child: Text('register'.tr),
                      ),
                    ],
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
