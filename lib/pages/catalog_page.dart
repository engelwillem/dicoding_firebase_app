import 'package:flutter/material.dart';

import '../app_router.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  // Dummy data offline dulu (nanti dirapihin nama+foto kedepannya)
  static final List<Map<String, dynamic>> _products = [
    {'name': 'IT Runner Pro', 'price': 349000},
    {'name': 'IT Street Flex', 'price': 299000},
    {'name': 'IT Hiking Grip', 'price': 429000},
    {'name': 'IT Slip-On Daily', 'price': 219000},
    {'name': 'IT Court Classic', 'price': 319000},
    {'name': 'IT Sandal Urban', 'price': 179000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsif: lebar layar menentukan jumlah kolom grid
            final maxTileWidth = constraints.maxWidth < 500 ? 220.0 : 260.0;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: maxTileWidth,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final p = _products[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.detail,
                      arguments: p, // kirim data ke halaman detail
                    );
                  },
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Placeholder gambar dulu (nanti diganti jadi Image.asset)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                              child: const Icon(Icons.image, size: 48),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            p['name'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rp ${p['price']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
