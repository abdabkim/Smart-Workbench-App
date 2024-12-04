import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_workbench_app/providers/user_provider.dart';
import 'package:smart_workbench_app/screens/welcomescreen.dart';
import 'package:smart_workbench_app/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => User())
        ],
        child: SmartWorkBenchApp(startscreen: WelcomeScreen()),
      ),
    );

    // Verify that the welcome screen is displayed
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}