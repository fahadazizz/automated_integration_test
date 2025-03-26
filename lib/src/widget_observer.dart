import 'package:flutter/material.dart';
import 'interaction_recorder.dart';
import 'input_handler.dart';

/// A widget observer that automatically wraps interactive widgets with recording capabilities.
class RecordingWidgetObserver extends WidgetsBindingObserver {
  final InteractionRecorder _interactionRecorder;
  final InputHandler _inputHandler;
  bool _isRecording = false;

  RecordingWidgetObserver({
    required InteractionRecorder interactionRecorder,
    required InputHandler inputHandler,
  }) : _interactionRecorder = interactionRecorder,
       _inputHandler = inputHandler;

  void startRecording() {
    _isRecording = true;
  }

  void stopRecording() {
    _isRecording = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startRecording();
    } else if (state == AppLifecycleState.paused) {
      stopRecording();
    }
  }

  /// Wraps a widget with recording capabilities if it's an interactive widget.
  Widget wrapWidget(Widget widget) {
    if (!_isRecording) return widget;

    if (widget is MaterialButton ||
        widget is TextButton ||
        widget is ElevatedButton) {
      return _interactionRecorder.wrapWithRecorder(widget);
    } else if (widget is TextField || widget is TextFormField) {
      return _inputHandler.wrapWithInputHandler(widget);
    }
    return widget;
  }
}
