import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

// import 'package:google_sign_in/google_sign_in.dart'; // Commented for testing

import '../../../core/routing/app_router.dart';
import '../../../core/services/api_service.dart';
import '../services/auth_service.dart';

/// Controller for managing authentication state and logic
class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // Commented for testing

  // Form controllers with default values for development
  final TextEditingController emailController = TextEditingController(
    text: 'mshakilawan735@gmail.com',
  );
  final TextEditingController passwordController = TextEditingController(
    text: 'Password@1',
  );
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form keys
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  // Observable state
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final acceptedTerms = false.obs;
  final passwordVisible = false.obs;
  final confirmPasswordVisible = false.obs;
  final errorMessage = ''.obs;
  final passwordStrength = 0.0.obs; // 0.0 to 1.0

  /// Toggle password visibility
  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    confirmPasswordVisible.value = !confirmPasswordVisible.value;
  }

  /// Toggle remember me checkbox
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  /// Toggle accepted terms checkbox
  void toggleAcceptedTerms(bool? value) {
    acceptedTerms.value = value ?? false;
  }

  /// Calculate password strength (0.0 to 1.0)
  void calculatePasswordStrength(String password) {
    double strength = 0.0;

    if (password.isEmpty) {
      passwordStrength.value = 0.0;
      return;
    }

    // Length check (0.25)
    if (password.length >= 8) strength += 0.25;

    // Uppercase check (0.25)
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;

    // Number check (0.25)
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;

    // Special character check (0.25)
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    passwordStrength.value = strength;
  }

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate password format
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate confirm password matches password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  /// Sign in with email and password
  Future<void> signIn(BuildContext context) async {
    if (!signInFormKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Login and store tokens (handled by auth service)
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // TokenResponse contains: accessToken, refreshToken, tokenType, user
      // Tokens are already stored in secure storage by auth service

      // Navigate to content generation page (or home/dashboard)
      if (context.mounted) context.go(AppRouter.generate);
    } on ApiException catch (e) {
      // Use user-friendly error message from enhanced ApiException
      errorMessage.value = e.userFriendlyMessage;
    } catch (e) {
      // Handle any other errors
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign up with email, password, and name
  Future<void> signUp(BuildContext context) async {
    if (!signUpFormKey.currentState!.validate()) return;

    if (!acceptedTerms.value) {
      errorMessage.value = 'Please accept the terms and conditions';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Register new user (returns UserResponse without tokens)
      await _authService.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: nameController.text.trim(),
      );

      // After registration, automatically login to get JWT tokens
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // TokenResponse contains: accessToken, refreshToken, tokenType, user
      // Tokens are already stored in secure storage by auth service

      // Navigate to content generation page (same as login)
      if (context.mounted) context.go(AppRouter.generate);
    } on ApiException catch (e) {
      // Use user-friendly error message from enhanced ApiException
      errorMessage.value = e.userFriendlyMessage;
    } catch (e) {
      // Handle any other errors
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // TODO: Implement Google Sign In flow
      // 1. Trigger Google Sign In to get ID token
      // 2. Pass ID token to backend via _authService.googleSignIn()
      // 3. Backend validates token and returns JWT tokens

      // Placeholder: For now, show error that Google Sign-In is not configured
      throw Exception(
        'Google Sign-In not configured yet. Please use email/password login.',
      );

      // Example implementation (uncomment when google_sign_in is added):
      /*
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // Send Firebase ID token to backend
      await _authService.googleSignIn(idToken);

      // Navigate to content generation page
      if (context.mounted) context.go(AppRouter.generate);
      */
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = errorMsg;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear form fields
  void clearFields() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
    rememberMe.value = false;
    acceptedTerms.value = false;
    passwordVisible.value = false;
    confirmPasswordVisible.value = false;
    errorMessage.value = '';
    passwordStrength.value = 0.0;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
