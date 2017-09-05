library flutter_google_places_autocomplete.src;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:google_maps_webservice/places.dart';

const _poweredByGoogleWhite =
    "https://developers.google.com/places/documentation/images/powered-by-google-on-white.png";
const _poweredByGoogleBlack =
    "https://developers.google.com/places/documentation/images/powered-by-google-on-non-white.png";

class GooglePlacesAutocompleteScaffoldRoute extends StatefulWidget {
  final String apiKey;
  final String hint;
  final Location location;
  final num offset;
  final num radius;
  final String language;
  final List<String> types;
  final List<Component> components;
  final bool strictbounds;

  GooglePlacesAutocompleteScaffoldRoute(
      {@required this.apiKey,
      this.hint = "Search",
      this.offset,
      this.location,
      this.radius,
      this.language,
      this.types,
      this.components,
      this.strictbounds});

  @override
  _GooglePlacesAutocompleteScaffoldState createState() =>
      new _GooglePlacesAutocompleteScaffoldState();
}

class _GooglePlacesAutocompleteScaffoldState
    extends State<GooglePlacesAutocompleteScaffoldRoute> {
  TextEditingController _query;
  PlacesAutocompleteResponse _response;
  GoogleMapsPlaces _places;
  bool _searching;

  @override
  void initState() {
    super.initState();
    _query = new TextEditingController(text: "");
    _places = new GoogleMapsPlaces(widget.apiKey);
    _searching = false;
  }

  @override
  Widget build(BuildContext context) {
    var body;

    if (_query.text.isEmpty ||
        _response == null ||
        _response.predictions.isEmpty) {
      var children = <Widget>[];
      if (_searching) {
        children.add(new LinearProgressIndicator());
      }
      children.add(new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
                padding: new EdgeInsets.all(8.0),
                child: new Image.network(
                    Theme.of(context).brightness == Brightness.light
                        ? _poweredByGoogleWhite
                        : _poweredByGoogleBlack))
          ]));
      body = new Stack(children: children);
    } else {
      body = new ListView(
          children: _response.predictions
              .map((Prediction p) => new ListTile(
                    leading: new Icon(Icons.location_on),
                    title: new Text(p.description),
                    onTap: () {
                      Navigator.of(context).pop(p);
                    },
                  ))
              .toList());
    }

    return new Scaffold(
        appBar: new AppBar(
            title: new TextField(
          controller: _query,
          autofocus: true,
          style: new TextStyle(color: Colors.white70, fontSize: 16.0),
          decoration: new InputDecoration(
              hintText: widget.hint,
              hintStyle: new TextStyle(color: Colors.white30, fontSize: 16.0),
              hideDivider: true),
          onChanged: _search,
        )),
        body: body);
  }

  _search(String value) async {
    if (value.isNotEmpty) {
      setState(() {
        _searching = true;
      });

      final response = await _places.autocomplete(value,
          offset: widget.offset,
          location: widget.location,
          radius: widget.radius,
          language: widget.language,
          types: widget.types,
          components: widget.components,
          strictbounds: widget.strictbounds);

      setState(() {
        _response = response;
        _searching = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _places.dispose();
  }
}
