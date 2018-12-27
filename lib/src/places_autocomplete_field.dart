import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

import 'flutter_google_places.dart';

/// A text field like widget to input places with autocomplete.
///
/// The autocomplete field calls [onChanged] with the new address line
/// whenever the user input a new location.
///
/// To control the text that is displayed in the text field, use the
/// [controller]. For example, to set the initial value of the text field, use
/// a [controller] that already contains some text.
///
/// By default, an autocomplete field has a [decoration] that draws a divider
/// below the field. You can use the [decoration] property to control the
/// decoration, for example by adding a label or an icon. If you set the [decoration]
/// property to null, the decoration will be removed entirely, including the
/// extra padding introduced by the decoration to save space for the labels.
/// If you want the icon to be outside the input field use [decoration.icon].
/// If it should be inside the field use [leading].
///
/// To integrate the [PlacesAutocompleteField] into a [Form] with other [FormField]
/// widgets, consider using [PlacesAutocompleteFormField].
///
/// See also:
///
///  * [PlacesAutocompleteFormField], which integrates with the [Form] widget.
///  * [InputDecorator], which shows the labels and other visual elements that
///    surround the actual text editing widget.
class PlacesAutocompleteField extends StatefulWidget {
  /// Creates a text field like widget.
  ///
  /// To remove the decoration entirely (including the extra padding introduced
  /// by the decoration to save space for the labels), set the [decoration] to
  /// null.
  const PlacesAutocompleteField({
    Key key,
    @required this.apiKey,
    this.controller,
    this.leading,
    this.hint = "Search",
    this.trailing,
    this.trailingOnTap,
    this.mode = Mode.fullscreen,
    this.offset,
    this.location,
    this.radius,
    this.language,
    this.sessionToken,
    this.types,
    this.components,
    this.strictbounds,
    this.onChanged,
    this.onError,
    this.inputDecoration = const InputDecoration(),
  }) : super(key: key);

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController controller;

  /// Icon shown inside the field left to the text.
  final Icon leading;

  /// Icon shown inside the field right to the text.
  final Icon trailing;

  /// Callback when [trailing] is tapped on.
  final VoidCallback trailingOnTap;

  /// Text that is shown, when no input was done, yet.
  final String hint;

  /// Your Google Maps Places API Key.
  ///
  /// For this key the Places Web API needs to be activated. For further
  /// information on how to do this, see their official documentation below.
  ///
  /// See also:
  ///
  /// * <https://developers.google.com/places/web-service/autocomplete>
  final String apiKey;

  /// The decoration to show around the text field.
  ///
  /// By default, draws a horizontal line under the autocomplete field but can be
  /// configured to show an icon, label, hint text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration inputDecoration;

  /// The position, in the input term, of the last character that the service
  /// uses to match predictions.
  ///
  /// For example, if the input is 'Google' and the
  /// offset is 3, the service will match on 'Goo'. The string determined by the
  /// offset is matched against the first word in the input term only. For
  /// example, if the input term is 'Google abc' and the offset is 3, the service
  /// will attempt to match against 'Goo abc'. If no offset is supplied, the
  /// service will use the whole term. The offset should generally be set to the
  /// position of the text caret.
  ///
  /// Source: https://developers.google.com/places/web-service/autocomplete
  final num offset;

  final Mode mode;

  final String language;

  final String sessionToken;

  final List<String> types;

  final List<Component> components;

  final Location location;

  final num radius;

  final bool strictbounds;

  /// Called when the text being edited changes.
  final ValueChanged<String> onChanged;

  /// Callback when autocomplete has error.
  final ValueChanged<PlacesAutocompleteResponse> onError;

  @override
  _LocationAutocompleteFieldState createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<PlacesAutocompleteField> {
  TextEditingController _controller;
  TextEditingController get _effectiveController =>
      widget.controller ?? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(PlacesAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null)
      _controller = TextEditingController.fromValue(oldWidget.controller.value);
    else if (widget.controller != null && oldWidget.controller == null)
      _controller = null;
  }

  Future<Prediction> _showAutocomplete() async => PlacesAutocomplete.show(
        context: context,
        apiKey: widget.apiKey,
        offset: widget.offset,
        onError: widget.onError,
        mode: widget.mode,
        hint: widget.hint,
        language: widget.language,
        sessionToken: widget.sessionToken,
        components: widget.components,
        location: widget.location,
        radius: widget.radius,
        types: widget.types,
        strictbounds: widget.strictbounds,
      );

  void _handleTap() async {
    Prediction p = await _showAutocomplete();

    if (p == null) return;

    setState(() {
      _effectiveController.text = p.description;
      if (widget.onChanged != null) {
        widget.onChanged(p.description);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = _effectiveController;

    var text = controller.text.isNotEmpty
        ? Text(
            controller.text,
            softWrap: true,
          )
        : Text(
            widget.hint ?? '',
            style: TextStyle(color: Colors.black38),
          );

    Widget child = Row(
      children: <Widget>[
        widget.leading ?? SizedBox(),
        SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: text,
        ),
        widget.trailing != null
            ? GestureDetector(
                onTap: widget.trailingOnTap,
                child: widget.trailingOnTap != null
                    ? widget.trailing
                    : Icon(
                        widget.trailing.icon,
                        color: Colors.grey,
                      ),
              )
            : SizedBox()
      ],
    );

    if (widget.inputDecoration != null) {
      child = InputDecorator(
        decoration: widget.inputDecoration,
        child: child,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: child,
    );
  }
}
