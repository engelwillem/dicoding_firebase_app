import 'dart:io' show Directory, File;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketlog_app_ewillem/models/catalog_item.dart';
import 'package:pocketlog_app_ewillem/pages/add_edit_item_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(CatalogItemAdapter());
  final box = await Hive.openBox<CatalogItem>('catalog');

  // Isi data awal jika database kosong
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

  runApp(const MyApp());
}

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
// Home (Stateful)
// =====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedCategory;

  Widget _thumb(BuildContext context, CatalogItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 56,
        height: 56,
        child: item.imagePath == null
            ? Container(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image),
              )
            : Image.file(File(item.imagePath!), fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogBox = Hive.box<CatalogItem>('catalog');

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
            ValueListenableBuilder(
              valueListenable: catalogBox.listenable(),
              builder: (context, Box<CatalogItem> box, _) {
                final categories = ['All', ...box.values.map((e) => e.category).toSet()];
                return SizedBox(
                  height: 60,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category || (_selectedCategory == null && category == 'All'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategory = category == 'All' ? null : category;
                            } else {
                              _selectedCategory = null;
                            }
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: catalogBox.listenable(),
                builder: (context, Box<CatalogItem> box, _) {
                  final items = box.values.where((item) {
                    return _selectedCategory == null || item.category == _selectedCategory;
                  }).toList();

                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No items in this category.'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        elevation: 0,
                        child: ListTile(
                          leading: _thumb(context, item),
                          title: Text(item.title),
                          subtitle: Text(item.category),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(item: item),
                              ),
                            ).then((_) => setState(() {}));
                          },
                        ),
                      );
                    },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditItemPage(),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =====================
// Detail (Stateful)
// =====================
class DetailPage extends StatefulWidget {
  final CatalogItem item;
  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (croppedFile == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = '${widget.item.id}.jpg';
    final String newPath = '${appDir.path}/$fileName';

    final File newImage = await File(croppedFile.path).copy(newPath);

    setState(() {
      widget.item.imagePath = newImage.path;
      widget.item.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        actions: [
          IconButton(
            tooltip: 'Toggle Favorite',
            onPressed: () {
              setState(() {
                widget.item.isFavorite = !widget.item.isFavorite;
                widget.item.save();
              });
            },
            icon: Icon(
              widget.item.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditItemPage(item: widget.item),
                ),
              ).then((_) => setState(() {}));
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Item'),
                    content:
                        const Text('Are you sure you want to delete this item?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          widget.item.delete();
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.of(context).pop(); // Go back to the list
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.item.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.file(
                      File(widget.item.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                widget.item.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.category,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                widget.item.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              if (widget.item.imagePath == null)
                FilledButton.icon(
                  onPressed: _pickAndCropImage,
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
// Search (Stateful)
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 56,
        height: 56,
        child: item.imagePath == null
            ? Container(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image),
              )
            : Image.file(File(item.imagePath!), fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogBox = Hive.box<CatalogItem>('catalog');
    final q = _query.trim().toLowerCase();
    final filtered = catalogBox.values.where((e) {
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q);
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
                              subtitle: Text(item.category),
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
