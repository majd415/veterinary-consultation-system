import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';
import 'app/routes/app_pages.dart';
import 'app/data/bindings/initial_binding.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/api_service.dart';
import 'app/data/services/payment_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize services
  Get.put(ApiService());
  await Get.putAsync(() => NotificationService().init());
  await Get.putAsync(() => PaymentService().init());

  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('is_first_run') ?? true;
  final initialRoute = isFirstRun ? Routes.LANGUAGE : Routes.ONBOARDING;

  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final languageCode = prefs.getString('language') ?? 'en';

  runApp(
    MyApp(
      initialRoute: initialRoute,
      isDarkMode: isDarkMode,
      languageCode: languageCode,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final bool isDarkMode;
  final String languageCode;

  const MyApp({
    super.key,
    required this.initialRoute,
    required this.isDarkMode,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pet Services',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      translations: AppTranslations(),
      locale: Locale(languageCode),
      fallbackLocale: const Locale('en', 'US'),
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
