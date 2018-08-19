import 'dart:async';

import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';
import 'package:flutter/material.dart';

const kGoogleApiKey = "API_KEY";

// to get places detail (lat/lng)
GoogleMapsPlaces _places = new GoogleMapsPlaces(kGoogleApiKey);

main() {
  runApp(new MaterialApp(
    title: "My App",
    theme: new ThemeData(
      accentColor: Colors.redAccent,
      inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.00))),
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.50, horizontal: 10.00)),
    ),
    routes: {
      "/": (_) => new MyApp(),
      "/search": (_) => new CustomSearchScaffold()
    },
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

final homeScaffoldKey = new GlobalKey<ScaffoldState>();
final searchScaffoldKey = new GlobalKey<ScaffoldState>();

class _MyAppState extends State<MyApp> {
  Mode _mode = Mode.overlay;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: homeScaffoldKey,
      appBar: new AppBar(
        title: new Text("My App"),
      ),
      body: new Center(
          child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new DropdownButton(
              value: _mode,
              items: <DropdownMenuItem<Mode>>[
                new DropdownMenuItem<Mode>(
                    child: new Text("Overlay"), value: Mode.overlay),
                new DropdownMenuItem<Mode>(
                    child: new Text("Fullscreen"), value: Mode.fullscreen),
              ],
              onChanged: (m) {
                setState(() {
                  _mode = m;
                });
              }),
          new RaisedButton(
              onPressed: () async {
                // show input autocomplete with selected mode
                // then get the Prediction selected
                Prediction p = await showGooglePlacesAutocomplete(
                    context: context,
                    apiKey: kGoogleApiKey,
                    onError: (res) {
                      homeScaffoldKey.currentState.showSnackBar(
                          new SnackBar(content: new Text(res.errorMessage)));
                    },
                    mode: _mode,
                    language: "fr",
                    components: [new Component(Component.country, "fr")]);

                displayPrediction(p, homeScaffoldKey.currentState);
              },
              child: new Text("Search places")),
          new RaisedButton(
            child: new Text("Custom"),
            onPressed: () {
              Navigator.of(context).pushNamed("/search");
            },
          ),
        ],
      )),
    );
  }
}

Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
  if (p != null) {
    // get detail (lat/lng)
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    scaffold.showSnackBar(
        new SnackBar(content: new Text("${p.description} - $lat/$lng")));
  }
}

// custom scaffold that handle search
// basically your widget need to extends [GooglePlacesAutocompleteWidget]
// and your state [GooglePlacesAutocompleteState]
class CustomSearchScaffold extends GooglePlacesAutocompleteWidget {
  CustomSearchScaffold()
      : super(
            apiKey: kGoogleApiKey,
            language: "en",
            components: [new Component(Component.country, "uk")]);

  @override
  _CustomSearchScaffoldState createState() => new _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends GooglePlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final appBar = new AppBar(title: new AppBarPlacesAutoCompleteTextField());
    final body = new GooglePlacesAutocompleteResult(onTap: (p) {
      displayPrediction(p, searchScaffoldKey.currentState);
    });
    return new Scaffold(key: searchScaffoldKey, appBar: appBar, body: body);
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    searchScaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(response.errorMessage)));
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    if (response != null && response.predictions.isNotEmpty) {
      searchScaffoldKey.currentState
          .showSnackBar(new SnackBar(content: new Text("Got answer")));
    }
  }
}
