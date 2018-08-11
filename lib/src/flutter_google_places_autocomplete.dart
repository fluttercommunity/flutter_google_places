library flutter_google_places_autocomplete.src;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  final ValueChanged<PlacesAutocompleteResponse> onError;

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
      this.strictbounds,
      this.onError,
      Key key})
      : super(key: key);

  @override
  State<GooglePlacesAutocompleteWidget> createState() {
    if (mode == Mode.fullscreen) {
      return new _GooglePlacesAutocompleteScaffoldState();
    }
    return new _GooglePlacesAutocompleteOverlayState();
  }

  static GooglePlacesAutocompleteState of(BuildContext context) => context
      .ancestorStateOfType(const TypeMatcher<GooglePlacesAutocompleteState>());
}

class _GooglePlacesAutocompleteScaffoldState
    extends GooglePlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final appBar = new AppBar(title: new AppBarPlacesAutoCompleteTextField());
    final body =
        new GooglePlacesAutocompleteResult(onTap: Navigator.of(context).pop);
    return new Scaffold(appBar: appBar, body: body);
  }
}

class _GooglePlacesAutocompleteOverlayState
    extends GooglePlacesAutocompleteState {
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
              new Expanded(
                  child: new Padding(
                child: _textField(),
                padding: const EdgeInsets.only(right: 8.0),
              )),
            ],
          )),
      new Divider(
          //height: 1.0,
          )
    ]);

    var body;

    if (searching) {
      body = new Stack(
        children: <Widget>[header, new _Loader()],
        alignment: FractionalOffset.bottomCenter,
      );
    } else if (query.text.isEmpty ||
        response == null ||
        response.predictions.isEmpty) {
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
                  children: response.predictions
                      .map((p) => new PredictionTile(
                          prediction: p, onTap: Navigator.of(context).pop))
                      .toList())));
    }

    final container = new Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: new Stack(children: <Widget>[
          header,
          new Padding(padding: new EdgeInsets.only(top: 48.0), child: body),
        ]));

    if (Platform.isIOS) {
      return new Padding(
          padding: new EdgeInsets.only(top: 8.0), child: container);
    }
    return container;
  }

  Icon get _iconBack => Platform.isIOS
      ? new Icon(Icons.arrow_back_ios)
      : new Icon(Icons.arrow_back);

  Widget _textField() => new TextField(
        controller: query,
        autofocus: true,
        decoration: new InputDecoration(
            hintText: widget.hint,
            hintStyle: new TextStyle(color: Colors.black54, fontSize: 16.0),
            border: null),
        onChanged: search,
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

class GooglePlacesAutocompleteResult extends StatefulWidget {
  final ValueChanged<Prediction> onTap;

  GooglePlacesAutocompleteResult({this.onTap});

  @override
  _GooglePlacesAutocompleteResult createState() =>
      new _GooglePlacesAutocompleteResult();
}

class _GooglePlacesAutocompleteResult
    extends State<GooglePlacesAutocompleteResult> {
  @override
  Widget build(BuildContext context) {
    final state = GooglePlacesAutocompleteWidget.of(context);
    assert(state != null);

    if (state.query.text.isEmpty ||
        state.response == null ||
        state.response.predictions.isEmpty) {
      final children = <Widget>[];
      if (state.searching) {
        children.add(new _Loader());
      }
      children.add(new PoweredByGoogleImage());
      return new Stack(children: children);
    }
    return new PredictionsListView(
        predictions: state.response.predictions, onTap: widget.onTap);
  }
}

class AppBarPlacesAutoCompleteTextField extends StatefulWidget {
  @override
  _AppBarPlacesAutoCompleteTextFieldState createState() =>
      new _AppBarPlacesAutoCompleteTextFieldState();
}

class _AppBarPlacesAutoCompleteTextFieldState
    extends State<AppBarPlacesAutoCompleteTextField> {
  @override
  Widget build(BuildContext context) {
    final state = GooglePlacesAutocompleteWidget.of(context);
    assert(state != null);

    return new Container(
        alignment: Alignment.topLeft,
        margin: new EdgeInsets.only(top: 4.0),
        child: new TextField(
          controller: state.query,
          autofocus: true,
          style: new TextStyle(color: Colors.white70, fontSize: 16.0),
          decoration: new InputDecoration(
              hintText: state.widget.hint,
              hintStyle: new TextStyle(color: Colors.white30, fontSize: 16.0),
              border: null), //try to delete 
          onChanged: state.search,
        ));
  }
}

class PoweredByGoogleImage extends StatelessWidget {
//Okey, let's start with icon.
//You can download 1x, 2x and 3x-sized icons right here: https://developers.google.com/maps/documentation/images/powered_by_google.zip
//After that, you'll fix pixelation on icons. So, in official flutter website, you can find how to add image assets with
//different sizes. I don't really know how to create PR with my own files and directories, so I hope you have time to do that.
  final _poweredByGoogleWhite =
      "assets/powered-by-google-on-white.png";
  //It will automatically find an icon that a device need.
  //The structure of your project will be smth like: 
  //assets/icon.png
  //assets/2.0x/icon.png
  //assets/3.0x/icon.png etc.
  final _poweredByGoogleBlack =
      "assets/powered-by-google-on-non-white.png";

  @override
  Widget build(BuildContext context) {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Padding(
              padding: new EdgeInsets.all(16.0),
              child: new Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? _poweredByGoogleWhite
                    : _poweredByGoogleBlack,
              )) // Even if Google Places API requests internet connection, it's much better to use pre-downloaded assets.
        ]);
  }
}

class PredictionsListView extends StatelessWidget {
  final List<Prediction> predictions;
  final ValueChanged<Prediction> onTap;

  PredictionsListView({@required this.predictions, this.onTap});

  @override
  Widget build(BuildContext context) {
    return new ListView(
        children: predictions
            .map((Prediction p) =>
                new PredictionTile(prediction: p, onTap: onTap))
            .toList());
  }
}

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  final ValueChanged<Prediction> onTap;

  PredictionTile({@required this.prediction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new Icon(Icons.location_on),
      title: new Text(prediction.description),
      onTap: () {
        if (onTap != null) {
          onTap(prediction);
        }
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
    bool strictbounds,
    ValueChanged<PlacesAutocompleteResponse> onError}) {
  final builder = (BuildContext ctx) => new GooglePlacesAutocompleteWidget(
        apiKey: apiKey,
        mode: mode,
        language: language,
        components: components,
        types: types,
        location: location,
        radius: radius,
        strictbounds: strictbounds,
        offset: offset,
        hint: hint,
        onError: onError,
      );

  if (mode == Mode.overlay) {
    return showDialog(context: context, builder: builder);
  }
  return Navigator.push(context, new MaterialPageRoute(builder: builder));
}

enum Mode { overlay, fullscreen }

abstract class GooglePlacesAutocompleteState
    extends State<GooglePlacesAutocompleteWidget> {
  TextEditingController query;
  PlacesAutocompleteResponse response;
  GoogleMapsPlaces _places;
  bool searching;

  @override
  void initState() {
    super.initState();
    query = new TextEditingController(text: "");
    _places = new GoogleMapsPlaces(widget.apiKey);
    searching = false;
  }

  Future<Null> doSearch(String value) async {
    if (mounted && value.isNotEmpty) {
      setState(() {
        searching = true;
      });

      final res = await _places.autocomplete(value,
          offset: widget.offset,
          location: widget.location,
          radius: widget.radius,
          language: widget.language,
          types: widget.types,
          components: widget.components,
          strictbounds: widget.strictbounds);

      if (res.errorMessage?.isNotEmpty == true ||
          res.status == "REQUEST_DENIED") {
        onResponseError(res);
      } else {
        onResponse(res);
      }
    } else {
      onResponse(null);
    }
  }

  Timer _timer;

  Future<Null> search(String value) async {
    _timer?.cancel();
    _timer = new Timer(const Duration(milliseconds: 300), () {
      _timer.cancel();
      doSearch(value);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _places.dispose();
    super.dispose();
  }

  @mustCallSuper
  void onResponseError(PlacesAutocompleteResponse res) {
    if (mounted) {
      if (widget.onError != null) {
        widget.onError(res);
      }
      setState(() {
        response = null;
        searching = false;
      });
    }
  }

  @mustCallSuper
  void onResponse(PlacesAutocompleteResponse res) {
    if (mounted) {
      setState(() {
        response = res;
        searching = false;
      });
    }
  }
}
