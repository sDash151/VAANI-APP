import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A collection of reusable helper functions used across the app.
class Helpers {
  Helpers._(); // Private constructor to prevent instantiation

  /// Displays a [SnackBar] with the given [message] at the bottom of the screen.
  /// 
  /// Example:
  /// ```dart
  /// Helpers.showSnackBar(context, 'Login failed. Try again.');
  /// ```
  static void showSnackBar(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.hideCurrentSnackBar(); // Dismiss any existing SnackBar
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Validates if the given [email] string is in a correct email format.
  /// Returns `true` if valid, `false` otherwise.
  /// 
  /// Example:
  /// ```dart
  /// bool valid = Helpers.isValidEmail('user@example.com');
  /// ```
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validates if the given [password] meets minimum length requirements.
  /// Currently, it checks if length is at least 6 characters.
  /// 
  /// Example:
  /// ```dart
  /// bool valid = Helpers.isValidPassword('mypassword');
  /// ```
  static bool isValidPassword(String password, {int minLength = 6}) {
    return password.trim().length >= minLength;
  }

  /// Capitalizes the first letter of the given [input] string.
  /// If [input] is empty, returns an empty string.
  /// 
  /// Example:
  /// ```dart
  /// String name = Helpers.capitalize('john'); // "John"
  /// ```
  static String capitalize(String input) {
    if (input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Formats a [DateTime] object into a readable string (e.g., "Apr 05, 2025 14:30").
  /// Uses the device’s locale.
  /// 
  /// Example:
  /// ```dart
  /// String formatted = Helpers.formatDateTime(DateTime.now());
  /// ```
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy – hh:mm a');
    return formatter.format(date);
  }

  /// Formats a [DateTime] object into a date-only string (e.g., "Apr 05, 2025").
  /// 
  /// Example:
  /// ```dart
  /// String dateOnly = Helpers.formatDate(dateTime);
  /// ```
  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  /// Returns a human-readable error message based on typical Firebase Auth errors.
  /// 
  /// Example:
  /// ```dart
  /// String errorMsg = Helpers.getAuthErrorMessage('invalid-email');
  /// ```
  static String getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return 'An unexpected error occurred. Please try again later.';
    }
  }

  /// Parses a generic exception [e] (e.g., FirebaseAuthException) and returns
  /// a user-friendly message. If it recognizes a FirebaseAuthException code, it uses [getAuthErrorMessage].
  /// Otherwise, it returns [e.toString()].
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   // Firebase sign-in logic
  /// } catch (e) {
  ///   String msg = Helpers.parseErrorMessage(e);
  ///   Helpers.showSnackBar(context, msg);
  /// }
  /// ```
  static String parseErrorMessage(Object e) {
    final message = e.toString();
    if (message.contains('[') && message.contains(']')) {
      // Example format: "[firebase_auth/wrong-password] The password is invalid."
      final code = message
          .substring(message.indexOf('/') + 1, message.indexOf(']'))
          .trim();
      return getAuthErrorMessage(code);
    }
    return message;
  }
}
