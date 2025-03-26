// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Generates integration tests from recorded interactions.
class TestGenerator {
  /// Saves a test session to a JSON file.
  Future<void> saveSession(
    Map<String, dynamic> sessionData,
    String filePath,
  ) async {
    final directory = path.dirname(filePath);
    await Directory(directory).create(recursive: true);

    final file = File(filePath);
    await file.writeAsString(jsonEncode(sessionData));
  }

  /// Generates a Flutter integration test from a recorded session.
  Future<String> generateTest(String sessionPath) async {
    final file = File(sessionPath);
    if (!await file.exists()) {
      throw Exception('Session file not found: $sessionPath');
    }

    final sessionData = jsonDecode(await file.readAsString());
    final buffer = StringBuffer();

    // Write test file header
    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:integration_test/integration_test.dart';");
    buffer.writeln();
    buffer.writeln("void main() {");
    buffer.writeln(
      "  IntegrationTestWidgetsFlutterBinding.ensureInitialized();",
    );
    buffer.writeln();
    buffer.writeln(
      "  testWidgets('Generated Integration Test', (WidgetTester tester) async {",
    );

    // Process interactions in chronological order
    final allInteractions = <Map<String, dynamic>>[];
    allInteractions.addAll(
      (sessionData['interactions'] as List).cast<Map<String, dynamic>>(),
    );
    allInteractions.addAll(
      (sessionData['navigation'] as List).cast<Map<String, dynamic>>(),
    );
    allInteractions.addAll(
      (sessionData['inputs'] as List).cast<Map<String, dynamic>>(),
    );
    allInteractions.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    // Generate test steps
    for (final interaction in allInteractions) {
      switch (interaction['type']) {
        case 'tap':
          _generateTapStep(buffer, interaction);
          break;
        case 'input':
          _generateInputStep(buffer, interaction);
          break;
        case 'push':
          _generateNavigationStep(buffer, interaction);
          break;
        case 'pop':
          _generateNavigationStep(buffer, interaction);
          break;
      }
    }

    // Write test file footer
    buffer.writeln("  });");
    buffer.writeln("}");

    return buffer.toString();
  }

  void _generateTapStep(StringBuffer buffer, Map<String, dynamic> interaction) {
    final finder = _generateFinder(interaction);
    buffer.writeln("    await tester.tap($finder);");
    buffer.writeln("    await tester.pumpAndSettle();");
  }

  void _generateInputStep(
    StringBuffer buffer,
    Map<String, dynamic> interaction,
  ) {
    final finder = _generateFinder(interaction);
    buffer.writeln(
      "    await tester.enterText($finder, '${interaction['value']}');",
    );
    buffer.writeln("    await tester.pumpAndSettle();");
  }

  void _generateNavigationStep(
    StringBuffer buffer,
    Map<String, dynamic> interaction,
  ) {
    if (interaction['type'] == 'push') {
      buffer.writeln("    // Navigated to: ${interaction['route']}");
    } else {
      buffer.writeln("    // Navigated back from: ${interaction['route']}");
    }
    buffer.writeln("    await tester.pumpAndSettle();");
  }

  String _generateFinder(Map<String, dynamic> interaction) {
    if (interaction['type'] == 'input') {
      return "find.byType(TextField)";
    }

    // For taps, try to find the widget by text first
    if (interaction['text'] != null) {
      return "find.text('${interaction['text']}')";
    }

    // Fallback to widget type
    return "find.byType(${interaction['widgetType']})";
  }
}
