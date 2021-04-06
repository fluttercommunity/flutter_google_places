## 0.3.0

- Update packages
- Upgrade to null safety
- Upgrade and migrate android project to AndroidX
- PlacesAutocompleteFormField: replaced deprecated autovalidate with autovalidateMode
- PlacesAutocompleteWidget: removed deprecated methods, added decoration for fullscreen and overlay places widget

## 0.2.8

- Fix pub.dev complaints
  - Remove unsecure links
  - Replace deprecated `autovalidate` bool with `AutovalidateMode`
  - Formated with dartfmt

## 0.2.7

- Add expected label behaviour to PlacesAutocompleteField (PR #108)
- Auto select text (PR #109)
- Add to support app restricted API keys (PR #136)
- Replaced deprecated `ancestorStateOfType` method (PR #141)
- Updating rxdart version in pubspec.yaml (PR #143)

## 0.2.6

- Fix error on select place
- Fix bug where `controller.text` is not properly updated
- Fix issue when close the widget and "_queryBehavior" is trying to add text

## 0.2.5

- Updates rxdart to 0.24.0
- Updates google_maps_webservice to 0.0.16

## 0.2.4

- Added support for flutter web
- Update rxdart
- Add overlayBorderRadius parameter
- Add startText parameter

## 0.2.3

- Update rxdart and google_maps_webservice

## 0.2.0

- Better text theme for text input
- Allow proxyUrl with `proxyBaseUrl` and override http client with `httpClient`

## 0.1.4

- Rename footer to logo to be less confusing

## 0.1.3

- Update rxdart

## 0.1.2

- Fix dark mode

## 0.1.1

- Fix icons quality
- Fix input border when custom theme

## 0.1.0

- Update sdk and fix warnings

## 0.0.5

- Fix usage of radius

## 0.0.4

- Open widgets to create your own UI
- Add onError callback

## 0.0.3

- Add padding for overlay on iOS

## 0.0.2

- Update google_maps_webservice to ^0.0.3
- Fix placeholder position
- Fix keyboard clipping on overlay

## 0.0.1

- Initial version
