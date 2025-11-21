import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warung_ajib/main.dart';

void main() {
  testWidgets('App launches and shows SplashScreen with correct content', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Verify that MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that SplashScreen is shown
    expect(find.byType(Scaffold), findsOneWidget);

    // Verify ALL the text content that actually exists in your SplashScreen
    expect(find.text('Selamat Datang di'), findsOneWidget);
    expect(find.text('WARUNG AJIB'), findsOneWidget);
    expect(find.text('Mranggen, Demak'), findsOneWidget);

    // Verify there's an Icon (based on the widget tree)
    expect(find.byType(Icon), findsOneWidget);

    // Verify the layout structure
    expect(find.byType(Center), findsWidgets);
    expect(find.byType(Column), findsWidgets);
  });

  testWidgets('SplashScreen has correct widget hierarchy', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify the main structural widgets
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Center), findsWidgets);
    expect(find.byType(Column), findsWidgets);

    // Verify all three text widgets are present
    expect(find.text('Selamat Datang di'), findsOneWidget);
    expect(find.text('WARUNG AJIB'), findsOneWidget);
    expect(find.text('Mranggen, Demak'), findsOneWidget);
  });
}