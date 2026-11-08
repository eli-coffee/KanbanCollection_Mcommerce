    import 'package:flutter/material.dart';
    import '../models/product.dart';
    import '../widgets/product_card.dart';
    import '../services/cart_service.dart';
    import '../screens/checkout_screen.dart';
    import '../utils/responsive.dart';
    import '../utils/product_image.dart';
    import 'package:flutter/gestures.dart';
    import '../services/product_service.dart';
    import '../services/settings_service.dart';
    import '../services/tts_service.dart';
    import '../utils/strings.dart';

    class ProductDetailScreen extends StatefulWidget {
      final Product product;
      final List<Product> allProducts; 

      const ProductDetailScreen({
        super.key,
        required this.product,
        required this.allProducts,
      });

      @override
      State<ProductDetailScreen> createState() => _ProductDetailScreenState();
    }

    class _ProductDetailScreenState extends State<ProductDetailScreen> {
      int _quantity = 1;
      final _recsController = ScrollController();
      bool _favorite = false;

      final _cartService = CartService();
      Product? _live; 

      String _peso(double v) =>
          '₱${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

      List<Product> get _recommendations {
        final p = widget.product;
        final same = widget.allProducts
            .where((x) => x.name != p.name && x.category == p.category)
            .toList();
        final others = widget.allProducts
            .where((x) => x.name != p.name && x.category != p.category)
            .toList();
        return [...same, ...others].take(6).toList();
      }

         Future<void> _addToCart() async {
    final p = _live ?? widget.product;
    await _cartService.add(p, quantity: _quantity);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              S.t('{n} × {name} added to cart', {'n': _quantity, 'name': p.name}))),
    );
  }
      void _buyNow() {
      final p = widget.product;
        Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            isPreorder: p.preorder,
            items: [
              CartItem(
                id: p.id.isEmpty ? p.name : p.id,
                name: p.name,
                price: p.price,
                imageUrl: p.imageUrl,
                preorder: p.preorder,
                quantity: _quantity,
              ),
            ],
          ),
        ),
      );
    }
      @override
      void dispose() {
        _recsController.dispose();
        TtsService.stop();
        super.dispose();
      }

      

      @override
      Widget build(BuildContext context) {
        LangScope.watch(context);

        return StreamBuilder<List<Product>>(
          stream: ProductService.stream(),
          builder: (context, snap) {
            var p = widget.product;
            for (final x in snap.data ?? const <Product>[]) {
              if (x.id == p.id) {
                p = x;
                break;
              }
            }
            
            _live = p;
            if (p.available != null && p.available! > 0 && _quantity > p.available!) {
              _quantity = p.available!;
            }
            return _buildPage(p);
          },
        );
      }
        
      @override
      Widget _buildPage(Product p) {
        final recs = _recommendations;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Product'),
            actions: [
              if (p.seller.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(context.tr('Sold by {name}', {'name': p.seller}),
                      style: const TextStyle(color: Colors.grey)),
                ),
              IconButton(
                icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border,
                    color: _favorite ? Colors.red : null),
                onPressed: () => setState(() => _favorite = !_favorite),
              ),
            ],
          ),

          body:  ResponsiveCenter(maxWidth: 800, child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
                      ColoredBox(
                        color: Colors.white,
                        child: SizedBox(
                      height: MediaQuery.of(context).size.width < 600
                          ? MediaQuery.of(context).size.width
                          : 420,
                      child: p.imageUrl.isEmpty
                          ? Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.toys, size: 80, color: Colors.grey),
                            )
                          : buildProductImage(p.imageUrl, fit: BoxFit.contain),
                    ),
                      ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.preorder)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Pre-Order Now Open',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    Text(p.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(_peso(p.price),
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                        if (p.oldPrice != null) ...[
                          const SizedBox(width: 10),
                          Text(_peso(p.oldPrice!),
                              style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough)),
                        ],
                      ],
                    ),

                    Padding(
      padding: const EdgeInsets.only(top: 8),
      child: p.preorder
          ?  Text(context.tr('Pre-order item'),
              style: TextStyle(color: Colors.orange))
          : p.stock == null
              ? SizedBox.shrink()
              : p.soldOut
                  ? Text(context.tr('Out of stock'),
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600))
                  : Text(context.tr('{n} in stock', {'n': p.stock}),
                      style: TextStyle(
                          color: p.stock! <= 5 ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.w600)),
    ),
                    if (p.reviews > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(context.tr('{rating}  ·  {n} Reviews', {
                            'rating': p.rating.toStringAsFixed(1),
                            'n': p.reviews
                          })),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Text(p.stock != null && !p.preorder
                          ? context.tr('Quantity ({n} available)', {'n': p.stock})
                          : context.tr('Quantity'),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        IconButton.outlined(
                          icon: const Icon(Icons.remove),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('$_quantity',
                              style: const TextStyle(fontSize: 18)),
                        ),
                      IconButton.outlined(
                            icon: const Icon(Icons.add),
                            onPressed: (p.available == null || _quantity < p.available!)
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                      ],
                    ),

                    const Divider(height: 32),
                   Row(
                        children: [
                           Expanded(
                            child: Text(context.tr('Product description'), style: TextStyle(fontSize: 22)),
                          ),
                          if (SettingsService().ttsEnabled)
                            IconButton(
                              tooltip: context.tr('Read aloud'),
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => TtsService.speak(
                                '${p.name}. ${p.price.round()} pesos. ${p.description}. '
                                '${p.details.join('. ')}',
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(p.description),

                    if (p.details.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(context.tr('Product Details'),
                          style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      for (final d in p.details)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•  '),
                              Expanded(child: Text(d)),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              

              
              if (recs.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(context.tr('You may also like'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              SizedBox(
                        height: 230,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                            },
                          ),
                          child: Scrollbar(
                            controller: _recsController,
                            thumbVisibility: true,
                            child: ListView.separated(
                              controller: _recsController,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              scrollDirection: Axis.horizontal,
                              itemCount: recs.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 12),
                              itemBuilder: (_, i) => SizedBox(
                                width: 160,
                                child: ProductCard(
                                  product: recs[i],
                                  onTap: () => Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                        product: recs[i],
                                        allProducts: widget.allProducts,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
    ),
              ],
            ],
          ),
          ),
          
        bottomNavigationBar: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: p.soldOut ? null : _addToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(context.tr('Add to Cart')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: p.soldOut ? null : _buyNow,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(p.soldOut
                  ? context.tr('Out of Stock')
                  : (p.preorder ? context.tr('Pre-Order Now') : context.tr('Buy Now'))),
            ),
          ),
        ],
      ),
    ),
  ),
          );
      }
    }