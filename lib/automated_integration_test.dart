library automated_integration_test;

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
///
/// This class handles:
/// * Recording UI interactions
/// * Managing test sessions
/// * Generating integration tests
///
/// To use this class:
/// 1. Initialize it in your main() function
/// 2. Wrap your MaterialApp with wrapApp()
/// 3. Run your app in development mode
/// 4. Tests will be generated automatically
class AutoTestRecorder with WidgetsBindingObserver {
  static AutoTestRecorder? _instance;

  /// Gets the singleton instance of AutoTestRecorder.
  ///
  /// Make sure to call [initialize] before accessing this.
  ///
  /// Throws a [StateError] if accessed before initialization.
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
  bool _hasRecordedInteractions = false;

  AutoTestRecorder._();

  /// Initializes the AutoTestRecorder.
  ///
  /// This should be called early in your app's lifecycle, typically in main().
  /// The recorder will automatically start recording in development mode.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await AutoTestRecorder.initialize();
  ///   runApp(const MyApp());
  /// }
  /// ```
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

    _isDevelopmentMode = !const bool.fromEnvironment('dart.vm.product');

    if (_isDevelopmentMode) {
      _widgetObserver.startRecording();
      WidgetsBinding.instance.addObserver(this);
      WidgetsBinding.instance.addObserver(_widgetObserver);
    }
  }

  /// Wraps your app with recording capabilities.
  ///
  /// This method should be used at the root of your app to enable:
  /// * Navigation tracking
  /// * Button tap recording
  /// * Text input recording
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return AutoTestRecorder.instance.wrapApp(
  ///     MaterialApp(home: MyHomePage()),
  ///   );
  /// }
  /// ```
  ///
  /// The recording only happens in development mode.
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      stopRecording();
    }
  }

  /// Stops recording and saves the current session.
  ///
  /// This is automatically called when the app is paused or closed.
  /// The session data is saved to a JSON file in the app's documents directory.
  Future<void> stopRecording() async {
    if (!_isDevelopmentMode || _currentSessionPath == null) return;

    _widgetObserver.stopRecording();
    WidgetsBinding.instance.removeObserver(_widgetObserver);

    final interactions = _interactionRecorder.getRecordedInteractions();
    final navigation = _navigationTracker.getNavigationHistory();
    final inputs = _inputHandler.getInputHistory();

    // Only generate test if there were interactions
    if (interactions.isNotEmpty || navigation.isNotEmpty || inputs.isNotEmpty) {
      _hasRecordedInteractions = true;

      final sessionData = {
        'sessionId': _currentSessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'interactions': interactions,
        'navigation': navigation,
        'inputs': inputs,
      };

      await _testGenerator.saveSession(sessionData, _currentSessionPath!);
      await _testGenerator.generateTest(_currentSessionPath!);
    }
  }

  /// Generates a test file from the current session.
  ///
  /// Returns the generated test code as a string.
  /// The test file is saved in the test/integration directory.
  Future<String> generateTest() async {
    if (!_isDevelopmentMode ||
        _currentSessionPath == null ||
        !_hasRecordedInteractions) return '';
    return await _testGenerator.generateTest(_currentSessionPath!);
  }

  /// Disposes the recorder and generates tests if needed.
  void dispose() {
    if (_isDevelopmentMode) {
      stopRecording();
      WidgetsBinding.instance.removeObserver(this);
    }
  }
}
