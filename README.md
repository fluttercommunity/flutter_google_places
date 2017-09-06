# flutter_google_places_autocomplete

Google places autocomplete widgets for flutter.

## Getting Started

For help getting started with Flutter, view our online [documentation](http://flutter.io/).

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  flutter_google_places_autocomplete: <last-version>
```

```dart

const GOOGLE_API_KEY = "API_KEY";

Prediction p = await showGooglePlacesAutocomplete(
                          context: context,
                          apiKey: API_KEY,
                          mode: Mode.overlay, // Mode.fullscreen
                          language: "fr",
                          components: [new Component(Component.country, "fr")]);

```