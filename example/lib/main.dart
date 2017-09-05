import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';
import 'package:flutter/material.dart';

const API_KEY = "AIzaSyBuZMpj_Yulhz4ux3BOndvxA4D8-PCEVrI";

main() {
  runApp(new MaterialApp(
      title: "My App",
      routes: {
        "/search": (_) => new GooglePlacesAutocompleteScaffoldRoute(
              apiKey: API_KEY,
              language: "fr",
              components: [new Component(Component.country, "fr")],
              types: ["geocode"],
            )
      },
      home: new MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

final scaffoldKey = new GlobalKey();

class _MyAppState extends State<MyApp> {
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
          new RaisedButton(
              onPressed: () async {
                Prediction p = await Navigator.of(context).pushNamed("/search");
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
