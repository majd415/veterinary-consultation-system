import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';

class LoadingOverlay {
  static bool _isShowing = false;

  static void show() {
    if (_isShowing) return;
    _isShowing = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use a generic lottie animation if specific one not found
                // Lottie.asset('assets/lottie/loading.json', width: 150, height: 150),
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 20),
                const Text(
                  'Loading...',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (!_isShowing) return;
    _isShowing = false;
    _retryHide(0);
  }

  static void _retryHide(int attempt) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
      // Double check after a delay to handle cases where Get.back() was ignored
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      });
    } else if (attempt < 20) {
      // If not open yet, wait 100ms and try again (up to 2 seconds)
      Future.delayed(const Duration(milliseconds: 100), () {
        _retryHide(attempt + 1);
      });
    }
  }
}
