import 'package:flutter/material.dart';
import 'navigation_tracker.dart';

/// A widget that wraps its child with navigation tracking capabilities.
class RecordingNavigator extends StatelessWidget {
  final NavigationTracker _tracker;
  final Widget child;

  const RecordingNavigator({
    required NavigationTracker tracker,
    required this.child,
    Key? key,
  }) : _tracker = tracker,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [_tracker],
      onGenerateRoute:
          (settings) => MaterialPageRoute(builder: (context) => child),
    );
  }
}
