class Product {
  final String id;
  final String name;
  final double price;
  final double? oldPrice;
  final String category;
  final String imageUrl;
  final bool preorder;
  final String description;
  final List<String> details;
  final double rating;
  final int reviews;
  final String seller;
  final int? stock;
  final List<String> images;  
  final String preorderPeriod; 

  const Product({
    this.id = '',
    required this.name,
    required this.price,
    this.oldPrice,
    this.category = 'All',
    this.imageUrl = '',
    this.preorder = false,
    this.description = 'No description available yet.',
    this.details = const [],
    this.rating = 0,
    this.reviews = 0,
    this.seller = '',
    this.stock,
    this.images = const [],
    this.preorderPeriod = '',
  });

  factory Product.fromMap(String id, Map<dynamic, dynamic> d) {
    return Product(
      id: id,
      name: d['name']?.toString() ?? 'Unnamed',
      price: (d['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (d['oldPrice'] as num?)?.toDouble(),
     category: (d['category']?.toString().trim().isNotEmpty ?? false)
    ? d['category'].toString().trim()
    : 'Uncategorized',
      imageUrl: d['imageUrl']?.toString() ?? '',
      preorder: d['preorder'] == true,
      description:
          d['description']?.toString() ?? 'No description available yet.',
      details: (d['details'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      reviews: (d['reviews'] as num?)?.toInt() ?? 0,
      seller: d['seller']?.toString() ?? '',
      stock: (d['stock'] as num?)?.toInt(),
      images: (d['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      preorderPeriod: d['preorderPeriod']?.toString() ?? '',
    );
  }

  Map<String, Object?> toMap() => {
      'name': name,
      'price': price,
      'oldPrice': oldPrice,
      'category': category,
      'imageUrl': imageUrl,
      'preorder': preorder,
      'description': description,
      'details': details,
      'seller': seller,
      'stock': stock,
      'images': images,
      'preorderPeriod': preorderPeriod,
    };

     int? get available => preorder ? null : stock;
     bool get soldOut => !preorder && stock != null && stock! <= 0;
}