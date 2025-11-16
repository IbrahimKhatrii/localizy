# **Localizy Generator**

A simple Dart-based localization generator that converts your JSON locale files into a strongly-typed `strings.dart` file with camelCase getters and safe normalized keys.

---

## **Features**

- Reads all JSON files from a folder (`en.json`, `hi.json`, etc.)
- Generates a single `strings.dart` file
- Normalizes keys (handles invalid characters, numbers, reserved keywords)
- Creates camelCase getters for every string
- Supports runtime language switching
- Zero dependencies — pure Dart

---

## **Folder Structure**

```
assets/localizy/
    en.json
    hi.json
lib/localization/
    strings.dart   ← generated output
tool/localizy.dart
```

---

## **JSON Format**

### `assets/localizy/en.json`

```json
{
  "app_name": "Localizy Demo",
  "welcome_message": "Hello World"
}
```

### `assets/localizy/hi.json`

```json
{
  "app_name": "लोकलाईज़ी डेमो",
  "welcome_message": "नमस्ते दुनिया"
}
```

---

## **How to Run**

Default paths:

```
dart run tool/localizy.dart
```

Custom input/output paths:

```
dart run tool/localizy.dart assets/translations lib/gen
```

---

## **How to Use in Code**

```dart
Strings.setLanguage('en');

print(Strings.appName);         // Localizy Demo
print(Strings.welcomeMessage);  // Hello World
```

---

## **Generated File Overview (`strings.dart`)**

It auto-creates:

- A `Strings` class
- Getters for each string
- A map for each locale
- A `_stuff()` method holding all locale maps
- Internally: `Strings.setLanguage(locale)` + `_getValue(key)`

Example getter:

```dart
static String get welcomeMessage => _getValue('welcome_message');
```

---

## **Key Normalization Rules**

| Original Key       | Normalized Key | Getter Name |
| ------------------ | -------------- | ----------- |
| `app_name`         | `app_name`     | `appName`   |
| `user-name`        | `user_name`    | `userName`  |
| `123value`         | `_123value`    | `_123value` |
| `class` (reserved) | `_k_class`     | `_kClass`   |

Rules applied:

- Replaces invalid chars with `_`
- Prefixes `_` if the key starts with a number
- Prefixes `_k_` if the key matches a Dart reserved keyword

---

## **CLI Arguments**

| Argument | Description               | Default            |
| -------- | ------------------------- | ------------------ |
| `arg[0]` | Input localization folder | `assets/localizy`  |
| `arg[1]` | Output folder             | `lib/localization` |

---

## **Error Handling**

- Prints a message if the input directory does not exist
- Warns if no JSON files are found
- Catches and logs exceptions during generation

---

## **Why This Generator?**

- Avoids handwritten string maps
- Gives you type-safe localization without heavy frameworks
- Perfect for small/medium Flutter projects or custom setups
- Output stays completely predictable and static

---

## **License**

MIT

---
