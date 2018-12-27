import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

import 'flutter_google_places.dart';
import 'places_autocomplete_field.dart';

/// A [FormField] that contains a [PlacesAutocompleteField].
///
/// This is a convenience widget that wraps a [PlacesAutocompleteField] widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
///
/// When a [controller] is specified, its [TextEditingController.text]
/// defines the [initialValue]. If this [FormField] is part of a scrolling
/// container that lazily constructs its children, like a [ListView] or a
/// [CustomScrollView], then a [controller] should be specified.
/// The controller's lifetime should be managed by a stateful widget ancestor
/// of the scrolling container.
///
/// If a [controller] is not specified, [initialValue] can be used to give
/// the automatically generated controller an initial value.
///
/// For a documentation about the various parameters, see [PlacesAutocompleteField].
///
/// See also:
///
///  * [PlacesAutocompleteField], which is the underlying widget without the [Form]
///    integration.
///  * [InputDecorator], which shows the labels and other visual elements that
///    surround the actual text editing widget.
class PlacesAutocompleteFormField extends FormField<String> {
  /// Creates a [FormField] that contains a [PlacesAutocompleteField].
  ///
  /// When a [controller] is specified, [initialValue] must be null (the
  /// default). If [controller] is null, then a [TextEditingController]
  /// will be constructed automatically and its `text` will be initialized
  /// to [initalValue] or the empty string.
  ///
  /// For documentation about the various parameters, see the [PlacesAutocompleteField] class
  /// and [new PlacesAutocompleteField], the constructor.
  PlacesAutocompleteFormField({
    Key key,
    @required String apiKey,
    this.controller,
    Icon leading,
    String initialValue,
    String hint = "Search",
    Icon trailing,
    VoidCallback trailingOnTap,
    Mode mode = Mode.fullscreen,
    num offset,
    Location location,
    num radius,
    String language,
    String sessionToken,
    List<String> types,
    List<Component> components,
    bool strictbounds,
    ValueChanged<PlacesAutocompleteResponse> onError,
    InputDecoration inputDecoration = const InputDecoration(),
    bool autovalidate = false,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })  : assert(initialValue == null || controller == null),
        super(
          key: key,
          initialValue:
              controller != null ? controller.text : (initialValue ?? ''),
          onSaved: onSaved,
          validator: validator,
          autovalidate: autovalidate,
          builder: (FormFieldState<String> field) {
            final _TextFormFieldState state = field;
            final InputDecoration effectiveDecoration = inputDecoration
                ?.applyDefaults(Theme.of(state.context).inputDecorationTheme);
            return PlacesAutocompleteField(
              key: key,
              inputDecoration:
                  effectiveDecoration?.copyWith(errorText: state.errorText),
              controller: state._effectiveController,
              apiKey: apiKey,
              leading: leading,
              trailing: trailing,
              offset: offset,
              trailingOnTap: trailingOnTap,
              hint: hint,
              location: location,
              radius: radius,
              components: components,
              language: language,
              sessionToken: sessionToken,
              types: types,
              mode: mode,
              strictbounds: strictbounds,
              onChanged: state.didChange,
              onError: onError,
            );
          },
        );

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [initialValue].
  final TextEditingController controller;

  @override
  _TextFormFieldState createState() => _TextFormFieldState();
}

class _TextFormFieldState extends FormFieldState<String> {
  TextEditingController _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller;

  @override
  PlacesAutocompleteFormField get widget => super.widget;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(PlacesAutocompleteFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null)
        _controller =
            TextEditingController.fromValue(oldWidget.controller.value);
      if (widget.controller != null) {
        setValue(widget.controller.text);
        if (oldWidget.controller == null) _controller = null;
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController.text = widget.initialValue;
    });
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value)
      didChange(_effectiveController.text);
  }
}
