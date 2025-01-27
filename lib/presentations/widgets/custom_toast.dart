import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';

void showToast({
  required BuildContext context,
  required Icon icon,
  required String title,
  required String message,
  required Color color,
}) {
  DelightToastBar(
    autoDismiss: true,
    builder: (context) => ToastCard(
      leading: Icon(icon.icon, color: Colors.white),
      title: Text(
        title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white
        )
      ),
      subtitle: Text(
        message, style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white
        )
      ),
      color: color,
    ),
  ).show(context);
}