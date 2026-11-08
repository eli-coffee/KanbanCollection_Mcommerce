import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../utils/strings.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faq = [
    ('How do I place an order?',
        'Open a product, choose a quantity, then tap Add to Cart or Buy Now. Review your items in Checkout and tap Place Order.'),
    ('What is a pre-order?',
        'A pre-order reserves an item that is not in stock yet. Pre-orders have no stock limit and appear in My Orders under Pre-order.'),
    ('How do I cancel an order?',
        'Go to Profile, then My Orders. Orders that are still Processing, Pre-order or Shipping show a Cancel Order button.'),
    ('Where can I see my order status?',
        'Profile, then My Orders has a tab for each status. The Notification tab also tells you when a status changes.'),
    ('How do I sell my own products?',
        'Open Profile, then My Store, and tap Add product. Add photos, a price, a category, and your stock.'),
    ('How do I change my username or password?',
        'Open Settings, then My Data. Changing your username or password asks for your current password.'),
    ('Why is a product marked Sold Out?',
        'The seller has no units left. If an order is cancelled, the units return to stock.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Help Center'))),
      body: ResponsiveCenter(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final f in _faq)
              Card(
                child: ExpansionTile(
                  title: Text(context.tr(f.$1),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(context.tr(f.$2))],
                ),
              ),
          ],
        ),
      ),
    );
  }
}