import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage; // To hold potential error messages

  void _login() {
    setState(() {
      _errorMessage = null; // Clear previous errors
    });

    // Progress 2: Mock logic to link to the correct dashboard
    String username = _usernameController.text;
    String password = _passwordController.text; // You might use this later
    String route;

    // Simulate login check based on username for demo purposes
    if (username.toLowerCase() == 'student') {
      route = '/student';
    } else if (username.toLowerCase() == 'lecturer') {
      route = '/lecturer';
    } else if (username.toLowerCase() == 'staff') {
      route = '/staff';
    } else {
      // Show error if username doesn't match known roles
      setState(() {
        _errorMessage = 'Invalid username or password. Try "student", "lecturer", or "staff".';
      });
      return; // Stop the login process
    }

    // Navigate to the correct home screen and remove login from back stack
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Ensures content avoids notches and system bars
        child: Center(
          child: SingleChildScrollView( // Allows scrolling if content overflows
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
              children: [
                // --- App Title ---
                Text(
                  'Asset Borrowing System',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Color.fromARGB(133, 0, 150, 135), // Use color from theme
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),

                // --- Subtitle ---
                Text(
                  'Sign in your account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Color.fromARGB(133, 0, 150, 135), // Use hint color from theme
                      ),
                ),
                const SizedBox(height: 32),

                // --- Username Field ---
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    // Uses styles from inputDecorationTheme in app_theme.dart
                    labelText: 'Username',
                    // prefixIcon: Icon(Icons.person), // Optional icon
                  ),
                  style: const TextStyle(color: Color.fromARGB(133, 0, 150, 135)), // Text color while typing
                ),
                const SizedBox(height: 16),

                // --- Password Field ---
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Hides password characters
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    // prefixIcon: Icon(Icons.lock), // Optional icon
                  ),
                  style: const TextStyle(color: Color.fromARGB(133, 0, 150, 135)),
                ),
                const SizedBox(height: 16),

                // --- Error Message Display ---
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color.fromARGB(133, 0, 150, 135), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // --- Login Button ---
                ElevatedButton(
                  onPressed: _login,
                  // Style comes from elevatedButtonTheme in app_theme.dart
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 16), // Spacing between buttons

                // --- Register Button ---
                TextButton(
                  onPressed: () {
                    // Navigate to the register screen
                    Navigator.pushNamed(context, '/register');
                  },
                  // Style comes from textButtonTheme in app_theme.dart
                  child: const Text("Don't have account? Register here"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}