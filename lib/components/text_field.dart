import 'package:flutter/material.dart';

// Changed from StatelessWidget to StatefulWidget to manage password visibility state
class MyTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword; // Flag to determine if this is a password field
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    required this.controller,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  // State variable to track whether password should be obscured
  // Starts as true (hidden) for password fields
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        // If it's a password field, use the _obscureText state variable
        // Otherwise, always show the text (for email fields, etc.)
        obscureText: widget.isPassword ? _obscureText : false,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          // Only show the visibility toggle icon if this is a password field
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    // Show eye icon based on current state:
                    // - visibility_off when password is hidden (obscured)
                    // - visibility when password is visible (not obscured)
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    // Toggle the password visibility state when icon is pressed
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null, // No icon for non-password fields
        ),
      ),
    );
  }
}
