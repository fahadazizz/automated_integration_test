# Automated Integration Test

A zero-config Flutter package that automatically records UI interactions (button taps, navigation, text input) and generates executable integration tests during development.

## Features

- **Automatic Recording**
  - Automatically captures button taps (MaterialButton, TextButton, ElevatedButton)
  - Tracks screen navigation (routes/push/pop)
  - Logs text input (TextField/TextFormField)
  - Only active during development mode

- **Zero Configuration**
  - No manual widget wrapping required
  - Single-line initialization
  - Automatic test generation
  - Automatic recording start/stop based on app lifecycle

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  automated_integration_test: ^1.0.2
```

## Quick Start Guide

1. **Add the Package**
   Add the package to your app's `pubspec.yaml`:
   ```yaml
   dependencies:
     automated_integration_test: ^1.0.2
   ```

2. **Update Android NDK Version**
   In your app's `android/app/build.gradle`, add:
   ```gradle
   android {
       ...
       ndkVersion "27.0.12077973"
       ...
   }
   ```

3. **Initialize the Recorder**
   In your `main.dart`, initialize the recorder early in the app lifecycle:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Initialize the recorder
     await AutoTestRecorder.initialize();
     
     runApp(const MyApp());
   }
   ```

4. **Wrap Your App**
   Wrap your app content with the recorder:
   ```dart
   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         title: 'Your App',
         theme: ThemeData(primarySwatch: Colors.blue),
         // Wrap your home screen with AutoTestRecorder
         home: AutoTestRecorder.instance.wrapApp(const YourHomeScreen()),
       );
     }
   }
   ```

5. **Run Your App**
   Run your app in development mode:
   ```bash
   flutter run
   ```

6. **Check Generated Tests**
   After running your app, check the generated tests in:
   ```
   test/integration/YYYY-MM-DD_HH-mm-ss_[session-id]_test.dart
   ```

## Generated Tests

The package automatically generates integration tests based on your interactions. Here's an example of what a generated test might look like:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generated Integration Test', (WidgetTester tester) async {
    // Enter text in the name field
    await tester.enterText(find.byType(TextField), 'John Doe');
    await tester.pumpAndSettle();
    
    // Tap the navigation button
    await tester.tap(find.text('Go to Next Screen'));
    await tester.pumpAndSettle();
  });
}
```

## Development Mode

The package only records interactions when running in development mode. This is determined automatically by checking `bool.fromEnvironment('dart.vm.product')`. Recording is:
- Started automatically when the app launches in development mode
- Stopped automatically when the app is paused or closed
- Disabled in release mode

## How It Works

The package uses several components to automatically record interactions:

1. **RecordingWidgetObserver**: Automatically wraps interactive widgets with recording capabilities
2. **NavigationTracker**: Monitors route changes using NavigatorObserver
3. **InteractionRecorder**: Captures button taps
4. **InputHandler**: Records text input changes

All interactions are saved to a JSON file and later converted into executable Flutter integration tests.

## Best Practices

1. **Initialize Early**
   - Initialize the recorder as early as possible in your app lifecycle

2. **Development Mode**
   - Always run in development mode for recording
   - Use `flutter run` instead of `flutter run --release`

3. **Test Generation**
   - Check generated tests after each recording session
   - Review and modify generated tests as needed
   - Add assertions to verify expected behavior

## Troubleshooting

1. **No Tests Generated**
   - Ensure you're running in development mode
   - Check if the app was properly closed (not force-stopped)
   - Verify the test directory exists

2. **Missing Interactions**
   - Make sure widgets are standard Flutter widgets
   - Check if widgets are properly wrapped in the widget tree
   - Verify the app is not in release mode

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
