import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'themes/theme_provider.dart';
import 'services/auth/auth_gate.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

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
      debugShowCheckedModeBanner:
          true, //at the final stage i'll do it false - DEBUG Sticker
      home: AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
