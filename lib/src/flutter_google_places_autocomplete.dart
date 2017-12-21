library flutter_google_places_autocomplete.src;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:google_maps_webservice/places.dart';

class GooglePlacesAutocompleteWidget extends StatefulWidget {
  final String apiKey;
  final String hint;
  final Location location;
  final num offset;
  final num radius;
  final String language;
  final List<String> types;
  final List<Component> components;
  final bool strictbounds;
  final Mode mode;

  GooglePlacesAutocompleteWidget(
      {@required this.apiKey,
      this.mode = Mode.fullscreen,
      this.hint = "Search",
      this.offset,
      this.location,
      this.radius,
      this.language,
      this.types,
      this.components,
      this.strictbounds});

  @override
  State<GooglePlacesAutocompleteWidget> createState() {
    if (mode == Mode.fullscreen) {
      return new _GooglePlacesAutocompleteFullscreenState();
    }
    return new _GooglePlacesAutocompleteOverlayState();
  }
}

class _GooglePlacesAutocompleteOverlayState
    extends State<GooglePlacesAutocompleteWidget> {
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

  _doSearch(String value) async {
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
    } else {
      setState(() {
        _response = null;
        _searching = false;
      });
    }
  }

  Timer _timer;

  _search(String value) async {
    _timer?.cancel();
    _timer = new Timer(const Duration(milliseconds: 300), () {
      _timer.cancel();
      _doSearch(value);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _places.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = new Column(children: <Widget>[
      new Material(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
              topLeft: new Radius.circular(2.0),
              topRight: new Radius.circular(2.0)),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new IconButton(
                color: Colors.black45,
                icon: _iconBack,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              new Expanded(child: _textField()),
            ],
          )),
      new Divider(
          //height: 1.0,
          )
    ]);

    var body;

    if (_searching) {
      body = new Stack(
        children: <Widget>[header, new _Loader()],
        alignment: FractionalOffset.bottomCenter,
      );
    } else if (_query.text.isEmpty ||
        _response == null ||
        _response.predictions.isEmpty) {
      body = new Material(
        color: Colors.white,
        child: new PoweredByGoogleImage(),
        borderRadius: new BorderRadius.only(
            bottomLeft: new Radius.circular(2.0),
            bottomRight: new Radius.circular(2.0)),
      );
    } else {
      body = new SingleChildScrollView(
          child: new Material(
              borderRadius: new BorderRadius.only(
                  bottomLeft: new Radius.circular(2.0),
                  bottomRight: new Radius.circular(2.0)),
              color: Colors.white,
              child: new ListBody(
                  children: _response.predictions
                      .map((p) => new PredictionTile(prediction: p))
                      .toList())));
    }

    return new Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: new Stack(children: <Widget>[
          header,
          new Padding(padding: new EdgeInsets.only(top: 48.0), child: body),
        ]));
  }

  Icon get _iconBack => Platform.isIOS
      ? new Icon(Icons.arrow_back_ios)
      : new Icon(Icons.arrow_back);

  _textField() => new TextField(
        controller: _query,
        autofocus: true,
        decoration: new InputDecoration(
            hintText: widget.hint,
            hintStyle: new TextStyle(color: Colors.black54, fontSize: 16.0),
            hideDivider: true),
        onChanged: _search,
      );
}

class _Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
        constraints: new BoxConstraints(maxHeight: 2.0),
        child: new LinearProgressIndicator());
  }
}

class _GooglePlacesAutocompleteFullscreenState
    extends State<GooglePlacesAutocompleteWidget> {
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
      final children = <Widget>[];
      if (_searching) {
        children.add(new _Loader());
      }
      children.add(new PoweredByGoogleImage());
      body = new Stack(children: children);
    } else {
      body = new PredictionsListView(predictions: _response.predictions);
    }

    return new Scaffold(appBar: new AppBar(title: _textField()), body: body);
  }

  _textField() => new Container(
      alignment: Alignment.topLeft,
      margin: new EdgeInsets.only(top: 4.0),
      child: new TextField(
        controller: _query,
        autofocus: true,
        style: new TextStyle(color: Colors.white70, fontSize: 16.0),
        decoration: new InputDecoration(
            hintText: widget.hint,
            hintStyle: new TextStyle(color: Colors.white30, fontSize: 16.0),
            hideDivider: true),
        onChanged: _search,
      ));

  Timer _timer;

  _doSearch(String value) async {
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
    } else {
      setState(() {
        _response = null;
        _searching = false;
      });
    }
  }

  _search(String value) async {
    _timer?.cancel();
    _timer = new Timer(const Duration(milliseconds: 300), () {
      _timer.cancel();
      _doSearch(value);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _places.dispose();
  }
}

class PoweredByGoogleImage extends StatelessWidget {
  final _poweredByGoogleWhite =
      "https://developers.google.com/places/documentation/images/powered-by-google-on-white.png";
  final _poweredByGoogleBlack =
      "https://developers.google.com/places/documentation/images/powered-by-google-on-non-white.png";

  @override
  Widget build(BuildContext context) {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Padding(
              padding: new EdgeInsets.all(16.0),
              child: new Image.network(
                Theme.of(context).brightness == Brightness.light
                    ? _poweredByGoogleWhite
                    : _poweredByGoogleBlack,
              ))
        ]);
  }
}

class PredictionsListView extends StatelessWidget {
  final List<Prediction> predictions;

  PredictionsListView({@required this.predictions});

  @override
  Widget build(BuildContext context) {
    return new ListView(
        children: predictions
            .map((Prediction p) => new PredictionTile(prediction: p))
            .toList());
  }
}

class PredictionTile extends StatelessWidget {
  final Prediction prediction;

  PredictionTile({@required this.prediction});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new Icon(Icons.location_on),
      title: new Text(prediction.description),
      onTap: () {
        Navigator.of(context).pop(prediction);
      },
    );
  }
}

Future<Prediction> showGooglePlacesAutocomplete(
    {@required BuildContext context,
    @required String apiKey,
    Mode mode = Mode.fullscreen,
    String hint = "Search",
    num offset,
    Location location,
    num radius,
    String language,
    List<String> types,
    List<Component> components,
    bool strictbounds}) {
  final builder = (BuildContext ctx) => new GooglePlacesAutocompleteWidget(
        apiKey: apiKey,
        mode: mode,
        language: language,
        components: components,
        types: types,
        location: location,
        strictbounds: strictbounds,
        offset: offset,
        hint: hint,
      );

  if (mode == Mode.overlay) {
    return showDialog(context: context, child: builder(context));
  }
  return Navigator.push(context, new MaterialPageRoute(builder: builder));
}

enum Mode { overlay, fullscreen }
