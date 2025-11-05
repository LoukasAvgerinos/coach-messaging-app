import 'package:flutter/material.dart';

// Light Mode Theme
ThemeData lightModeTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.black,
    secondary: Colors.grey.shade200,
    onSecondary: Colors.white10,
    tertiary: Colors.grey.shade500,
    inversePrimary: Colors.grey.shade600,
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
    surface: Colors.grey.shade900,
    primary: Colors.white,
    secondary: Colors.grey.shade800,
    onSecondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade400,
    inversePrimary: Colors.grey.shade300,
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
