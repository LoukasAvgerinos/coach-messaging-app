import 'package:flutter/material.dart';
import 'package:andreopoulos_messasing/shared/widgets/buttons/primary_button.dart';
import 'package:andreopoulos_messasing/shared/widgets/inputs/app_text_field.dart';
import 'package:andreopoulos_messasing/features/auth/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  // tap function for navigation to Register Page
  final Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // login method
  void login() async {
    // auth service login call
    final authService = AuthService();

    // try to sign in
    try {
      await authService.signIn(_emailController.text, _passwordController.text);
      // Navigate to the main app page or show success message
    } catch (e) {
      // Show error message
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Login Failed'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 50),

                //Logo
                Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/andreo_logo.jpg',
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // welcome message
                const SizedBox(height: 50),
                Text(
                  'Welcome to\nChat for Athletes!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                // email textfield
                const SizedBox(height: 30),

                //email textfield
                MyTextField(hintText: "Email", controller: _emailController),
                //password textfield
                const SizedBox(height: 10),
                MyTextField(
                  hintText: "Password",
                  isPassword: true,
                  controller: _passwordController,
                ),

                //login button
                const SizedBox(height: 20),
                MyButton(text: "Login", onTap: login),

                //register Athlete
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Call the onTap callback if provided
                        if (widget.onTap != null) {
                          widget.onTap!();
                        }
                      },
                      child: Text(
                        'Register Here',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
