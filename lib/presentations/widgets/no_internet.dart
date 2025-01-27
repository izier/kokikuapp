import 'package:flutter/material.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/constants/variables/theme.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const NoInternetWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationService.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(Icons.signal_wifi_off, size: 48, color: AppTheme.primaryColor),
        SizedBox(height: 8),
        Text(
          localizations.translate('noInternet'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: onRefresh,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh),
                const SizedBox(width: 8),
                Text(localizations.translate('refresh')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
