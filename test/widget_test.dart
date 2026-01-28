import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dicoding_firebase_app/main.dart';

void main() {
  testWidgets('PocketLog: Home tampil dan bisa ke Search + filter', (tester) async {
    // Jalankan app
    await tester.pumpWidget(const MyApp());

    // Pastikan Home tampil
    expect(find.text('PocketLog'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);

    // Navigasi ke Search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Pastikan SearchPage tampil
    expect(find.text('Search'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Ketik untuk memfilter
    await tester.enterText(find.byType(TextField), 'Item 12');
    await tester.pumpAndSettle();

    // Cek "Item 12" di list saja (bukan teks di TextField)
    final listTextMatches =
        find.text('Item 12').evaluate().where((e) => e.widget is Text).length;

    expect(listTextMatches, 1);
  });
}
