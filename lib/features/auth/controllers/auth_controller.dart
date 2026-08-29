import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  User? get currentUser => _authService.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authService.signInWithEmail(email: email, password: password);
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _authService.friendlyErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authService.signUpWithEmail(email: email, password: password);
      await _authService.updateDisplayName(fullName);
      // Sign back out so the user logs in fresh with their new credentials,
      // rather than being auto-signed-in by account creation (same fix
      // applied throughout Tasks 1-3).
      await _authService.signOut();

      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        'Account Created',
        'Please log in to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _authService.friendlyErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}