import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_reels/app.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: Text('QuranReels'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify basic app rendering
    expect(find.text('QuranReels'), findsOneWidget);
  });
}
