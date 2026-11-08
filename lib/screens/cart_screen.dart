
import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '/screens/checkout_screen.dart';
import '../utils/responsive.dart';
import '../utils/product_image.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartService();
  final bool _placingOrder = false;

  String _peso(double v) =>
      '₱${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

  void _checkout() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CheckoutScreen(
        items: List.of(_cart.items),
        fromCart: true,
      ),
    ),
  );
}
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), centerTitle: true),
      body: ResponsiveCenter(maxWidth: 800, child: ListenableBuilder(listenable: _cart,
        builder: (context, _) {
          if (_cart.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 72, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Your cart is empty'),
                ],
              ),
            );
          }

          final items = _cart.items;
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 24),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return Row(
                      children: [
                       ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 72,
                            height: 72,
                            child: item.imageUrl.isEmpty
                                ? Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.toys),
                                  )
                                : buildProductImage(item.imageUrl, width: 72, height: 72),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(_peso(item.price),
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton.outlined(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: () => _cart.decrease(item),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text('${item.quantity}'),
                                  ),
                                  IconButton.outlined(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () => _cart.increase(item),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _cart.remove(item),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Summary + checkout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: const [
                    BoxShadow(blurRadius: 8, color: Colors.black12)
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total (${_cart.totalCount} items)',
                                style: const TextStyle(color: Colors.grey)),
                            Text(_peso(_cart.total),
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _placingOrder ? null : _checkout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _placingOrder
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      )
      
      );
  }
}