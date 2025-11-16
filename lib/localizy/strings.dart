class Strings {
  const Strings._();

  static String? _locale;

  static void setLanguage(String locale) {
    _locale = locale;
  }

  static String get appName => _getValue('app_name');


  static Map<String, String> _en() => {'app_name': 'Localizy'};static Map<String, String> _hi() => {'app_name': 'Localizy'};
  static Map<String, Map<String, String>> _stuff() => {      'en': _en(),
      'hi': _hi(),
};

  static String _getValue(String s) {
    if (_locale == null) return '';
    return _stuff()[_locale]?[s] ?? '';
  }
}
