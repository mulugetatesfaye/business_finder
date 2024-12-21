import 'package:business_finder/app_bottnavigation.dart';
import 'package:business_finder/src/pages/authentication/signup_page.dart';
import 'package:business_finder/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // To toggle visibility

  void _login() async {
    // Validate the form fields before attempting login
    if (_formKey.currentState?.validate() != true) return;

    // Start loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the auth service from the provider
      final authService = ref.read(authServiceProvider);

      // Attempt to log in the user
      final user = await authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Navigate to the home page or dashboard upon successful login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const BottomNavBarScreen(),
          ),
          (route) => false,
        );
      } else {
        // Display error message if login fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    } catch (e) {
      // Handle exceptions and display error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      // Stop loading indicator
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background to light
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),

            // App logo
            const Center(
              child: Text(
                "Yet",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tagline
            const Center(
              child: Text(
                "Ethiopia's largest Business finder!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54, // Adjust text color for light mode
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Login Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.black),
                      prefixIcon:
                          const Icon(Icons.person, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, // Show/hide password
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.black),
                      prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible =
                                !_isPasswordVisible; // Toggle password visibility
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login button with loading indicator
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(double.maxFinite, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                  const SizedBox(height: 16),

                  // Already have an account TextButton
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ));
                    },
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
