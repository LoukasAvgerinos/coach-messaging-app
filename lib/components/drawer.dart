import 'package:andreopoulos_messasing/pages/home_page.dart';
import 'package:flutter/material.dart';
//import 'package:andreopoulos_messasing/pages/login_page.dart';
import 'package:andreopoulos_messasing/services/auth/auth_service.dart';
import '/pages/settings_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  // Logout method with confirmation dialog and proper navigation
  // This method shows a confirmation dialog before logging out the user
  Future<void> logout(BuildContext context) async {
    // CRITICAL: Store the navigator BEFORE any async operations
    // This prevents BuildContext errors after await
    final navigator = Navigator.of(context, rootNavigator: true);

    // Show confirmation dialog to prevent accidental logouts
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            // Cancel button - returns false
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            // Logout button - returns true
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // If user didn't confirm, exit early
    if (confirmLogout != true) {
      print('❌ User cancelled logout');
      return;
    }

    // Show loading dialog using the stored navigator
    navigator.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const Scaffold(
          backgroundColor: Colors.black54,
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      // Sign out from Firebase
      print('🔓 Starting logout process...');
      await AuthService().signOut();
      print('✅ Firebase signOut() completed');

      // Close loading screen
      navigator.pop();
      print('✅ Closed loading screen');

      // Pop all routes to get back to AuthGate (the root route)
      // AuthGate will detect the auth state change and show login page
      navigator.popUntil((route) => route.isFirst);
      print('✅ Popped to root - AuthGate should now show login page');
    } catch (e) {
      print('❌ Logout error: $e');

      // Close loading screen
      navigator.pop();

      // Show error dialog
      await showDialog(
        context: context,
        builder: (errorContext) {
          return AlertDialog(
            title: const Text('Logout Failed'),
            content: Text('Error: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(errorContext).pop(),
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
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          DrawerHeader(
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/andreo_logo.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Home list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.home,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'H O M E',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onTap: () {
                // Close drawer
                Navigator.pop(context);
                // Navigate to home page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ),

          // Settings list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'S E T T I N G S',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onTap: () {
                // Close drawer first
                Navigator.pop(context);
                // Then navigate to settings
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),

          const Spacer(),

          // Logout list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 55.0),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'L O G O U T',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),

              onTap: () {
                // Close drawer first
                Navigator.pop(context);
                // Call logout method which handles confirmation and sign out
                logout(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
