import 'package:flutter/material.dart';

enum SnackType { success, error, warning, info }

void showCustomSnackBar(
  BuildContext context, {
  required String message,
  required SnackType type,
}) {
  Color bgColor;
  IconData icon;

  switch (type) {
    case SnackType.success:
      bgColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case SnackType.error:
      bgColor = Colors.red;
      icon = Icons.error;
      break;
    case SnackType.warning:
      bgColor = Colors.orange;
      icon = Icons.warning;
      break;
    case SnackType.info:
      bgColor = Colors.blue;
      icon = Icons.info;
      break;
  }

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
