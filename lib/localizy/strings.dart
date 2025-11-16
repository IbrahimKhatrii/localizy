class Strings {
  const Strings._();

  /// Private field to store the currently selected locale
  static String? _locale;

  /// Method to set the active language/locale
  /// [locale] - The locale identifier to set
  static void setLanguage(String locale) {
    _locale = locale;
  }

  /// en: Localizy,
  /// hi: स्वागत ऐप
  static String get appName => _getValue('app_name');

  /// Generate locale-specific methods
  static Map<String, String> _en() => {'app_name': 'Localizy'};
  static Map<String, String> _hi() => {'app_name': 'Localizy'};

  /// Method that returns a map of all locales and their key-value pairs
  static Map<String, Map<String, String>> _stuff() => {
        'en': _en(),
        'hi': _hi(),
      };

  /// Private method to get the value for a given key from the current locale
  /// [s] - The localization key to look up
  /// Returns the localized value or an empty string if not found
  static String _getValue(String s) {
    if (_locale == null) return '';
    return _stuff()[_locale]?[s] ?? '';
  }
}
