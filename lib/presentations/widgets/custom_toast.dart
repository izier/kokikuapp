import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:kokiku/constants/variables/theme.dart';

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
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white
          )
      ),
      subtitle: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white
          )
      ),
      color: color,
    ),
  ).show(context);
}

void showSuccessToast({
  required BuildContext context,
  required String title,
  required String message,
}) {
  DelightToastBar(
    autoDismiss: true,
    builder: (context) => ToastCard(
      leading: Icon(Icons.check, color: Colors.white),
      title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white
          )
      ),
      subtitle: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white
          )
      ),
      color: Colors.green,
    ),
  ).show(context);
}

void showErrorToast({
  required BuildContext context,
  required String title,
  required String message,
}) {
  DelightToastBar(
    autoDismiss: true,
    builder: (context) => ToastCard(
      leading: Icon(Icons.cancel, color: Colors.white),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          color: Colors.white
        )
      ),
      subtitle: Text(
        message,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: Colors.white
        )
      ),
      color: Colors.red,
    ),
  ).show(context);
}