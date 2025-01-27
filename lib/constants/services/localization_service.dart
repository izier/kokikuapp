import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  final Locale locale;

  LocalizationService(this.locale);

  static LocalizationService? of(BuildContext context) {
    return Localizations.of<LocalizationService>(context, LocalizationService);
  }

  static const LocalizationsDelegate<LocalizationService> delegate =
  _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    try {
      // Attempt to load the JSON file for the current locale
      String jsonString =
      await rootBundle.loadString('l10n/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Convert dynamic JSON map to a String map
      _localizedStrings =
          jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      // Handle errors (e.g., file not found, parsing issues)
      debugPrint('Error loading localization file: $e');
      _localizedStrings = {}; // Ensure it's initialized to an empty map
      return false;
    }
  }

  String translate(String key) {
    // Always return a valid string, fallback to the key if translation is missing
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<LocalizationService> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Define supported locales
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<LocalizationService> load(Locale locale) async {
    // Create an instance of LocalizationService and load translations
    LocalizationService localizations = LocalizationService(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
