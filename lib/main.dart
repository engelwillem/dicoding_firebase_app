import 'dart:io';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// =====================
// Model + data lokal (offline)
// =====================
class CatalogItem {
  final String id;
  final String title;
  final String subtitle; // kategori singkat
  final String description;

  const CatalogItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

final List<CatalogItem> demoItems = List.generate(
  12,
  (i) => CatalogItem(
    id: 'item_${i + 1}',
    title: 'Item ${i + 1}',
    subtitle: 'Kategori ${(i % 4) + 1}',
    description:
        'Ini deskripsi item ${i + 1}. Data masih lokal agar UI + navigasi stabil dan bisa digunakan offline.',
  ),
);

// Menyimpan path gambar per item (untuk masa depan).
// Saat submission: tombol foto dinonaktifkan agar tidak crash.
final ValueNotifier<Map<String, String>> itemImagePaths = ValueNotifier(
  <String, String>{},
);

// =====================
// App (Stateless)
// =====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

// =====================
// Home (Stateless)
// =====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _thumb(BuildContext context, CatalogItem item) {
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: itemImagePaths,
      builder: (context, map, _) {
        final path = map[item.id];
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: path == null
                ? Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image),
                  )
                : Image.file(File(path), fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketLog'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: demoItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = demoItems[index];
                  return Card(
                    elevation: 0,
                    child: ListTile(
                      leading: _thumb(context, item),
                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(item: item),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'E B Willem',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================
// Detail (Stateless)
// =====================
class DetailPage extends StatelessWidget {
  final CatalogItem item;
  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<Map<String, String>>(
                valueListenable: itemImagePaths,
                builder: (context, map, _) {
                  final path = map[item.id];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: path == null
                          ? Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: Icon(Icons.image, size: 56),
                              ),
                            )
                          : Image.file(File(path), fit: BoxFit.cover),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                item.subtitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Tombol aman (tidak crash) untuk submission
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Fitur foto sementara dinonaktifkan untuk submission agar stabil.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Pilih Foto & Crop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================
// Search (Stateful) - mengikuti panduan syarat StatefulWidget
// =====================
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _thumb(BuildContext context, CatalogItem item) {
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: itemImagePaths,
      builder: (context, map, _) {
        final path = map[item.id];
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: path == null
                ? Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image),
                  )
                : Image.file(File(path), fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = demoItems.where((e) {
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.subtitle.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Cari item',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Tidak ada hasil'))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return Card(
                            elevation: 0,
                            child: ListTile(
                              leading: _thumb(context, item),
                              title: Text(item.title),
                              subtitle: Text(item.subtitle),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailPage(item: item),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
