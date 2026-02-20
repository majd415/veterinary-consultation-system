import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/api_service.dart';
import '../../data/utils/loading_overlay.dart';
import '../auth/auth_controller.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  var isVet = false.obs;
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var bio = ''.obs;
  var avatar = ''.obs;
  var role = ''.obs;

  var isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString('user_name') ?? 'User';
    email.value = prefs.getString('user_email') ?? '';
    phone.value = prefs.getString('user_phone') ?? '';
    bio.value = prefs.getString('user_bio') ?? '';
    avatar.value = prefs.getString('user_avatar') ?? '';
    role.value = prefs.getString('user_role') ?? 'user';
    isVet.value = role.value == 'vet';

    _resetControllers();
  }

  void _resetControllers() {
    nameController.text = name.value;
    emailController.text = email.value;
    phoneController.text = phone.value;
    bioController.text = bio.value;
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) {
        await _uploadImage(image);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> _uploadImage(XFile image) async {
    isLoading.value = true;
    LoadingOverlay.show();
    try {
      final bytes = await image.readAsBytes();
      final response = await _apiService.uploadPhoto(bytes, image.name);

      if (response.status.isOk && response.body != null) {
        final newUrl = response.body['url'];
        avatar.value = newUrl;

        // Auto-save to profile without nested loader
        await saveProfile(showLoader: false);
        Get.snackbar('Success', 'Profile photo updated!');
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

  Future<void> saveProfile({bool showLoader = true}) async {
    if (showLoader) {
      isLoading.value = true;
      LoadingOverlay.show();
    }
    try {
      final response = await _apiService.updateProfile({
        'name': nameController.text,
        'phone': phoneController.text,
        'bio': bioController.text,
        'avatar': avatar.value,
      });

      if (response.status.isOk) {
        final prefs = await SharedPreferences.getInstance();
        final userData = response.body['user'];

        await prefs.setString('user_name', userData['name']);
        await prefs.setString('user_phone', userData['phone'] ?? '');
        await prefs.setString('user_avatar', userData['avatar'] ?? '');

        final bioData = userData['bio'];
        String bioStr = '';
        if (bioData is Map)
          bioStr = bioData['en'] ?? '';
        else if (bioData is String)
          bioStr = bioData;
        await prefs.setString('user_bio', bioStr);

        // Sync local observables
        name.value = userData['name'];
        phone.value = userData['phone'] ?? '';
        avatar.value = userData['avatar'] ?? '';
        bio.value = bioStr;

        // Sync with AuthController for Sidebar
        Get.find<AuthController>().loadSessionData();

        if (showLoader) {
          Get.snackbar('Success', 'Profile updated successfully');
        }
      } else {
        Get.snackbar('Error', 'Failed to update profile');
      }
    } catch (e) {
      Get.snackbar('Error', 'Update error: $e');
    } finally {
      if (showLoader) {
        isLoading.value = false;
        LoadingOverlay.hide();
      }
    }
  }

  void logout() {
    Get.find<AuthController>().logout();
  }
}
