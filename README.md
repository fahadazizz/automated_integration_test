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
  automated_integration_test: ^1.0.0
```

## Quick Start Guide

1. **Add the Package**
   Add the package to your app's `pubspec.yaml`:
   ```yaml
   dependencies:
     automated_integration_test: ^1.0.0
   ```

2. **Initialize the Recorder**
   In your `main.dart`, initialize the recorder early in the app lifecycle:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Initialize the recorder (no context needed)
     await AutoTestRecorder.initialize();
     
     runApp(const MyApp());
   }
   ```

3. **Wrap Your App**
   Wrap your `MaterialApp` with the recorder:
   ```dart
   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return AutoTestRecorder.instance.wrapApp(
         MaterialApp(
           home: MyHomePage(),
         ),
       );
     }
   }
   ```

4. **Run Your App**
   Run your app in development mode:
   ```bash
   flutter run
   ```

5. **Interact with Your App**
   - Use your app normally
   - All UI interactions will be automatically recorded
   - Recording stops automatically when the app is paused or closed

6. **Check Generated Tests**
   After running your app, check the generated tests in:
   ```
   test/integration/YYYY-MM-DD_HH-mm-ss_[session-id]_test.dart
   ```

## Complete Example

Here's a complete example showing how to use the package:

```dart
import 'package:flutter/material.dart';
import 'package:automated_integration_test/automated_integration_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the recorder (no context needed)
  await AutoTestRecorder.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTestRecorder.instance.wrapApp(
      MaterialApp(
        title: 'Automated Test Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automated Test Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text input field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Button to navigate to second screen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecondScreen(),
                  ),
                );
              },
              child: const Text('Go to Second Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
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
    await tester.tap(find.text('Go to Second Screen'));
    await tester.pumpAndSettle();
    
    // Verify we're on the second screen
    expect(find.text('Welcome to Second Screen!'), findsOneWidget);
    
    // Tap the back button
    await tester.tap(find.text('Go Back'));
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
   - Use a global navigator key to access context

2. **Development Mode**
   - Always run in development mode for recording
   - Use `flutter run` instead of `flutter run --release`

3. **Test Generation**
   - Check generated tests after each recording session
   - Review and modify generated tests as needed
   - Add assertions to verify expected behavior

4. **Navigation**
   - Use named routes for better test generation
   - Keep navigation paths simple and predictable

## Troubleshooting

1. **No Tests Generated**
   - Ensure you're running in development mode
   - Check if the app was properly closed (not force-stopped)
   - Verify the test directory exists

2. **Missing Interactions**
   - Make sure widgets are standard Flutter widgets
   - Check if widgets are properly wrapped in the widget tree
   - Verify the app is not in release mode

3. **Test Generation Errors**
   - Check for proper widget keys
   - Ensure all required dependencies are installed
   - Verify Flutter SDK version compatibility

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
