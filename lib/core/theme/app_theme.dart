import 'package:flutter/material.dart';

// ============================================
// APP COLOR PALETTE
// ============================================
class AppColors {
  // Primary brand colors
  static const Color navyDark = Color(0xFF010F31);      // #010F31 - Navbar, Drawer
  static const Color navyMedium = Color(0xFF0D2994);    // #0D2994 - Primary actions
  static const Color purpleAccent = Color(0xFF5E5FE8);  // #5E5FE8 - Send button, accents

  // Base colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Greys for backgrounds and text
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
}

// Light Mode Theme
ThemeData lightModeTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    // Main colors
    primary: AppColors.navyMedium,           // Primary buttons, app bar
    secondary: AppColors.lightGrey,          // Message bubbles, cards
    tertiary: AppColors.purpleAccent,        // Send button, FABs, accents

    // Surface colors
    surface: AppColors.white,                // Background
    onSurface: AppColors.black,              // Text on surface

    // Primary color text
    onPrimary: AppColors.white,              // Text on primary color
    onSecondary: AppColors.black,            // Text on secondary color
    onTertiary: AppColors.white,             // Text on tertiary color

    // Additional colors
    inversePrimary: AppColors.mediumGrey,    // Subtle text, hints
  ),

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.navyDark,     // #010F31 for navbar
    foregroundColor: AppColors.white,
    elevation: 0,
    centerTitle: true,
  ),

  // Drawer theme
  drawerTheme: const DrawerThemeData(
    backgroundColor: AppColors.navyMedium,   // #0D2994 for drawer
  ),

  // Smooth page transitions for all screens
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);

// Dark Mode Theme
ThemeData darkModeTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    // Main colors
    primary: AppColors.navyMedium,           // Primary buttons, app bar
    secondary: AppColors.darkGrey,           // Message bubbles, cards
    tertiary: AppColors.purpleAccent,        // Send button, FABs, accents

    // Surface colors
    surface: AppColors.navyDark,             // Background (dark navy)
    onSurface: AppColors.white,              // Text on surface

    // Primary color text
    onPrimary: AppColors.white,              // Text on primary color
    onSecondary: AppColors.white,            // Text on secondary color
    onTertiary: AppColors.white,             // Text on tertiary color

    // Additional colors
    inversePrimary: AppColors.mediumGrey,    // Subtle text, hints
  ),

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.navyDark,     // #010F31 for navbar
    foregroundColor: AppColors.white,
    elevation: 0,
    centerTitle: true,
  ),

  // Drawer theme
  drawerTheme: const DrawerThemeData(
    backgroundColor: AppColors.navyMedium,   // #0D2994 for drawer
  ),

  // Smooth page transitions for all screens
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);

// ============================================
// ALTERNATIVE TRANSITION OPTIONS
// ============================================
// To use a different transition style, replace the pageTransitionsTheme above with one of these:

// Option 1: Fade transitions (gentle, Material Design style)
/*
pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
  },
),
*/

// Option 2: Zoom transitions (Material 3 style, modern)
/*
pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
  },
),
*/

// Option 3: Default Material transitions (standard Android)
/*
pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
),
*/
