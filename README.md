# flutter_google_places
<p align="left">
  <a href="https://pub.dartlang.org/packages/flutter_google_places"><img alt="pub version" src="https://img.shields.io/pub/v/flutter_google_places.svg?style=flat-square"></a>
</p>

Google places autocomplete widgets for flutter.

<div style="text-align: center"><table><tr>
    <td style="text-align: center">
<img src="https://github.com/lejard-h/flutter_google_places/blob/master/flutter_01.png" height="400">
</td>
<td style="text-align: center">
<img src="https://github.com/lejard-h/flutter_google_places/blob/master/flutter_02.png" height="400">
</td>
</tr>
</table>
</div>

## Getting Started

For help getting started with Flutter, view our online [documentation](http://flutter.io/).

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  flutter_google_places: <last-version>
```

```dart

const kGoogleApiKey = "API_KEY";

Prediction p = await PlacesAutocomplete.show(
                          context: context,
                          apiKey: kGoogleApiKey,
                          mode: Mode.overlay, // Mode.fullscreen
                          language: "fr",
                          components: [new Component(Component.country, "fr")]);

```

The library use [google_maps_webservice](https://github.com/lejard-h/google_maps_webservice) library which directly refer to the official [documentation](https://developers.google.com/maps/web-services/) for google maps web service. 
