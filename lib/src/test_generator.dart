// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Generates integration tests from recorded interactions.
class TestGenerator {
  /// Ensures the test directory exists
  Future<String> _ensureTestDirectory() async {
    final testDir = Directory('test/integration');
    if (!await testDir.exists()) {
      await testDir.create(recursive: true);
    }
    return testDir.path;
  }

  /// Saves the session data to a JSON file
  Future<void> saveSession(
      Map<String, dynamic> sessionData, String filePath) async {
    try {
      final file = File(filePath);
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      await file.writeAsString(jsonEncode(sessionData));
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  /// Generates a test file from the recorded session
  Future<String> generateTest(String sessionFilePath) async {
    try {
      final testDirPath = await _ensureTestDirectory();
      final sessionFile = File(sessionFilePath);

      if (!await sessionFile.exists()) {
        print('Session file not found: $sessionFilePath');
        return '';
      }

      final sessionData = jsonDecode(await sessionFile.readAsString());
      final testContent = _generateTestContent(sessionData);

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final testFilePath =
          path.join(testDirPath, 'integration_test_$timestamp.dart');

      final testFile = File(testFilePath);
      await testFile.writeAsString(testContent);

      print('Test file generated at: $testFilePath');
      return testContent;
    } catch (e) {
      print('Error generating test: $e');
      return '';
    }
  }

  /// Generates the test file content
  String _generateTestContent(Map<String, dynamic> sessionData) {
    final interactions = sessionData['interactions'] as List? ?? [];
    final navigation = sessionData['navigation'] as List? ?? [];
    final inputs = sessionData['inputs'] as List? ?? [];

    final buffer = StringBuffer();
    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:integration_test/integration_test.dart';");
    buffer.writeln();
    buffer.writeln('void main() {');
    buffer
        .writeln('  IntegrationTestWidgetsFlutterBinding.ensureInitialized();');
    buffer.writeln();
    buffer.writeln(
        "  testWidgets('Generated Integration Test', (WidgetTester tester) async {");
    buffer.writeln('    await tester.pumpAndSettle();');
    buffer.writeln();

    // Add recorded interactions
    for (final interaction in interactions) {
      if (interaction['type'] == 'tap') {
        buffer.writeln(
            "    await tester.tap(find.text('${interaction['text']}'));");
        buffer.writeln('    await tester.pumpAndSettle();');
      }
    }

    // Add recorded inputs
    for (final input in inputs) {
      buffer.writeln(
          "    await tester.enterText(find.byType(${input['widgetType']}), '${input['text']}');");
      buffer.writeln('    await tester.pumpAndSettle();');
    }

    // Add navigation verifications
    for (final nav in navigation) {
      buffer
          .writeln("    expect(find.text('${nav['route']}'), findsOneWidget);");
      buffer.writeln('    await tester.pumpAndSettle();');
    }

    buffer.writeln('  });');
    buffer.writeln('}');

    return buffer.toString();
  }
}
