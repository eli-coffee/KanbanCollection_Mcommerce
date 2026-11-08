import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../utils/product_image.dart';
import '../product_form_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _search = TextEditingController();
  late final Stream<List<Product>> _stream = ProductService.stream();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _peso(double v) =>
      '₱${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

  String _stock(Product p) =>
      p.preorder ? 'Pre-order' : (p.stock == null ? '—' : '${p.stock}');

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _open([Product? product]) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (result != null && mounted) _snack('Product $result');
  }

  Future<void> _delete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"${p.name}" (sold by ${p.seller.isEmpty ? 'nobody' : p.seller}) '
            'will be removed from the shop. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ProductService.delete(p);
      if (!mounted) return;
      _snack('Product deleted');
    } catch (e) {
      if (!mounted) return;
      _snack('Could not delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Products',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _open(),
                icon: const Icon(Icons.add),
                label: const Text('Add product'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search by name, seller, or category',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final q = _query.trim().toLowerCase();
                final list = snapshot.data!
                    .where((p) =>
                        q.isEmpty ||
                        '${p.name} ${p.seller} ${p.category}'
                            .toLowerCase()
                            .contains(q))
                    .toList();

                if (list.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: c.maxWidth),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: DataTable(
                            dataRowMinHeight: 56,
                            dataRowMaxHeight: 64,
                            columns: const [
                              DataColumn(label: Text('Photo')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Seller')),
                              DataColumn(label: Text('Category')),
                              DataColumn(label: Text('Price'), numeric: true),
                              DataColumn(label: Text('Stock')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: [
                              for (final p in list)
                                DataRow(cells: [
                                  DataCell(ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: buildProductImage(p.imageUrl,
                                          width: 44, height: 44),
                                    ),
                                  )),
                                  DataCell(ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 240),
                                    child: Text(p.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                                  DataCell(Text(
                                      p.seller.isEmpty ? '—' : p.seller)),
                                  DataCell(Text(p.category)),
                                  DataCell(Text(_peso(p.price))),
                                  DataCell(Text(
                                    _stock(p),
                                    style: TextStyle(
                                        color: p.soldOut ? Colors.red : null,
                                        fontWeight: p.soldOut
                                            ? FontWeight.bold
                                            : null),
                                  )),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Edit',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _open(p),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () => _delete(p),
                                    ),
                                  ])),
                                ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}