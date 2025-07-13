import 'package:flutter/material.dart';
import 'package:quitter/assets/colors.dart';
import 'package:quitter/components/auth_form.dart';
import 'package:quitter/services/auth_service.dart';
import 'package:quitter/pages/root_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true; // toggle between Login and Signup
  bool _isLoading = false; // show spinner during API calls

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  /// Handle login or signup
Future<void> _handleAuth() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();
  final username = _usernameController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email and password cannot be empty")),
    );
    return;
  }

  if (!_isLogin) {
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username is required.")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }
  }

  setState(() => _isLoading = true);

  try {
    bool success;
    if (_isLogin) {
      success = await loginUser(email, password);
    } else {
      await signUpUser(email, password, username);
      success = true; // Signup auto logs in
    }

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RootPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid login credentials")),
      );
    }
  } catch (e) {
    print('Auth error: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Auth error: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  /// Toggle between Login and Signup form
  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _usernameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthForm(
                  isLogin: _isLogin,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  usernameController: _usernameController,
                  onSubmit: _handleAuth,
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : TextButton(
                        onPressed: _toggleForm,
                        child: Text(
                          _isLogin
                              ? "Don't have an account? Sign up"
                              : "Already have an account? Log in",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
