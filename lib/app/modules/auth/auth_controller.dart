import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/app_pages.dart';
import '../../data/services/api_service.dart';
import '../../data/utils/loading_overlay.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final bioController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var selectedRole = 'user'.obs; // 'user' or 'vet'
  var loginMethod = 'email'.obs; // 'email' or 'phone'

  var profilePhotoUrl = ''.obs;
  var userName = 'Pet User'.obs;
  var pickedImage = Rxn<XFile>();

  @override
  void onInit() {
    super.onInit();
    _initFcmRefreshListener();
    _initForegroundListener(); // لتلقي الإشعارات بالـ foreground

    loadSessionData();
    checkLoginStatus();
  }

  void _initForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.notification?.title}');
      // هنا ممكن تعمل أي شيء بالإشعار، تخزن بياناته أو تظهر SnackBar
    });
  }

  Future<void> loadSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('user_name') ?? 'Pet User';
    profilePhotoUrl.value = prefs.getString('user_avatar') ?? '';
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void setRole(String role) {
    selectedRole.value = role;
  }

  void setLoginMethod(String method) {
    loginMethod.value = method;
  }

  //  Future<void> login() async {
  //   if (emailController.text.isEmpty || passwordController.text.isEmpty) {
  //     Get.snackbar('Error', 'Please fill all fields');
  //     return;
  //   }

  //   isLoading.value = true;
  //   LoadingOverlay.show();
  //   try {
  //     final response = await _apiService.login(
  //       emailController.text,
  //       passwordController.text,
  //       selectedRole.value,
  //     );

  //     if (response.status.isOk) {
  //       final prefs = await SharedPreferences.getInstance();

  //       await prefs.setString('auth_token', response.body['access_token']);
  //       final fcm = prefs.getString('fcm_token');

  //       if (fcm != null) {
  //         await _apiService.updateFcmToken(fcm);
  //       }
  //       await prefs.setString('user_role', response.body['user']['role']);
  //       final name = response.body['user']['name'];
  //       await prefs.setString('user_name', name);
  //       userName.value = name;

  //       await prefs.setString('user_email', response.body['user']['email']);

  //       final phone = response.body['user']['phone'] ?? '';
  //       await prefs.setString('user_phone', phone);

  //       final avatar = response.body['user']['avatar'] ?? '';
  //       await prefs.setString('user_avatar', avatar);
  //       profilePhotoUrl.value = avatar;

  //       final bioData = response.body['user']['bio'];
  //       String bioStr = '';
  //       if (bioData is Map) {
  //         bioStr = bioData['en'] ?? '';
  //       } else if (bioData is String) {
  //         bioStr = bioData;
  //       }
  //       await prefs.setString('user_bio', bioStr);

  //       LoadingOverlay.hide();
  //       Get.offAllNamed(Routes.HOME);
  //     } else {
  //       LoadingOverlay.hide();
  //       String errorMessage = 'Login failed';
  //       if (response.statusCode == 422 && response.body != null) {
  //         final errors = response.body['errors'];
  //         if (errors != null && errors is Map) {
  //           errorMessage = errors.values.first[0].toString();
  //         }
  //       } else if (response.body != null) {
  //         errorMessage = response.body['message'] ?? errorMessage;
  //       }
  //       Get.snackbar('Error', errorMessage);
  //     }
  //   } catch (e) {
  //     LoadingOverlay.hide();
  //     Get.snackbar('Error', 'An unexpected error occurred');
  //   } finally {
  //     isLoading.value = false;
  //     LoadingOverlay.hide();
  //   }
  // }

  ///////edit login ///////

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    isLoading.value = true;
    LoadingOverlay.show();
    try {
      final response = await _apiService.login(
        emailController.text,
        passwordController.text,
        selectedRole.value,
      );

      if (response.status.isOk) {
        final prefs = await SharedPreferences.getInstance();

        // حفظ الـ token الأساسي
        await prefs.setString('auth_token', response.body['access_token']);
        await prefs.setString(
          'user_id',
          response.body['user']['id'].toString(),
        );

        // **هنا نجيب FCM مباشرة من Firebase**
        final fcmToken = await FirebaseMessaging.instance.getToken();
        print("fcm log in ");

        print(fcmToken);
        if (fcmToken != null) {
          await prefs.setString('fcm_token', fcmToken); // تخزين محلي
          await _apiService.updateFcmToken(fcmToken); // تحديث على الباك
        }

        await prefs.setString('user_role', response.body['user']['role']);
        final name = response.body['user']['name'];
        await prefs.setString('user_name', name);
        userName.value = name;

        await prefs.setString('user_email', response.body['user']['email']);
        final phone = response.body['user']['phone'] ?? '';
        await prefs.setString('user_phone', phone);
        final avatar = response.body['user']['avatar'] ?? '';
        await prefs.setString('user_avatar', avatar);
        profilePhotoUrl.value = avatar;

        final bioData = response.body['user']['bio'];
        String bioStr = '';
        if (bioData is Map) {
          bioStr = bioData['en'] ?? '';
        } else if (bioData is String) {
          bioStr = bioData;
        }
        await prefs.setString('user_bio', bioStr);

        LoadingOverlay.hide();
        Get.offAllNamed(Routes.HOME);
      } else {
        LoadingOverlay.hide();
        String errorMessage = 'Login failed';
        if (response.statusCode == 422 && response.body != null) {
          final errors = response.body['errors'];
          if (errors != null && errors is Map) {
            errorMessage = errors.values.first[0].toString();
          }
        } else if (response.body != null) {
          errorMessage = response.body['message'] ?? errorMessage;
        }
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
      LoadingOverlay.hide();
    }
  }

  /////////end login

  //lesnr for change token from firebase
  void _initFcmRefreshListener() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString("auth_token");

    if (authToken == null) return; // المستخدم غير مسجّل دخول

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("🔥 FCM Token refreshed: $newToken");

      final old = prefs.getString("fcm_token");

      if (old != newToken) {
        await prefs.setString("fcm_token", newToken);
        await _apiService.updateFcmToken(newToken);
      }
    });
  }
  //////end lesnar

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) {
        pickedImage.value = image;
        await uploadImage();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> uploadImage() async {
    if (pickedImage.value == null) return;

    isLoading.value = true;
    LoadingOverlay.show();
    try {
      final bytes = await pickedImage.value!.readAsBytes();
      final response = await _apiService.uploadPhoto(
        bytes,
        pickedImage.value!.name,
      );

      if (response.status.isOk && response.body != null) {
        profilePhotoUrl.value = response.body['url'];
        Get.snackbar('Success', 'Profile photo uploaded!');
      } else {
        Get.snackbar('Error', 'Upload failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Upload error: $e');
    } finally {
      isLoading.value = false;
      LoadingOverlay.hide();
    }
  }

  Future<void> startRegistration() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    if (passwordController.text.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters long');
      return;
    }

    isLoading.value = true;
    LoadingOverlay.show();
    print('DEBUG: Registration attempt for: ${emailController.text}');

    try {
      final response = await _apiService.sendCode(emailController.text);

      print('DEBUG: Status Code: ${response.statusCode}');
      print('DEBUG: Response Body: ${response.body}');
      print('DEBUG: Status Text: ${response.statusText}');

      if (response.status.isOk) {
        print('DEBUG: Success! Navigating to VerificationView');
        LoadingOverlay.hide();
        Get.toNamed(Routes.VERIFICATION, arguments: {'type': 'register'});
      } else {
        LoadingOverlay.hide();
        String errorMessage = 'Failed to send code';
        if (response.body != null && response.body is Map) {
          errorMessage = response.body['message'] ?? errorMessage;
        } else if (response.statusCode == 0 || response.statusCode == null) {
          errorMessage =
              'Network Error: Cannot reach server. Check the URL and CORS.';
        }
        print('DEBUG: Error - $errorMessage');
        Get.snackbar('Error', errorMessage);
      }
    } catch (e, stack) {
      LoadingOverlay.hide();
      print('DEBUG: Exception caught: $e');
      print('DEBUG: Stack trace: $stack');
      Get.snackbar('Error', 'Unexpected technical error: $e');
    } finally {
      isLoading.value = false;
      LoadingOverlay.hide();
      print('DEBUG: Registration process finished.');
    }
  }

  // Future<void> verifyAndRegister() async {
  //   if (codeController.text.isEmpty) {
  //     Get.snackbar('Error', 'Please enter the verification code');
  //     return;
  //   }

  //   if (passwordController.text.length < 8) {
  //     Get.snackbar('Error', 'Password must be at least 8 characters long');
  //     return;
  //   }

  //   isLoading.value = true;
  //   LoadingOverlay.show();
  //   try {
  //     final verifyResponse = await _apiService.verifyCode(
  //       emailController.text,
  //       codeController.text,
  //     );

  //     if (verifyResponse.status.isOk) {
  //       final registerResponse = await _apiService.register({
  //         'name': nameController.text,
  //         'email': emailController.text,
  //         'phone': phoneController.text,
  //         'password': passwordController.text,
  //         'role': selectedRole.value,
  //         'avatar': profilePhotoUrl.value,
  //         'bio': bioController.text,
  //         'code': codeController.text,
  //       });

  //       if (registerResponse.status.isOk) {
  //         LoadingOverlay.hide();

  //         Get.offAllNamed(Routes.LOGIN);
  //         Get.snackbar('Success'.tr, 'register_successful'.tr);
  //       } else {
  //         LoadingOverlay.hide();
  //         String errorMessage = 'Registration failed';

  //         if (registerResponse.statusCode == 422 &&
  //             registerResponse.body != null) {
  //           final errors = registerResponse.body['errors'];
  //           if (errors != null && errors is Map) {
  //             errorMessage = errors.values.first[0].toString();
  //           }
  //         } else if (registerResponse.body != null) {
  //           errorMessage = registerResponse.body['message'] ?? errorMessage;
  //         }

  //         Get.snackbar(
  //           'Error',
  //           errorMessage,
  //           duration: const Duration(seconds: 5),
  //         );
  //       }
  //     } else {
  //       LoadingOverlay.hide();
  //       Get.snackbar('Error', 'Invalid verification code');
  //     }
  //   } catch (e) {
  //     LoadingOverlay.hide();
  //     Get.snackbar('Error', 'An unexpected error occurred');
  //   } finally {
  //     isLoading.value = false;
  //     LoadingOverlay.hide();
  //   }
  // }
  //edit register ..

  Future<void> verifyAndRegister() async {
    if (codeController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter the verification code');
      return;
    }

    if (passwordController.text.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters long');
      return;
    }

    isLoading.value = true;
    LoadingOverlay.show();
    try {
      final verifyResponse = await _apiService.verifyCode(
        emailController.text,
        codeController.text,
      );

      if (verifyResponse.status.isOk) {
        final registerResponse = await _apiService.register({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'password': passwordController.text,
          'role': selectedRole.value,
          'avatar': profilePhotoUrl.value,
          'bio': bioController.text,
          'code': codeController.text,
        });

        if (registerResponse.status.isOk) {
          // ✅ تسجيل ناجح، الآن نجيب FCM token ونحدثه على الباكند
          final prefs = await SharedPreferences.getInstance();
          final fcmToken = await FirebaseMessaging.instance.getToken();
          print("fcm register  in ");

          print(fcmToken);
          if (fcmToken != null) {
            await prefs.setString('fcm_token', fcmToken);
            await _apiService.updateFcmToken(fcmToken);
          }

          LoadingOverlay.hide();
          Get.offAllNamed(Routes.LOGIN);
          Get.snackbar('Success'.tr, 'register_successful'.tr);
        } else {
          LoadingOverlay.hide();
          String errorMessage = 'Registration failed';

          if (registerResponse.statusCode == 422 &&
              registerResponse.body != null) {
            final errors = registerResponse.body['errors'];
            if (errors != null && errors is Map) {
              errorMessage = errors.values.first[0].toString();
            }
          } else if (registerResponse.body != null) {
            errorMessage = registerResponse.body['message'] ?? errorMessage;
          }

          Get.snackbar(
            'Error',
            errorMessage,
            duration: const Duration(seconds: 5),
          );
        }
      } else {
        LoadingOverlay.hide();
        Get.snackbar('Error', 'Invalid verification code');
      }
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
      LoadingOverlay.hide();
    }
  }

  //end register ..
  Future<void> startForgotPassword() async {
    if (emailController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your email');
      return;
    }

    isLoading.value = true;
    LoadingOverlay.show();
    try {
      final response = await _apiService.forgotPassword(emailController.text);
      if (response.status.isOk) {
        LoadingOverlay.hide();
        Get.toNamed(Routes.VERIFICATION, arguments: {'type': 'reset'});
      } else {
        LoadingOverlay.hide();
        Get.snackbar(
          'Error',
          response.body['message'] ?? 'Failed to send reset code',
        );
      }
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
      LoadingOverlay.hide();
    }
  }

  Future<void> verifyResetCode() async {
    if (codeController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter the code');
      return;
    }

    isLoading.value = true;
    LoadingOverlay.show();
    try {
      final response = await _apiService.verifyCode(
        emailController.text,
        codeController.text,
      );
      if (response.status.isOk) {
        LoadingOverlay.hide();
        Get.toNamed(Routes.RESET_PASSWORD);
      } else {
        LoadingOverlay.hide();
        Get.snackbar('Error', 'Invalid code');
      }
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
      LoadingOverlay.hide();
    }
  }

  Future<void> resetPassword() async {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    isLoading.value = true;
    LoadingOverlay.show();
    try {
      final response = await _apiService.resetPassword(
        emailController.text,
        passwordController.text,
      );
      if (response.status.isOk) {
        LoadingOverlay.hide();
        Get.offAllNamed(Routes.LOGIN);
        Get.snackbar('Success', 'Password updated successfully');
      } else {
        LoadingOverlay.hide();
        Get.snackbar(
          'Error',
          response.body['message'] ?? 'Failed to reset password',
        );
      }
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
      LoadingOverlay.hide();
    }
  }

  Future<void> logout() async {
    LoadingOverlay.show();
    try {
      await _apiService.logout();
    } catch (e) {
      print('Logout Error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      LoadingOverlay.hide();
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
