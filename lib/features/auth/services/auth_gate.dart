import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:andreopoulos_messasing/features/auth/services/login_or_register.dart';
import 'package:andreopoulos_messasing/features/profile/presentation/pages/profile_check_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Debug: Print the current auth state
          print('🔐 AuthGate - Connection state: ${snapshot.connectionState}');
          print('🔐 AuthGate - Has data: ${snapshot.hasData}');
          print('🔐 AuthGate - User: ${snapshot.data?.email ?? "No user"}');

          // Show loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if user is logged in
          if (snapshot.hasData) {
            // User is logged in - check if profile exists
            print('✅ AuthGate - User is logged in, checking profile...');
            return const ProfileCheckPage();
          } else {
            // User is not logged in
            print('❌ AuthGate - No user, showing LoginOrRegister');
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
