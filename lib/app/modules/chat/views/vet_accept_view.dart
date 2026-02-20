import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat_controller.dart';

class VetAcceptView extends GetView<ChatController> {
  const VetAcceptView({super.key});

  @override
  Widget build(BuildContext context) {
    final chatRequestId = Get.parameters['chat_request_id'];

    return Scaffold(
      appBar: AppBar(title: Text('new_vet_request'.tr), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notification_important,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'client_needs_help'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'request_id'.tr + '$chatRequestId',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (chatRequestId != null) {
                      controller.acceptRequest(chatRequestId);
                    }
                  },
                  child: Text(
                    'accept_consultation'.tr,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('decline'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
