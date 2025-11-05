import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:andreopoulos_messasing/services/auth/login_or_register.dart';
import 'package:andreopoulos_messasing/pages/home_page.dart'; // Update path if needed

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if user is logged in
          if (snapshot.hasData) {
            // User is logged in
            return const HomePage();
          } else {
            // User is not logged in
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
