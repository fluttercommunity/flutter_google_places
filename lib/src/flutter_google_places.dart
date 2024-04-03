library flutter_google_places.src;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';

class PlacesAutocompleteWidget extends StatefulWidget {
  final String apiKey;
  final String? startText;
  final String hint;
  final BorderRadius? overlayBorderRadius;
  final Location? location;
  final num? offset;
  final num? radius;
  final String? language;
  final String? sessionToken;
  final List<String>? types;
  final List<Component>? components;
  final bool? strictbounds;
  final String? region;
  final Mode mode;
  final Widget? logo;
  final ValueChanged<PlacesAutocompleteResponse>? onError;
  final int debounce;
  final InputDecoration? decoration;
  final TextStyle? textStyle;
  final ThemeData? themeData;

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
  final BaseClient? httpClient;

  /// optional - set 'resultTextStyle' value in google_maps_webservice
  ///
  /// In case of changing the default text style of result's text
  final TextStyle? resultTextStyle;

  const PlacesAutocompleteWidget({
    required this.apiKey,
    this.mode = Mode.fullscreen,
    this.hint = "Search",
    this.overlayBorderRadius,
    this.offset,
    this.location,
    this.radius,
    this.language,
    this.sessionToken,
    this.types,
    this.components,
    this.strictbounds,
    this.region,
    this.logo,
    this.onError,
    Key? key,
    this.proxyBaseUrl,
    this.httpClient,
    this.startText,
    this.debounce = 300,
    this.decoration,
    this.textStyle,
    this.themeData,
    this.resultTextStyle,
  }) : super(key: key);

  @override
  State<PlacesAutocompleteWidget> createState() =>
      _PlacesAutocompleteOverlayState();

  static PlacesAutocompleteState? of(BuildContext context) =>
      context.findAncestorStateOfType<PlacesAutocompleteState>();
}

class _PlacesAutocompleteOverlayState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final theme = widget.themeData ?? Theme.of(context);
    if (widget.mode == Mode.fullscreen) {
      return Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
            title: AppBarPlacesAutoCompleteTextField(
              textDecoration: widget.decoration,
              textStyle: widget.textStyle,
            ),
          ),
          body: PlacesAutocompleteResult(
            onTap: Navigator.of(context).pop,
            logo: widget.logo,
            resultTextStyle: widget.resultTextStyle,
          ),
        ),
      );
    } else {
      final headerTopLeftBorderRadius = widget.overlayBorderRadius != null
          ? widget.overlayBorderRadius!.topLeft
          : const Radius.circular(2);

      final headerTopRightBorderRadius = widget.overlayBorderRadius != null
          ? widget.overlayBorderRadius!.topRight
          : const Radius.circular(2);

      final header = Column(
        children: <Widget>[
          Material(
            color: theme.dialogBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: headerTopLeftBorderRadius,
              topRight: headerTopRightBorderRadius,
            ),
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
            ),
          ),
          const Divider()
        ],
      );

      Widget body;

      final bodyBottomLeftBorderRadius = widget.overlayBorderRadius != null
          ? widget.overlayBorderRadius!.bottomLeft
          : const Radius.circular(2);

      final bodyBottomRightBorderRadius = widget.overlayBorderRadius != null
          ? widget.overlayBorderRadius!.bottomRight
          : const Radius.circular(2);

      if (_searching) {
        body = Stack(
          alignment: FractionalOffset.bottomCenter,
          children: <Widget>[_Loader()],
        );
      } else if (_queryTextController!.text.isEmpty ||
          _response == null ||
          _response!.predictions.isEmpty) {
        body = Material(
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.only(
            bottomLeft: bodyBottomLeftBorderRadius,
            bottomRight: bodyBottomRightBorderRadius,
          ),
          child: widget.logo ?? const PoweredByGoogleImage(),
        );
      } else {
        body = SingleChildScrollView(
          child: Material(
            borderRadius: BorderRadius.only(
              bottomLeft: bodyBottomLeftBorderRadius,
              bottomRight: bodyBottomRightBorderRadius,
            ),
            color: theme.dialogBackgroundColor,
            child: ListBody(
              children: _response!.predictions
                  .map(
                    (p) => PredictionTile(
                      prediction: p,
                      onTap: Navigator.of(context).pop,
                      resultTextStyle: widget.resultTextStyle,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      }

      final container = Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: Stack(
          children: <Widget>[
            header,
            Padding(padding: const EdgeInsets.only(top: 48.0), child: body),
          ],
        ),
      );

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: container,
        );
      }
      return container;
    }
  }

  Icon get _iconBack => Theme.of(context).platform == TargetPlatform.iOS
      ? const Icon(Icons.arrow_back_ios)
      : const Icon(Icons.arrow_back);

  Widget _textField(BuildContext context) => TextField(
        controller: _queryTextController,
        autofocus: true,
        style: widget.textStyle ??
            TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black87
                  : null,
              fontSize: 16.0,
            ),
        decoration: widget.decoration ??
            InputDecoration(
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
      constraints: const BoxConstraints(maxHeight: 2.0),
      child: const LinearProgressIndicator(),
    );
  }
}

class PlacesAutocompleteResult extends StatefulWidget {
  final ValueChanged<Prediction>? onTap;
  final Widget? logo;
  final TextStyle? resultTextStyle;

  const PlacesAutocompleteResult({
    Key? key,
    this.onTap,
    this.logo,
    this.resultTextStyle,
  }) : super(key: key);

  @override
  PlacesAutocompleteResultState createState() =>
      PlacesAutocompleteResultState();
}

class PlacesAutocompleteResultState extends State<PlacesAutocompleteResult> {
  @override
  Widget build(BuildContext context) {
    final state = PlacesAutocompleteWidget.of(context)!;

    if (state._queryTextController!.text.isEmpty ||
        state._response == null ||
        state._response!.predictions.isEmpty) {
      final children = <Widget>[];
      if (state._searching) {
        children.add(_Loader());
      }
      children.add(widget.logo ?? const PoweredByGoogleImage());
      return Stack(children: children);
    }
    return PredictionsListView(
      predictions: state._response!.predictions,
      onTap: widget.onTap,
      resultTextStyle: widget.resultTextStyle,
    );
  }
}

class AppBarPlacesAutoCompleteTextField extends StatefulWidget {
  final InputDecoration? textDecoration;
  final TextStyle? textStyle;

  const AppBarPlacesAutoCompleteTextField({
    Key? key,
    this.textDecoration,
    this.textStyle,
  }) : super(key: key);

  @override
  AppBarPlacesAutoCompleteTextFieldState createState() =>
      AppBarPlacesAutoCompleteTextFieldState();
}

class AppBarPlacesAutoCompleteTextFieldState
    extends State<AppBarPlacesAutoCompleteTextField> {
  @override
  Widget build(BuildContext context) {
    final state = PlacesAutocompleteWidget.of(context)!;

    return Container(
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(top: 4.0),
      child: TextField(
        controller: state._queryTextController,
        autofocus: true,
        style: widget.textStyle ?? _defaultStyle(),
        decoration:
            widget.textDecoration ?? _defaultDecoration(state.widget.hint),
      ),
    );
  }

  InputDecoration _defaultDecoration(String hint) {
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
  static const _poweredByGoogleWhite =
      "packages/flutter_google_places/assets/google_white.png";
  static const _poweredByGoogleBlack =
      "packages/flutter_google_places/assets/google_black.png";

  const PoweredByGoogleImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            Theme.of(context).brightness == Brightness.light
                ? _poweredByGoogleWhite
                : _poweredByGoogleBlack,
            scale: 2.5,
          ),
        )
      ],
    );
  }
}

class PredictionsListView extends StatelessWidget {
  final List<Prediction> predictions;
  final ValueChanged<Prediction>? onTap;
  final TextStyle? resultTextStyle;

  const PredictionsListView({
    Key? key,
    required this.predictions,
    this.onTap,
    this.resultTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: predictions
          .map(
            (Prediction p) => PredictionTile(
              prediction: p,
              onTap: onTap,
              resultTextStyle: resultTextStyle,
            ),
          )
          .toList(),
    );
  }
}

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  final ValueChanged<Prediction>? onTap;
  final TextStyle? resultTextStyle;

  const PredictionTile({
    Key? key,
    required this.prediction,
    this.onTap,
    this.resultTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(
        prediction.description!,
        style: resultTextStyle ?? Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () {
        onTap?.call(prediction);
      },
    );
  }
}

enum Mode { overlay, fullscreen }

abstract class PlacesAutocompleteState extends State<PlacesAutocompleteWidget> {
  TextEditingController? _queryTextController;
  PlacesAutocompleteResponse? _response;
  GoogleMapsPlaces? _places;
  late bool _searching;
  Timer? _debounce;

  final _queryBehavior = BehaviorSubject<String>.seeded('');

  @override
  void initState() {
    super.initState();

    _queryTextController = TextEditingController(text: widget.startText);
    _queryTextController!.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.startText?.length ?? 0,
    );

    _initPlaces();
    _searching = false;

    _queryTextController!.addListener(_onQueryChange);

    _queryBehavior.stream.listen(doSearch);
  }

  Future<void> _initPlaces() async {
    _places = GoogleMapsPlaces(
      apiKey: widget.apiKey,
      baseUrl: widget.proxyBaseUrl,
      httpClient: widget.httpClient,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
  }

  Future<void> doSearch(String value) async {
    if (mounted && value.isNotEmpty && _places != null) {
      setState(() {
        _searching = true;
      });

      final res = await _places!.autocomplete(
        value,
        offset: widget.offset,
        location: widget.location,
        radius: widget.radius,
        language: widget.language,
        sessionToken: widget.sessionToken,
        types: widget.types ?? [],
        components: widget.components ?? [],
        strictbounds: widget.strictbounds ?? false,
        region: widget.region,
      );

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

  void _onQueryChange() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounce), () {
      if (!_queryBehavior.isClosed) {
        _queryBehavior.add(_queryTextController!.text);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _places?.dispose();
    _debounce?.cancel();
    _queryBehavior.close();
    _queryTextController?.removeListener(_onQueryChange);
  }

  @mustCallSuper
  void onResponseError(PlacesAutocompleteResponse res) {
    if (!mounted) return;

    widget.onError?.call(res);
    setState(() {
      _response = null;
      _searching = false;
    });
  }

  @mustCallSuper
  void onResponse(PlacesAutocompleteResponse? res) {
    if (!mounted) return;

    setState(() {
      _response = res;
      _searching = false;
    });
  }
}

class PlacesAutocomplete {
  static Future<Prediction?> show({
    required BuildContext context,
    required String apiKey,
    Mode mode = Mode.fullscreen,
    String hint = "Search",
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
    InputDecoration? decoration,
    String startText = "",
    Duration transitionDuration = const Duration(seconds: 300),
    TextStyle? textStyle,
    ThemeData? themeData,
    TextStyle? resultTextStyle,
  }) {
    final autoCompleteWidget = PlacesAutocompleteWidget(
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
      httpClient: httpClient as BaseClient?,
      startText: startText,
      decoration: decoration,
      textStyle: textStyle,
      themeData: themeData,
      resultTextStyle: resultTextStyle,
    );

    if (mode == Mode.overlay) {
      return showDialog(
        context: context,
        builder: (BuildContext ctx) => autoCompleteWidget,
      );
    } else {
      return Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => autoCompleteWidget,
          transitionDuration: transitionDuration,
        ),
      );
    }
  }
}
