// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:country_flags/country_flags.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/main.dart';
import 'package:kokiku/presentations/widgets/custom_toast.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signOut(BuildContext context) async {
    final LocalizationService localizations = LocalizationService.of(context)!;
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      showSuccessToast(
        context: context,
        title: localizations.translate('loggedOut'),
        message: localizations.translate('loggedOutSub'),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/landing',
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      log("Error: $e");
      showErrorToast(
        context: context,
        title: localizations.translate('loggedOutFail'),
        message: e.toString(),
      );
    }
  }

  void _changeLanguage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CountryFlag.fromLanguageCode('en', shape: const Circle()),
                title: Text('English'),
                onTap: () {
                  setState(() {
                    MyApp.updateLocale(context, const Locale('en'));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CountryFlag.fromLanguageCode('id', shape: const Circle()),
                title: Text('Bahasa Indonesia'),
                onTap: () {
                  setState(() {
                    MyApp.updateLocale(context, const Locale('id'));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LocalizationService localizations = LocalizationService.of(context)!;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(localizations.translate('settings')),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language),
            title: Text(localizations.translate('language')),
            onTap: () {
              _changeLanguage(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(localizations.translate('logout')),
            onTap: () {
              _signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
