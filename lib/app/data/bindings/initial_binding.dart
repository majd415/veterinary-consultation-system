import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';
import '../../modules/auth/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.put(PaymentService(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}
