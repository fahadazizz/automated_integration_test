import 'package:flutter/material.dart';

/// Records user interactions with the app, particularly button taps.
class InteractionRecorder {
  final List<Map<String, dynamic>> _recordedInteractions = [];

  void recordInteraction({
    required String type,
    required String widgetType,
    String? text,
    Map<String, dynamic>? additionalData,
  }) {
    _recordedInteractions.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      'widgetType': widgetType,
      'text': text,
      if (additionalData != null) ...additionalData,
    });
  }

  List<Map<String, dynamic>> getRecordedInteractions() => _recordedInteractions;

  /// Wraps a widget with interaction recording capabilities.
  Widget wrapWithRecorder(Widget child) {
    if (child is MaterialButton) {
      return GestureDetector(
        onTapDown: (_) {
          recordInteraction(
            type: 'tap',
            widgetType: 'MaterialButton',
            text: child.child is Text ? (child.child as Text).data : null,
          );
        },
        child: child,
      );
    } else if (child is TextButton) {
      return GestureDetector(
        onTapDown: (_) {
          recordInteraction(
            type: 'tap',
            widgetType: 'TextButton',
            text: child.child is Text ? (child.child as Text).data : null,
          );
        },
        child: child,
      );
    } else if (child is ElevatedButton) {
      return GestureDetector(
        onTapDown: (_) {
          recordInteraction(
            type: 'tap',
            widgetType: 'ElevatedButton',
            text: child.child is Text ? (child.child as Text).data : null,
          );
        },
        child: child,
      );
    }
    return child;
  }
}
