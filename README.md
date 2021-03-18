# flutter_google_places_hoc081098

Google places autocomplete widgets for flutter.

## Updated by [@hoc081098](https://github.com/hoc081098). See [file changes](https://github.com/fluttercommunity/flutter_google_places_hoc081098/compare/master...hoc081098:main)

[![Pub](https://img.shields.io/pub/v/flutter_google_places_hoc081098?include_prereleases)](https://pub.dev/packages/flutter_google_places_hoc081098)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fhoc081098%2Fflutter_google_places&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

- Migrated to **null-safety**.
- Updated dependencies to latest release.
- Refactoring by using **RxDart** for more power.
- Fixed many issues.
- Applied [pedantic](https://pub.dev/packages/pedantic).
- Refactored example, migrated to Android v2 embedding.

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_google_places_hoc081098: <last-version>
```

<div style="text-align: center">
<table>
    <tr>
        <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/hoc081098/flutter_google_places/master/flutter_01.png" height="400">
        </td>
        <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/hoc081098/flutter_google_places/master/flutter_02.png" height="400">
        </td>
    </tr>
</table>
</div>

## Simple usage

```dart
// replace flutter_google_places by flutter_google_places_hoc081098
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';

const kGoogleApiKey = 'API_KEY';

void onError(PlacesAutocompleteResponse response) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(response.errorMessage ?? 'Unknown error'),
    ),
  );
}

final Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  onError: onError,
  mode: Mode.overlay, // or Mode.fullscreen
  language: 'fr',
  components: [Component(Component.country, 'fr')],
);

```

The library use [google_maps_webservice](https://github.com/lejard-h/google_maps_webservice) library which directly refer to the official [documentation](https://developers.google.com/maps/web-services/) for google maps web service. 
