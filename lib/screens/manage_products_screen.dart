import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_form_screen.dart';
import '../services/auth_service.dart';
import '../utils/responsive.dart';
import '../utils/product_image.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final _searchController = TextEditingController();
 late final Stream<List<Product>> _stream =
  ProductService.streamForSeller(AuthService().currentUsername ?? '');
  String _query = '';      

  
  
  String _peso(double v) =>
      '₱${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

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
        content: Text('"${p.name}" will be removed from the shop. '
            'This cannot be undone.'),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

 Widget _thumb(Product p) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(
      width: 56,
      height: 56,
      child: p.imageUrl.isEmpty
          ? Container(color: Colors.grey.shade200, child: const Icon(Icons.toys))
          : buildProductImage(p.imageUrl, width: 56, height: 56),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Store'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body:  ResponsiveCenter(maxWidth: 800, child:Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
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

                final list = snapshot.data!
                    .where((p) =>
                        p.name.toLowerCase().contains(_query.toLowerCase()))
                    .toList();

                if (list.isEmpty) {
                  return Center(
                    child: Text(_query.isEmpty
                        ? 'You have no listings yet. Tap Add product to sell something.'
                        : 'No products match your search.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = list[i];
                    return ListTile(
                      leading: _thumb(p),
                      title: Text(p.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                          '${_peso(p.price)}  ·  ${p.category}${p.preorder ? '  ·  Pre-order' : ''}'),
                      onTap: () => _open(p),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                            onPressed: () => _open(p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () => _delete(p),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      )
    );
  }
}