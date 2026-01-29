import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketlog_app_ewillem/main.dart';
import 'package:pocketlog_app_ewillem/models/catalog_item.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    Hive.registerAdapter(CatalogItemAdapter());
    final box = await Hive.openBox<CatalogItem>('catalog');

    if (box.isEmpty) {
      final demoItems = List.generate(
        12,
        (i) => CatalogItem(
          id: 'item_${i + 1}',
          title: 'Item ${i + 1}',
          category: 'Kategori ${(i % 4) + 1}',
          description:
              'Ini deskripsi item ${i + 1}. Data masih lokal agar UI + navigasi stabil dan bisa digunakan offline.',
        ),
      );
      for (var item in demoItems) {
        box.put(item.id, item);
      }
    }
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

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
