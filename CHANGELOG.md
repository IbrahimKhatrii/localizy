## 1.0.73

### Fixes

- Locale files containing hyphens (e.g., `hi-IN.json`) were not parsed correctly. This is now fully supported.
- The generated `strings.dart` file previously leaked dependencies from Localizy; it is now completely standalone after generation.
- Resolved several minor runtime issues caused by incorrect generation logic.

### Changes

- Refactored parts of the generator responsible for producing `strings.dart` to improve consistency and reliability.
