import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../theme/app_colors.dart';
import '../auth_controller.dart';

class VerificationView extends GetView<AuthController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final type = args?['type'] ?? 'register'; // 'register' or 'reset'

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
                  // Lottie Animation Placeholder
                  // If you have a lottie file, use Lottie.asset('assets/lottie/verification.json')
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 100,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Verification',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter the 4-digit code sent to your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
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
                        TextField(
                          controller: controller.codeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 4,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 10,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            hintText: '0000',
                          ),
                        ),
                        const SizedBox(height: 30),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      if (type == 'register') {
                                        controller.verifyAndRegister();
                                      } else {
                                        controller.verifyResetCode();
                                      }
                                    },
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text('Verify'),
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
