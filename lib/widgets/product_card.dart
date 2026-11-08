import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/product_image.dart';
import '../utils/strings.dart';

String _peso(double v) =>
    '₱${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: scheme.surface,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    p.imageUrl.isEmpty
                        ? Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.toys, size: 48))
                        : buildProductImage(p.imageUrl, fit: BoxFit.cover),
                    if (p.soldOut)
                      Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: Text(context.tr('SOLD OUT'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 2)),
                      )
                    else if (!p.preorder && p.stock != null && p.stock! <= 5)
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Text(
                              context.tr('Only {n} left', {'n': p.stock}),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
                            child: Row(
                children: [
                  Icon(Icons.sell_outlined, size: 24, color: scheme.onSurface),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 3,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_peso(p.price),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          if (p.oldPrice != null)
                            Text(_peso(p.oldPrice!),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough)),
                        ],
                      ),
                    ),
                  ),
                  if (p.preorder) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          color: AppColors.preorder,
                          child: Text(
                            context.tr('Pre-Order\nNow Open'),
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.1,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (onAddToCart != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      onPressed: p.soldOut ? null : onAddToCart,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}