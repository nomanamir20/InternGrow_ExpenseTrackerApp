import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    ever(controller.errorMessage, (String? message) {
      if (message != null) {
        Get.snackbar('Sign Up Failed', message, snackPosition: SnackPosition.BOTTOM);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to start tracking your finances',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: subTextColor),
                ),
                const SizedBox(height: 32),

                AppTextField(
                  controller: fullNameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: Validators.fullName,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]")),
                  ],
                ),
                const SizedBox(height: 20),

                AppTextField(
                  controller: emailController,
                  label: 'Email',
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline),
                  validator: Validators.email,
                ),
                const SizedBox(height: 20),

                AppTextField(
                  controller: passwordController,
                  label: 'Password',
                  hintText: 'Create a strong password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: Validators.password,
                ),
                const SizedBox(height: 20),

                AppTextField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) => Validators.confirmPassword(value, passwordController.text),
                ),
                const SizedBox(height: 28),

                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) return;
                                controller.signUp(
                                  fullName: fullNameController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                );
                              },
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Sign Up'),
                      ),
                    )),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: TextStyle(color: subTextColor)),
                    GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.login),
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}