import 'package:flutter/material.dart';
import 'package:quitter/assets/colors.dart';

class AuthForm extends StatelessWidget {
  final bool isLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Email",
            hintStyle: const TextStyle(color: Colors.white70),
            suffixIcon: IconButton(
              onPressed: () => emailController.clear(),
              icon: const Icon(Icons.clear, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Password",
            hintStyle: const TextStyle(color: Colors.white70),
            suffixIcon: IconButton(
              onPressed: () => passwordController.clear(),
              icon: const Icon(Icons.clear, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.main_color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // More rounded
            ),
            elevation: 8,
            shadowColor: AppColors.main_color.withOpacity(0.5),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(isLogin ? "Login" : "Sign Up"),
        ),
      ],
    );
  }
}
