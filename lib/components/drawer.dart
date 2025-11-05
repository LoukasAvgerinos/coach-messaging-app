import 'package:andreopoulos_messasing/pages/home_page.dart';
import 'package:flutter/material.dart';
//import 'package:andreopoulos_messasing/pages/login_page.dart';
import 'package:andreopoulos_messasing/services/auth/auth_service.dart';
import '/pages/settings_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void logout() {
    //get auth service
    final _auth = AuthService();
    _auth.signOut();
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

              onTap: () async {
                Navigator.pop(context); // Close drawer first
                await AuthService().signOut(); // Sign out user
              },
            ),
          ),
        ],
      ),
    );
  }
}
