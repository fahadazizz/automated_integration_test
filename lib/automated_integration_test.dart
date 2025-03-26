import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'src/interaction_recorder.dart';
import 'src/navigation_tracker.dart';
import 'src/input_handler.dart';
import 'src/test_generator.dart';
import 'src/recording_navigator.dart';
import 'src/widget_observer.dart';

/// The main class for automated integration testing.
class AutoTestRecorder {
  static AutoTestRecorder? _instance;

  /// Gets the singleton instance of AutoTestRecorder.
  /// Make sure to call [initialize] before accessing this.
  static AutoTestRecorder get instance {
    if (_instance == null) {
      throw StateError(
        'AutoTestRecorder has not been initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  final _uuid = const Uuid();
  final _dateFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');

  late final InteractionRecorder _interactionRecorder;
  late final NavigationTracker _navigationTracker;
  late final InputHandler _inputHandler;
  late final TestGenerator _testGenerator;
  late final RecordingWidgetObserver _widgetObserver;

  String? _currentSessionId;
  String? _currentSessionPath;
  bool _isDevelopmentMode = false;

  AutoTestRecorder._();

  /// Initializes the AutoTestRecorder.
  /// This should be called early in your app's lifecycle, typically in main().
  static Future<void> initialize() async {
    if (_instance != null) return;

    _instance = AutoTestRecorder._();
    await _instance!._initialize();
  }

  Future<void> _initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _currentSessionId = _uuid.v4();
    _currentSessionPath =
        '${appDir.path}/test_sessions/${_dateFormat.format(DateTime.now())}_${_currentSessionId}.json';

    _interactionRecorder = InteractionRecorder();
    _navigationTracker = NavigationTracker();
    _inputHandler = InputHandler();
    _testGenerator = TestGenerator();
    _widgetObserver = RecordingWidgetObserver(
      interactionRecorder: _interactionRecorder,
      inputHandler: _inputHandler,
    );

    // Check if we're in development mode
    _isDevelopmentMode = !const bool.fromEnvironment('dart.vm.product');

    if (_isDevelopmentMode) {
      // Start recording automatically in development mode
      _widgetObserver.startRecording();
      WidgetsBinding.instance.addObserver(_widgetObserver);
    }
  }

  /// Wraps a widget with recording capabilities.
  /// This should be used at the root of your app to enable navigation tracking.
  Widget wrapApp(Widget child) {
    if (!_isDevelopmentMode) return child;

    return RecordingNavigator(
      tracker: _navigationTracker,
      child: Builder(
        builder: (context) {
          return _widgetObserver.wrapWidget(child);
        },
      ),
    );
  }

  /// Stops recording and saves the current session.
  Future<void> stopRecording() async {
    if (!_isDevelopmentMode || _currentSessionPath == null) return;

    _widgetObserver.stopRecording();
    WidgetsBinding.instance.removeObserver(_widgetObserver);

    final sessionData = {
      'sessionId': _currentSessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'interactions': _interactionRecorder.getRecordedInteractions(),
      'navigation': _navigationTracker.getNavigationHistory(),
      'inputs': _inputHandler.getInputHistory(),
    };

    await _testGenerator.saveSession(sessionData, _currentSessionPath!);
  }

  /// Generates a test file from the current session.
  Future<String> generateTest() async {
    if (!_isDevelopmentMode || _currentSessionPath == null) return '';
    return await _testGenerator.generateTest(_currentSessionPath!);
  }
}
