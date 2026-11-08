import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucosmart_app/main.dart';

void main() {
  testWidgets('GlucoSmart inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const GlucoSmartApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}