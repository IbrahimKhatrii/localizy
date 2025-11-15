import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) async {
  final dir = arguments.isNotEmpty ? arguments[0] : 'assets/localizy';
  final oDir = arguments.length > 1 ? arguments[1] : 'lib/localization';

  await generate(dir, oDir);
}

Future<void> generate(String localizationDir, String outputDir) async {
  try {
    await Directory(outputDir).create(recursive: true);
    final jsonFiles = await _getJsonFiles(localizationDir);
    if (jsonFiles.isEmpty) return;

    List<String> locales = [];
    Map<String, Map<String, String>> data = {};
    Set<String> allKeys = {};
    Map<String, String> allValues = {};

    for (final file in jsonFiles) {
      final x = await File(file).readAsString();

      final jsonData = json.decode(x) as Map<String, dynamic>;

      final locale = file
          .replaceAll('\\', '/')
          .split('/')
          .last
          .toLowerCase()
          .replaceAll('.json', '');

      locales.add(locale);

      Map<String, String> map = {};

      jsonData.forEach((key, value) {
        key = normalizeKey(key);
        String stringValue = value.toString();
        map.putIfAbsent(
          key,
          () => stringValue,
        );
        allKeys.add(key);
        allValues.putIfAbsent(
          key,
          () => value,
        );
      });

      data.putIfAbsent(
        locale,
        () => map,
      );
    }

    Map<String, String> combinedData = {};
    for (String key in allKeys) {
      combinedData[key] = allValues[key]!;
    }

    String content = _getStringsClassContent(locales, combinedData);

    await File('$outputDir/strings.dart').writeAsString(content);
  } catch (e) {
    print('Error generating strings: $e');
  }
}

Future<List<String>> _getJsonFiles(String localizationDir) async {
  var files = <String>[];
  final dir = Directory(localizationDir);
  if (!await dir.exists()) {
    /// Print error message if directory doesn't exist and return early
    print('Localization directory does not exist: $localizationDir');
    return [];
  }
  await for (final entity in dir.list()) {
    /// Check if entity is a File and has JSON extension (case-insensitive)
    if (entity is File && entity.path.toLowerCase().endsWith('.json')) {
      /// Add valid JSON file path to the list
      files.add(entity.path);
    }
  }
  if (files.isEmpty) {
    /// Print message if no JSON files are found
    print('No JSON files found in $localizationDir');
    return [];
  } else {
    print('Found ${files.length} localization files');
  }
  return files;
}

String _getStringsClassContent(List<String> locales, Map<String, String> data) {
  String localeMethods = '';
  String localeMapEntries = '';

  for (final locale in locales) {
    localeMethods += '''
  static Map<String, String> _$locale() {
    return {${_generateKeyValuePairs(data)}};
  }

''';
    localeMapEntries += "      '$locale': _$locale(),\n";
  }

  return '''
class Strings {
  const Strings._();

  static String? _locale;

  static void setLanguage(String locale) {
    _locale = locale;
  }

${_generateGetterMethods(data)}

  $localeMethods
  static Map<String, Map<String, String>> _stuff() {
    return {
$localeMapEntries    };
  }

  static String? _getValue(String s) {
    if (_locale == null) return null;
    return _stuff()[_locale]?[s];
  }
}
''';
}

String _generateKeyValuePairs(Map<String, String> data) {
  List<String> pairs = [];
  data.forEach((key, value) {
    pairs.add("'${key}': '${value.replaceAll("'", "\\'")}'");
  });
  return pairs.join(', ');
}

String _generateGetterMethods(Map<String, String> data) {
  List<String> getters = [];
  data.forEach((key, value) {
    getters.add('''
  static String? get $key {
    return _getValue('$key');
  }
''');
  });
  return getters.join('\n');
}

String normalizeKey(String key) {
  const reserved = {
    'assert',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'do',
    'else',
    'enum',
    'extends',
    'false',
    'final',
    'finally',
    'for',
    'if',
    'in',
    'is',
    'new',
    'null',
    'rethrow',
    'return',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'var',
    'void',
    'while',
    'with',
    'typedef',
    'await',
    'async',
    'yield'
  };

  String k = key.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');

  if (RegExp(r'^[0-9]').hasMatch(k)) {
    k = '_$k';
  }

  if (reserved.contains(k)) {
    k = '_k_$k';
  }

  return k;
}
