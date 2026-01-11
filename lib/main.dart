import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'themes/theme_provider.dart';
import 'services/auth/auth_gate.dart';
import 'services/notification_service.dart';
import 'services/message_listener_service.dart';

// Global navigator key - allows navigation from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize Message Listener Service
  final messageListener = MessageListenerService();

  // Start listening when user logs in
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      print('🔓 User logged in, starting message listener');
      messageListener.startListening();
    } else {
      print('🔒 User logged out, stopping message listener');
      messageListener.stopListening();
    }
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Add the global navigator key
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner:
          true, //at the final stage i'll do it false - DEBUG Sticker
      home: const AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
