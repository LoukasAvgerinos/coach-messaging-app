import 'package:andreopoulos_messasing/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:andreopoulos_messasing/components/my_button.dart';
import 'package:andreopoulos_messasing/components/text_field.dart';
import 'package:andreopoulos_messasing/guidelines/pass_guide.dart';

class RegisterPage extends StatefulWidget {
  // Navigation callback
  final Function()? onTap;

  // Constructor
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Register Method
  void register() async {
    // get Auth Serveice instance
    final _auth = AuthService();

    //passwords match check
    if (_passwordController.text != _confirmPasswordController.text) {
      // show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Failed - passwords do not match'),
            content: const Text('The passwords you entered do not match.'),
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
      return; // exit the method if passwords do not match
    }

    try {
      await _auth.signUpWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      // show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Failed'),
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
                  'Create Your Athlete Account!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

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

                //confirm password textfield
                const SizedBox(height: 10),
                MyTextField(
                  hintText: "Confirm Password",
                  isPassword: true,
                  controller: _confirmPasswordController,
                ),

                //register button
                const SizedBox(height: 20),
                MyButton(
                  text: 'Register', // ✅ Σωστή χρήση του text parameter
                  onTap: register,
                ),

                // rules for passwords
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    // Άνοιγμα της guidelines page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasswordGuidelinesPage(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'How To Generate Strong Password',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),

                //login link
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Login Now',
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
