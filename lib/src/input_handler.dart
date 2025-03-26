import 'package:flutter/material.dart';

/// Monitors text input changes in the app.
class InputHandler {
  final List<Map<String, dynamic>> _inputHistory = [];
  final Map<TextEditingController, String> _controllerStates = {};

  void initialize(BuildContext context) {
    // We'll need to wrap TextField widgets with our custom wrapper
    // This will be done through the AutoTestRecorder's widget tree modification
  }

  void recordInput({required String controllerId, required String value}) {
    _inputHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'input',
      'controllerId': controllerId,
      'value': value,
    });
  }

  List<Map<String, dynamic>> getInputHistory() => _inputHistory;

  /// Wraps a TextField or TextFormField with input monitoring capabilities.
  Widget wrapWithInputHandler(Widget child) {
    if (child is TextField) {
      return _wrapTextField(child);
    } else if (child is TextFormField) {
      return _wrapTextFormField(child);
    }
    return child;
  }

  Widget _wrapTextField(TextField textField) {
    final controller = textField.controller ?? TextEditingController();
    final id = controller.hashCode.toString();

    if (!_controllerStates.containsKey(controller)) {
      _controllerStates[controller] = controller.text;
      controller.addListener(() {
        if (_controllerStates[controller] != controller.text) {
          _controllerStates[controller] = controller.text;
          recordInput(controllerId: id, value: controller.text);
        }
      });
    }

    return TextField(
      controller: controller,
      decoration: textField.decoration,
      style: textField.style,
      textAlign: textField.textAlign,
      textDirection: textField.textDirection,
      readOnly: textField.readOnly,
      showCursor: textField.showCursor,
      expands: textField.expands,
      maxLines: textField.maxLines,
      minLines: textField.minLines,
      maxLength: textField.maxLength,
      maxLengthEnforcement: textField.maxLengthEnforcement,
      obscureText: textField.obscureText,
      obscuringCharacter: textField.obscuringCharacter,
      keyboardType: textField.keyboardType,
      textInputAction: textField.textInputAction,
      textCapitalization: textField.textCapitalization,
      onChanged: textField.onChanged,
      onEditingComplete: textField.onEditingComplete,
      onSubmitted: textField.onSubmitted,
      onAppPrivateCommand: textField.onAppPrivateCommand,
      inputFormatters: textField.inputFormatters,
      enabled: textField.enabled,
      cursorWidth: textField.cursorWidth,
      cursorHeight: textField.cursorHeight,
      cursorRadius: textField.cursorRadius,
      cursorColor: textField.cursorColor,
      selectionHeightStyle: textField.selectionHeightStyle,
      selectionWidthStyle: textField.selectionWidthStyle,
      keyboardAppearance: textField.keyboardAppearance,
      scrollPadding: textField.scrollPadding,
      dragStartBehavior: textField.dragStartBehavior,
      enableInteractiveSelection: textField.enableInteractiveSelection,
      selectionControls: textField.selectionControls,
      mouseCursor: textField.mouseCursor,
      buildCounter: textField.buildCounter,
      scrollController: textField.scrollController,
      scrollPhysics: textField.scrollPhysics,
      autofocus: textField.autofocus,
      clipBehavior: textField.clipBehavior,
      restorationId: textField.restorationId,
    );
  }

  Widget _wrapTextFormField(TextFormField textFormField) {
    final controller = textFormField.controller ?? TextEditingController();
    final id = controller.hashCode.toString();

    if (!_controllerStates.containsKey(controller)) {
      _controllerStates[controller] = controller.text;
      controller.addListener(() {
        if (_controllerStates[controller] != controller.text) {
          _controllerStates[controller] = controller.text;
          recordInput(controllerId: id, value: controller.text);
        }
      });
    }

    return TextFormField(
      controller: controller,
      onChanged: textFormField.onChanged,
      onSaved: textFormField.onSaved,
      validator: textFormField.validator,
      autovalidateMode: textFormField.autovalidateMode,
      enabled: textFormField.enabled,
      restorationId: textFormField.restorationId,
    );
  }
}
