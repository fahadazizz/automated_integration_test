import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> setupIntegrationTest() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

Future<void> pumpAndSettle(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 1));
}
