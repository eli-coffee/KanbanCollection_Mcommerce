import 'package:flutter/material.dart';

class ShopTopBar extends StatelessWidget {
  const ShopTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: Theme.of(context).colorScheme.surface,
      titleSpacing: 16,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'images/logo.png',
              height: 70,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 70,
                width: 70,
                color: Colors.blue.shade50,
                child: const Icon(Icons.store, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Kanban Collectibles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}