import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';
import 'package:flutter/material.dart';

const API_KEY = "API_KEY";

main() {
  runApp(new MaterialApp(
      title: "My App",
      home: new MyApp(),
      theme: new ThemeData(accentColor: Colors.redAccent)));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

final scaffoldKey = new GlobalKey();

class _MyAppState extends State<MyApp> {
  Mode _mode = Mode.overlay;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
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
                    apiKey: API_KEY,
                    mode: _mode,
                    language: "fr",
                    components: [new Component(Component.country, "fr")]);

                if (p != null) {
                  (scaffoldKey.currentState as ScaffoldState).showSnackBar(
                      new SnackBar(content: new Text(p.description)));
                }
              },
              child: new Text("Search places"))
        ],
      )),
    );
  }
}
