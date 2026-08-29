import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // GetX pattern: ever() listens for state changes and reacts with a
    // side-effect (showing an error) — the equivalent of Bloc's
    // BlocListener or Riverpod's ref.listen.
    ever(controller.errorMessage, (String? message) {
      if (message != null) {
        Get.snackbar('Login Failed', message, snackPosition: SnackPosition.BOTTOM);
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
                const SizedBox(height: 40),
                const Icon(Icons.account_balance_wallet, size: 56, color: AppColors.primary),
                const SizedBox(height: 20),
                Text(
                  'Welcome to InternGrow Finance',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to manage your money',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: subTextColor),
                ),
                const SizedBox(height: 32),

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
                  hintText: 'Enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) => Validators.notEmpty(value, fieldName: 'Password'),
                ),
                const SizedBox(height: 28),

                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) return;
                                controller.signIn(
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
                            : const Text('Log In'),
                      ),
                    )),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: subTextColor)),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.signUp),
                      child: const Text(
                        'Sign Up',
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