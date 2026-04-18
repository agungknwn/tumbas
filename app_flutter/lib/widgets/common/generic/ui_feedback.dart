import 'package:flutter/material.dart';

enum FeedbackType { error, success, info }

class UiFeedback {
  static void show(
    BuildContext context, {
    required String message,
    FeedbackType type = FeedbackType.info,
  }) {
    Color backgroundColor;

    switch (type) {
      case FeedbackType.error:
        backgroundColor = Colors.red;
        break;
      case FeedbackType.success:
        backgroundColor = Colors.green;
        break;
      case FeedbackType.info:
        backgroundColor = Colors.blue;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
