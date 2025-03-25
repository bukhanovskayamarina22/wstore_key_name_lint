# Wstore Key Name Lint Package

This package provides a custom linter for Dart applications using the `wstore` package for state management. Its primary function is to ensure that the `keyName` of computed getters matches the name of the getter itself.

## Features

- Validates that the `keyName` parameter of computed getters matches the getter name.
- Helps maintain consistency and avoid errors in state management.

## Installation

To use this linter in your Dart project, add this package to your `pubspec.yaml`:

```yaml
dev_dependencies:
  key_name_lint: 
    git:
      url: https://github.com/bukhanovskayamarina22/wstore_key_name_lint.git
      ref: <commit-hash> // optional
```

## Usage

After adding the package, you can run the linter with the following command:

```bash
dart run custom_lint
```

## Example

Here's an example of how the linter works:

```dart
GlobalErrors get globalError => computedFromStore(
  store: ErrorsStore(),
  getValue: (store) => store.globalError,
  keyName: 'globalError', // This is correct
);
```

If the `keyName` does not match the getter name, the linter will report an error:

```dart
GlobalErrors get globalError => computedFromStore(
  store: ErrorsStore(),
  getValue: (store) => store.globalError,
  keyName: 'incorrectKeyName', // This will trigger a linter error
);
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any bugs or feature requests.

## License

This package is licensed under the MIT License. See the `LICENSE` file for more information.

---

For more information about Dart and custom linting, visit the [Dart documentation](https://dart.dev).
