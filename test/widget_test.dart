import 'package:flutter_test/flutter_test.dart';
import 'package:motrich/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MotrichApp smoke test - shows welcome screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MotrichApp());
    await tester.pumpAndSettle();
    expect(find.text('Motrich Manager'), findsOneWidget);
    expect(find.text('Pencatat Keuangan Pribadi dengan Kendali Penuh'), findsOneWidget);
  });
}
