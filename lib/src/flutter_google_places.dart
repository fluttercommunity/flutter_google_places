library flutter_google_places_hoc081098.src;

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart';
import 'package:listenable_stream/listenable_stream.dart';
import 'package:rxdart/rxdart.dart';

class PlacesAutocompleteWidget extends StatefulWidget {
  final String? apiKey;
  final Mode mode;
  final String? hint;

  final String? startText;
  final BorderRadius? overlayBorderRadius;
  final Location? location;
  final Location? origin;
  final num? offset;
  final num? radius;
  final String? language;
  final String? sessionToken;
  final List<String>? types;
  final List<Component>? components;
  final bool? strictbounds;
  final String? region;
  final Widget? logo;
  final ValueChanged<PlacesAutocompleteResponse>? onError;
  final Duration? debounce;
  final Map<String, String>? headers;

  /// optional - sets 'proxy' value in google_maps_webservice
  ///
  /// In case of using a proxy the baseUrl can be set.
  /// The apiKey is not required in case the proxy sets it.
  /// (Not storing the apiKey in the app is good practice)
  final String? proxyBaseUrl;

  /// optional - set 'client' value in google_maps_webservice
  ///
  /// In case of using a proxy url that requires authentication
  /// or custom configuration
  final Client? httpClient;

  PlacesAutocompleteWidget(
      {Key? key,
      required this.apiKey,
      this.mode = Mode.fullscreen,
      this.hint = 'Search',
      this.overlayBorderRadius,
      this.offset,
      this.location,
      this.origin,
      this.radius,
      this.language,
      this.sessionToken,
      this.types,
      this.components,
      this.strictbounds,
      this.region,
      this.logo,
      this.onError,
      this.proxyBaseUrl,
      this.httpClient,
      this.startText,
      this.debounce,
      this.headers})
      : super(key: key) {
        if (apiKey == null && proxyBaseUrl == null) {
          throw ArgumentError('One of `apiKey` and `proxyBaseUrl` fields is required');
        }
      }

  @override
  State<PlacesAutocompleteWidget> createState() {
    if (mode == Mode.fullscreen) {
      return _PlacesAutocompleteScaffoldState();
    }
    return _PlacesAutocompleteOverlayState();
  }

  static PlacesAutocompleteState of(BuildContext context) =>
      context.findAncestorStateOfType<PlacesAutocompleteState>()!;
}

class _PlacesAutocompleteScaffoldState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
        title: AppBarPlacesAutoCompleteTextField(
            textDecoration: null, textStyle: null));
    final body = PlacesAutocompleteResult(
      onTap: Navigator.of(context).pop,
      logo: widget.logo,
    );
    return Scaffold(appBar: appBar, body: body);
  }
}

class _PlacesAutocompleteOverlayState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final headerTopLeftBorderRadius =
        widget.overlayBorderRadius?.topLeft ?? Radius.circular(2);

    final headerTopRightBorderRadius =
        widget.overlayBorderRadius?.topRight ?? Radius.circular(2);

    final header = Column(children: <Widget>[
      Material(
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: headerTopLeftBorderRadius,
              topRight: headerTopRightBorderRadius),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                color: theme.brightness == Brightness.light
                    ? Colors.black45
                    : null,
                icon: _iconBack,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _textField(context),
                ),
              ),
            ],
          )),
      Divider()
    ]);

    final bodyBottomLeftBorderRadius =
        widget.overlayBorderRadius?.bottomLeft ?? Radius.circular(2);

    final bodyBottomRightBorderRadius =
        widget.overlayBorderRadius?.bottomRight ?? Radius.circular(2);

    final container = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
      child: Stack(
        children: <Widget>[
          header,
          Padding(
            padding: EdgeInsets.only(top: 48.0),
            child: StreamBuilder<_SearchState>(
              stream: state$,
              initialData: state,
              builder: (context, snapshot) {
                final state = snapshot.requireData;

                if (state.isSearching) {
                  return Stack(
                    alignment: FractionalOffset.bottomCenter,
                    children: <Widget>[_Loader()],
                  );
                } else if (state.text.isEmpty ||
                    state.response == null ||
                    state.response!.predictions.isEmpty) {
                  return Material(
                    color: theme.dialogBackgroundColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: bodyBottomLeftBorderRadius,
                      bottomRight: bodyBottomRightBorderRadius,
                    ),
                    child: widget.logo ?? const PoweredByGoogleImage(),
                  );
                } else {
                  return SingleChildScrollView(
                    child: Material(
                      borderRadius: BorderRadius.only(
                        bottomLeft: bodyBottomLeftBorderRadius,
                        bottomRight: bodyBottomRightBorderRadius,
                      ),
                      color: theme.dialogBackgroundColor,
                      child: ListBody(
                        children: state.response?.predictions
                                .map(
                                  (p) => PredictionTile(
                                    prediction: p,
                                    onTap: Navigator.of(context).pop,
                                  ),
                                )
                                .toList(growable: false) ??
                            const [],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Padding(padding: EdgeInsets.only(top: 8.0), child: container);
    }
    return container;
  }

  Icon get _iconBack => Theme.of(context).platform == TargetPlatform.iOS
      ? Icon(Icons.arrow_back_ios)
      : Icon(Icons.arrow_back);

  Widget _textField(BuildContext context) => TextField(
        controller: _queryTextController,
        autofocus: true,
        style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black87
                : null,
            fontSize: 16.0),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black45
                : null,
            fontSize: 16.0,
          ),
          border: InputBorder.none,
        ),
      );
}

class _Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxHeight: 2.0),
        child: LinearProgressIndicator());
  }
}

class PlacesAutocompleteResult extends StatelessWidget {
  final ValueChanged<Prediction> onTap;
  final Widget? logo;

  PlacesAutocompleteResult({required this.onTap, required this.logo});

  @override
  Widget build(BuildContext context) {
    final state = PlacesAutocompleteWidget.of(context);

    return StreamBuilder<_SearchState>(
      stream: state.state$,
      initialData: state.state,
      builder: (context, snapshot) {
        final state = snapshot.requireData;

        if (state.text.isEmpty ||
            state.response == null ||
            state.response!.predictions.isEmpty) {
          final children = <Widget>[];
          if (state.isSearching) {
            children.add(_Loader());
          }
          children.add(logo ?? const PoweredByGoogleImage());
          return Stack(children: children);
        }
        return PredictionsListView(
          predictions: state.response?.predictions ?? const [],
          onTap: onTap,
        );
      },
    );
  }
}

class AppBarPlacesAutoCompleteTextField extends StatefulWidget {
  final InputDecoration? textDecoration;
  final TextStyle? textStyle;

  AppBarPlacesAutoCompleteTextField(
      {Key? key, required this.textDecoration, required this.textStyle})
      : super(key: key);

  @override
  _AppBarPlacesAutoCompleteTextFieldState createState() =>
      _AppBarPlacesAutoCompleteTextFieldState();
}

class _AppBarPlacesAutoCompleteTextFieldState
    extends State<AppBarPlacesAutoCompleteTextField> {
  @override
  Widget build(BuildContext context) {
    final state = PlacesAutocompleteWidget.of(context);

    return Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 4.0),
        child: TextField(
          controller: state._queryTextController,
          autofocus: true,
          style: widget.textStyle ?? _defaultStyle(),
          decoration:
              widget.textDecoration ?? _defaultDecoration(state.widget.hint),
        ));
  }

  InputDecoration _defaultDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white30
          : Colors.black38,
      hintStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black38
            : Colors.white30,
        fontSize: 16.0,
      ),
      border: InputBorder.none,
    );
  }

  TextStyle _defaultStyle() {
    return TextStyle(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black.withOpacity(0.9)
          : Colors.white.withOpacity(0.9),
      fontSize: 16.0,
    );
  }
}

class PoweredByGoogleImage extends StatelessWidget {
  final _poweredByGoogleWhite =
      'packages/flutter_google_places_hoc081098/assets/google_white.png';
  final _poweredByGoogleBlack =
      'packages/flutter_google_places_hoc081098/assets/google_black.png';

  const PoweredByGoogleImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Padding(
          padding: EdgeInsets.all(16.0),
          child: Image.asset(
            Theme.of(context).brightness == Brightness.light
                ? _poweredByGoogleWhite
                : _poweredByGoogleBlack,
            scale: 2.5,
          ))
    ]);
  }
}

class PredictionsListView extends StatelessWidget {
  final List<Prediction> predictions;
  final ValueChanged<Prediction> onTap;

  PredictionsListView({required this.predictions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: predictions
          .map((Prediction p) => PredictionTile(prediction: p, onTap: onTap))
          .toList(growable: false),
    );
  }
}

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  final ValueChanged<Prediction> onTap;

  PredictionTile({required this.prediction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(prediction.description ?? ''),
      onTap: () => onTap(prediction),
    );
  }
}

enum Mode { overlay, fullscreen }

abstract class PlacesAutocompleteState extends State<PlacesAutocompleteWidget> {
  late final TextEditingController _queryTextController =
      TextEditingController(text: widget.startText)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.startText?.length ?? 0,
        );

  GoogleMapsPlaces? _places;

  late final Stream<_SearchState> state$;
  var state = _SearchState(false, null, '');
  StreamSubscription<_SearchState>? subscription;

  @override
  void initState() {
    super.initState();

    _initPlaces();
    state$ = _queryTextController
        .toValueStream(replayValue: true)
        .map((event) => event.text)
        .debounceTime(widget.debounce ?? const Duration(milliseconds: 300))
        .where((s) => s.isNotEmpty && _places != null)
        .distinct()
        .switchMap(doSearch)
        .doOnData((event) => state = event)
        .share();
    subscription = state$.listen(null);
  }

  Future<void> _initPlaces() async {
    final headers = await GoogleApiHeaders().getHeaders();

    assert(() {
      debugPrint('[flutter_google_places_hoc081098] headers=$headers');
      return true;
    }());

    if (!mounted) {
      return;
    }
    _places = GoogleMapsPlaces(
      apiKey: widget.apiKey,
      baseUrl: widget.proxyBaseUrl,
      httpClient: widget.httpClient,
      apiHeaders: <String, String>{
        ...headers,
        ...?widget.headers,
      },
    );
  }

  Stream<_SearchState> doSearch(String value) async* {
    yield _SearchState(true, null, value);

    assert(() {
      debugPrint(
          '[flutter_google_places_hoc081098] input=$value location=${widget.location} origin=${widget.origin}');
      return true;
    }());

    try {
      final res = await _places!.autocomplete(
        value,
        offset: widget.offset,
        location: widget.location,
        radius: widget.radius,
        language: widget.language,
        sessionToken: widget.sessionToken,
        types: widget.types ?? const [],
        components: widget.components ?? const [],
        strictbounds: widget.strictbounds ?? false,
        region: widget.region,
        origin: widget.origin,
      );

      if (res.errorMessage?.isNotEmpty == true ||
          res.status == 'REQUEST_DENIED') {
        assert(() {
          debugPrint('[flutter_google_places_hoc081098] REQUEST_DENIED $res');
          return true;
        }());
        onResponseError(res);
      }

      yield _SearchState(
        false,
        PlacesAutocompleteResponse(
          status: res.status,
          errorMessage: res.errorMessage,
          predictions: _sorted(res.predictions),
        ),
        value,
      );
    } catch (e, s) {
      assert(() {
        debugPrint('[flutter_google_places_hoc081098] ERROR $e $s');
        return true;
      }());
      yield _SearchState(false, null, value);
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    subscription = null;
    _queryTextController.dispose();

    _places?.dispose();
    _places = null;

    super.dispose();
  }

  @mustCallSuper
  void onResponseError(PlacesAutocompleteResponse res) {
    if (!mounted) return;
    widget.onError?.call(res);
  }

  @mustCallSuper
  void onResponse(PlacesAutocompleteResponse res) {}

  static List<Prediction> _sorted(List<Prediction> predictions) {
    if (predictions.isEmpty ||
        predictions.every((e) => e.distanceMeters == null)) {
      return predictions;
    }

    final sorted = predictions.sortedBy<num>((e) => e.distanceMeters ?? 0);

    assert(() {
      debugPrint(
          '[flutter_google_places_hoc081098] sorted=${sorted.map((e) => e.distanceMeters).toList(growable: false)}');
      return true;
    }());

    return sorted;
  }
}

class _SearchState {
  final String text;
  final bool isSearching;
  final PlacesAutocompleteResponse? response;

  _SearchState(this.isSearching, this.response, this.text);

  @override
  String toString() =>
      '_SearchState{text: $text, isSearching: $isSearching, response: $response}';
}

class PlacesAutocomplete {
  static Future<Prediction?> show(
      {required BuildContext context,
      required String? apiKey,
      Mode mode = Mode.fullscreen,
      String? hint = 'Search',
      BorderRadius? overlayBorderRadius,
      num? offset,
      Location? location,
      num? radius,
      String? language,
      String? sessionToken,
      List<String>? types,
      List<Component>? components,
      bool? strictbounds,
      String? region,
      Widget? logo,
      ValueChanged<PlacesAutocompleteResponse>? onError,
      String? proxyBaseUrl,
      Client? httpClient,
      String? startText,
      Duration? debounce,
      Location? origin}) {
    final builder = (BuildContext context) => PlacesAutocompleteWidget(
          apiKey: apiKey,
          mode: mode,
          overlayBorderRadius: overlayBorderRadius,
          language: language,
          sessionToken: sessionToken,
          components: components,
          types: types,
          location: location,
          radius: radius,
          strictbounds: strictbounds,
          region: region,
          offset: offset,
          hint: hint,
          logo: logo,
          onError: onError,
          proxyBaseUrl: proxyBaseUrl,
          httpClient: httpClient,
          startText: startText,
          debounce: debounce,
          origin: origin,
        );

    if (mode == Mode.overlay) {
      return showDialog<Prediction>(context: context, builder: builder);
    }
    return Navigator.push<Prediction>(
        context, MaterialPageRoute(builder: builder));
  }
}
