class OrderItem{
  final String name;
  final double price;
  final int quantity;
  final String productId;

const OrderItem ({
  required this.name,
  required this.price,
  required this.quantity,
  this.productId = '',
});
}



class AppOrder {
  final String username;
  final String id;
  final List<OrderItem> items;
  final double total;
  final String status;
  final int createdAt;
  final String node;
  final String productId;

  const AppOrder({
    this.productId = '',
    required this.username,
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.node = 'orders',
  });


    factory AppOrder.fromMap(String id, Map<dynamic, dynamic> d, 
    {String node = 'orders'}) {
    final rawItems = d['items'];
    final Iterable<dynamic> itemList = (rawItems is List) 
    ? rawItems 
    : rawItems is Map 
    ? rawItems.values 
    : const [];
    
      
      final items = <OrderItem>[];
      for (final i in itemList)
      {
        if (i is Map) {
          items.add(OrderItem(
            productId: i['productId']?.toString() ?? '',
            name: i['name']?.toString() ?? 'Item',
            quantity: (i['quantity'] as num?)?.toInt() ?? 1,
            price: (i['price'] as num?) ?.toDouble() ?? 0,
          ));

        }

      }
      

    return AppOrder(
      username: d['username']?.toString() ?? '',
      id: id,
      items: items,
      total: (d['total'] as num?)?.toDouble() ?? 0,
      status: d['status']?.toString() ?? 'Pending',
      createdAt: (d['createdAt'] as num?)?.toInt() ?? 0,
      node: node,
    );
  }
}

