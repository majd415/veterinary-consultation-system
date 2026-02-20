import 'package:get/get.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/onboarding/onboarding_controller.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/role_selection_view.dart';

import '../modules/home/views/home_view.dart';
import '../modules/home/home_controller.dart' hide HomeCategory;
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/profile_controller.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat/views/vet_list_view.dart';
import '../modules/chat/views/vet_payment_view.dart';
import '../modules/chat/views/vet_accept_view.dart';
import '../modules/chat/chat_controller.dart';
import '../modules/store/views/store_view.dart';
import '../modules/store/views/product_details_view.dart';
import '../modules/store/views/cart_view.dart';
import '../modules/store/views/payment_view.dart';
import '../modules/store/views/store_payment_view.dart';
import '../modules/store/views/invoice_view.dart';
import '../modules/store/store_controller.dart';
import '../modules/grooming/views/grooming_view.dart';
import '../modules/grooming/views/grooming_payment_view.dart';
import '../modules/grooming/views/appointment_details_view.dart';
import '../modules/grooming/grooming_controller.dart';
import '../modules/hotel/views/hotel_view.dart';
import '../modules/hotel/views/hotel_payment_view.dart';
import '../modules/hotel/views/hotel_reservation_details_view.dart';
import '../modules/hotel/hotel_controller.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/notification/notification_controller.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/settings_controller.dart';

import '../modules/auth/views/verification_view.dart';
import '../modules/auth/views/reset_password_view.dart';
import '../modules/language/views/language_view.dart';
import '../modules/language/language_controller.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.ONBOARDING;

  static final routes = [
    GetPage(
      name: Routes.LANGUAGE,
      page: () => const LanguageView(),
      binding: BindingsBuilder(() {
        Get.put(LanguageController());
      }),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: Routes.ROLE_SELECTION,
      page: () => const RoleSelectionView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => const ChatView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatController());
      }),
    ),
    GetPage(
      name: Routes.VET_LIST,
      page: () => const VetListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatController());
      }),
    ),
    GetPage(
      name: Routes.VET_PAYMENT,
      page: () => const VetPaymentView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatController());
      }),
    ),
    GetPage(
      name: Routes.STORE,
      page: () => const StoreView(),
      binding: BindingsBuilder(() {
        Get.put(StoreController());
      }),
    ),
    GetPage(
      name: Routes.PRODUCT_DETAILS,
      page: () => const ProductDetailsView(),
      binding: BindingsBuilder(() {
        Get.put(StoreController());
      }),
    ),
    GetPage(
      name: Routes.CART,
      page: () => const CartView(),
      binding: BindingsBuilder(() {
        Get.put(StoreController());
      }),
    ),
    GetPage(
      name: Routes.GROOMING,
      page: () => const GroomingView(),
      binding: BindingsBuilder(() {
        Get.put(GroomingController());
      }),
    ),
    GetPage(
      name: Routes.HOTEL,
      page: () => const HotelView(),
      binding: BindingsBuilder(() {
        Get.put(HotelController());
      }),
    ),
    GetPage(
      name: Routes.NOTIFICATION,
      page: () => const NotificationView(),
      binding: BindingsBuilder(() {
        Get.put(NotificationController());
      }),
    ),
    GetPage(name: Routes.PAYMENT, page: () => const PaymentView()),
    GetPage(
      name: Routes.GROOMING_PAYMENT,
      page: () => const GroomingPaymentView(),
    ),
    GetPage(
      name: Routes.APPOINTMENT_DETAILS,
      page: () => const AppointmentDetailsView(),
    ),
    GetPage(name: Routes.HOTEL_PAYMENT, page: () => const HotelPaymentView()),
    GetPage(
      name: Routes.HOTEL_RESERVATION_DETAILS,
      page: () => const HotelReservationDetailsView(),
    ),
    GetPage(
      name: Routes.STORE_PAYMENT,
      page: () => const StorePaymentView(),
      binding: BindingsBuilder(() {
        Get.put(StoreController());
      }),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.put(SettingsController());
      }),
    ),
    GetPage(
      name: Routes.INVOICE,
      page: () => const InvoiceView(),
      binding: BindingsBuilder(() {
        Get.put(StoreController());
      }),
    ),
    GetPage(
      name: Routes.VERIFICATION,
      page: () => const VerificationView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: BindingsBuilder(() {}),
    ),
    GetPage(
      name: Routes.VET_ACCEPT,
      page: () => const VetAcceptView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatController());
      }),
    ),
  ];
}
