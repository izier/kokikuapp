import 'package:flutter/material.dart';
import 'package:kokiku/constants/services/localization_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationService.of(context)!;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              localizations.translate('appTitle'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            ),
          ],
        )
      ),
      body: Center(),
    );
  }
}
