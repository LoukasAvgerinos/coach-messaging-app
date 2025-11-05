import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../pages/login_page.dart';
import '../../pages/register.dart';
import '../../themes/theme_provider.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Smooth animated transition between Login and Register
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Combine fade and slide for smooth effect
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOutCubic,
                        ),
                      ),
                  child: child,
                ),
              );
            },
            child: showLoginPage
                ? LoginPage(key: const ValueKey('login'), onTap: togglePages)
                : RegisterPage(
                    key: const ValueKey('register'),
                    onTap: togglePages,
                  ),
          ),

          // Floating theme toggle button in top right
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Provider.of<ThemeProvider>(context).isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
