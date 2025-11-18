class Strings {
  const Strings._();

  /// Private field to store the currently selected locale
  static String? _locale;

  /// Method to set the active language/locale
  /// [locale] - The locale identifier to set
  static void setLanguage(String locale) {
    _locale = locale;
  }

  /// - `en` Localizy
  ///
  /// - `hi-IN` लोकलाइज़ी
  static String get appName => _getValue('app_name');

  /// - `en` Localizy Demo
  ///
  /// - `hi-IN` लोकलाईज़ी डेमो
  static String get demo => _getValue('demo');

  /// Generate locale-specific methods
  static Map<String, String> _en() =>
      {'app_name': 'Localizy', 'demo': 'Localizy Demo'};
  static Map<String, String> _hi_IN() =>
      {'app_name': 'लोकलाइज़ी', 'demo': 'लोकलाईज़ी डेमो'};

  /// Method that returns a map of all locales and their key-value pairs
  static Map<String, Map<String, String>> _stuff() => {
        'en': _en(),
        'hi-IN': _hi_IN(),
      };

  /// Private method to get the value for a given key from the current locale
  /// [s] - The localization key to look up
  /// Returns the localized value or an empty string if not found
  static String _getValue(String s) {
    if (_locale == null) return '';
    return _stuff()[_locale]?[s] ?? '';
  }
}
