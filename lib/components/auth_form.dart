import 'package:flutter/material.dart';
import 'package:quitter/components/login_form.dart';
import 'package:quitter/components/signup_form.dart';

class AuthForm extends StatelessWidget {
  final bool isLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController usernameController;
  final VoidCallback onSubmit;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.usernameController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return isLogin
        ? LoginForm(
            emailController: emailController,
            passwordController: passwordController,
            onSubmit: onSubmit,
          )
        : SignupForm(
            emailController: emailController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            usernameController: usernameController,
            onSubmit: onSubmit,
          );
  }
}
