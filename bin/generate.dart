import 'dart:convert';
import 'dart:io';

/// Main function that serves as the entry point for the localization code generator
/// Takes command line arguments for input and output directories
void main(List<String> arguments) async {
  /// Get the localization directory from command line arguments, default to 'assets/localizy' if not provided
  final dir = arguments.isNotEmpty ? arguments[0] : 'assets/localizy';

  /// Get the output directory from command line arguments, default to 'lib/localization' if not provided
  final oDir = arguments.length > 1 ? arguments[1] : 'lib/localization';

  /// Generate the localization files
  await generate(dir, oDir);
}

/// Generates localization Dart code from JSON files
/// [localizationDir] - Directory containing JSON localization files
/// [outputDir] - Directory where generated Dart code will be saved
Future<void> generate(String localizationDir, String outputDir) async {
  try {
    /// Create the output directory if it doesn't exist, recursively creating parent directories if needed
    await Directory(outputDir).create(recursive: true);

    /// Get all JSON files from the localization directory
    final jsonFiles = await _getJsonFiles(localizationDir);

    /// Return early if no JSON files are found
    if (jsonFiles.isEmpty) return;

    /// List to store all locale identifiers found in the JSON files
    List<String> locales = [];

    /// Map to store localization data with locale as key and key-value pairs as value
    Map<String, Map<String, String>> data = {};

    /// Set to store all unique localization keys across all files
    Set<String> allKeys = {};

    /// Map to store all values mapped to their keys (used to preserve original values)
    Map<String, String> allValues = {};

    /// Process each JSON file
    for (final file in jsonFiles) {
      /// Read the content of the JSON file
      final x = await File(file).readAsString();

      /// Parse the JSON content into a Dart map
      final jsonData = json.decode(x) as Map<String, dynamic>;

      /// Extract the locale identifier from the filename by:
      /// - Replacing backslashes with forward slashes
      /// - Getting the last part after splitting by '/'
      /// - Converting to lowercase
      /// - Removing the '.json' extension
      final locale = file
          .replaceAll('\\', '/')
          .split('/')
          .last
          .toLowerCase()
          .replaceAll('.json', '');

      /// Add the locale to the list of locales
      locales.add(locale);

      /// Create a map to store the processed key-value pairs for this locale
      Map<String, String> map = {};

      /// Process each key-value pair in the JSON data
      jsonData.forEach((key, value) {
        /// Normalize the key to ensure it's a valid Dart identifier
        key = normalizeKey(key);

        /// Convert the value to string representation
        String stringValue = value.toString();

        /// Add the key-value pair to the map if it doesn't already exist
        map.putIfAbsent(
          key,
          () => stringValue,
        );

        /// Add the key to the set of all keys
        allKeys.add(key);

        /// Add the key-value pair to the allValues map if it doesn't already exist
        allValues.putIfAbsent(
          key,
          () => value,
        );
      });

      /// Add the locale and its data to the main data map if it doesn't already exist
      data.putIfAbsent(
        locale,
        () => map,
      );
    }

    /// Create a combined data map that contains all keys and their corresponding values
    Map<String, String> combinedData = {};
    for (String key in allKeys) {
      combinedData[key] = allValues[key]!;
    }

    /// Generate the content for the strings.dart file
    String content = _getStringsClassContent(locales, combinedData, data);

    /// Write the generated content to the strings.dart file
    await File('$outputDir/strings.dart').writeAsString(content);
  } catch (e) {
    /// Print error message if there's an exception during generation
    print('Error generating strings: $e');
  }
}

/// Gets all JSON files from the specified directory
/// [localizationDir] - Directory to search for JSON files
/// Returns a list of file paths for JSON files found
Future<List<String>> _getJsonFiles(String localizationDir) async {
  /// Initialize an empty list to store JSON file paths
  var files = <String>[];

  /// Create a Directory object for the localization directory
  final dir = Directory(localizationDir);

  /// Check if the directory exists
  if (!await dir.exists()) {
    /// Print error message if directory doesn't exist and return early
    print('Localization directory does not exist: $localizationDir');
    return [];
  }

  /// Iterate through all entities in the directory
  await for (final entity in dir.list()) {
    /// Check if entity is a File and has JSON extension (case-insensitive)
    if (entity is File && entity.path.toLowerCase().endsWith('.json')) {
      /// Add valid JSON file path to the list
      files.add(entity.path);
    }
  }

  /// Check if no JSON files were found
  if (files.isEmpty) {
    /// Print message if no JSON files are found
    print('No JSON files found in $localizationDir');
    return [];
  } else {
    /// Print message indicating number of localization files found
    print('Found ${files.length} localization files');
  }

  /// Return the list of JSON file paths
  return files;
}

/// Generates the content for the Strings class with all localization data
/// [locales] - List of locale identifiers
/// [data] - Map containing all localization key-value pairs
/// [localeData] - Map containing localization data per locale
/// Returns the generated Dart class content as a string
String _getStringsClassContent(List<String> locales, Map<String, String> data,
    Map<String, Map<String, String>> localeData) {
  /// String to store the locale-specific method definitions
  String localeMethods = '';

  /// String to store the locale map entries for the main map
  String localeMapEntries = '';

  /// Generate methods and map entries for each locale
  for (final locale in locales) {
    /// Add a method that returns the key-value map for this locale
    localeMethods +=
        '''static Map<String, String> _$locale() => {${_generateKeyValuePairs(localeData[locale]!)}};
  ''';

    /// Add an entry to the main locale map
    localeMapEntries += "'$locale': _$locale(),";
  }

  /// Return the complete class definition with all generated content
  return '''
class Strings {
  const Strings._();

  /// Private field to store the currently selected locale
  static String? _locale;

  /// Method to set the active language/locale
  /// [locale] - The locale identifier to set
  static void setLanguage(String locale) {
    _locale = locale;
  }

${_generateGetterMethods(data, localeData)}

  /// Generate locale-specific methods
  $localeMethods
  /// Method that returns a map of all locales and their key-value pairs
  static Map<String, Map<String, String>> _stuff() => {$localeMapEntries};

  /// Private method to get the value for a given key from the current locale
  /// [s] - The localization key to look up
  /// Returns the localized value or an empty string if not found
  static String _getValue(String s) {
    if (_locale == null) return '';
    return _stuff()[_locale]?[s] ?? '';
  }
}
''';
}

/// Generates key-value pairs in Dart map format for the localization data
/// [data] - Map containing localization key-value pairs
/// Returns a string representation of the key-value pairs for Dart code
String _generateKeyValuePairs(Map<String, String?> data) {
  /// List to store individual key-value pair strings
  List<String> pairs = [];

  /// Process each key-value pair in the data map
  data.forEach((key, value) {
    /// Add the key-value pair to the list, escaping single quotes in the value
    pairs.add("'${key}': '${value!.replaceAll("'", "\\'")}'");
  });

  /// Join all pairs with commas
  return pairs.join(', ');
}

/// Generates getter methods for each localization key with locale values in documentation
/// [data] - Map containing localization key-value pairs
/// [localeData] - Map containing localization data per locale
/// Returns a string containing all generated getter method definitions
String _generateGetterMethods(
    Map<String, String> data, Map<String, Map<String, String>> localeData) {
  /// List to store individual getter method strings
  List<String> getters = [];

  /// Process each key-value pair to create a getter method
  data.forEach((key, value) {
    /// Build the locale values documentation string with each locale on a new line
    List<String> localeLines = [];
    localeData.forEach((locale, localeMap) {
      if (localeMap.containsKey(key)) {
        localeLines.add("  /// - `$locale` ${localeMap[key]}");
      }
    });

    /// Generate a getter method using camelCase version of the key with locale values in documentation
    if (localeLines.isNotEmpty) {
      getters.add('''${localeLines.join('\n  ///\n')}
  static String get ${toCamelCase(key)} => _getValue('$key');
''');
    } else {
      /// If no locale values found, just add the basic getter
      getters.add('''
  /// Getter for the '$key'
  static String get ${toCamelCase(key)} => _getValue('$key');
''');
    }
  });

  /// Join all getter methods with newlines
  return getters.join('\n');
}

/// Converts a string to camelCase format
/// [input] - The input string to convert
/// Returns the camelCase version of the input string
String toCamelCase(String input) {
  /// Return empty string if input is empty or whitespace
  if (input.trim().isEmpty) return "";

  /// Split the input string by underscores, spaces, and hyphens, then filter out empty parts
  final parts = input
      .split(RegExp(r'[_\s-]+')) // underscores, spaces, hyphens — sab handle
      .where((p) => p.isNotEmpty)
      .toList();

  /// Convert the first part to lowercase (first word)
  final first = parts.first.toLowerCase();

  /// Convert the remaining parts to title case (first letter uppercase, rest lowercase) and join them
  final rest = parts
      .skip(1)
      .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
      .join();

  /// Combine the first part and the rest to form camelCase
  return first + rest;
}

/// Normalizes a key to ensure it's a valid Dart identifier
/// [key] - The key to normalize
/// Returns the normalized key that's safe to use as a Dart identifier
String normalizeKey(String key) {
  /// Set of reserved Dart keywords that cannot be used as identifiers
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

  /// Replace any non-alphanumeric characters (except underscore) with underscores
  String k = key.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');

  /// Add an underscore prefix if the key starts with a number
  if (RegExp(r'^[0-9]').hasMatch(k)) {
    k = '_$k';
  }

  /// Add a prefix if the key is a reserved Dart keyword
  if (reserved.contains(k)) {
    k = '_k_$k';
  }

  /// Return the normalized key
  return k;
}
