import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_pizza/main.dart';

void main() {
  testWidgets('Pizza Palace app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PizzaApp());

    // Verify that the app title is displayed
    expect(find.text('🍕 Pizza Palace'), findsOneWidget);
    expect(find.text('Build your perfect pizza!'), findsOneWidget);

    // Verify the app renders without errors
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}