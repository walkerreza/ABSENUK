// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:absenuk/app/routes/app_pages.dart';

void main() {
  testWidgets('App initial route smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      GetMaterialApp(
        title: "Application",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );

    // TODO: Verify that the initial route (AppPages.INITIAL) displays correctly.
    // The following lines are for the default counter app and will likely fail.
    // You need to adapt them to test your actual initial UI.
    //
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);
    //
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    //
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);

    // For now, a simple test to ensure GetMaterialApp is rendered:
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
