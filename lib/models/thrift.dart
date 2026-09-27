class ThriftProduct {
  final int id;
  final String title;
  final String description;
  final int price;
  final String conditionStatus;
  final bool isSold;
  final Category? category;
  final Owner? seller;
  final List<ThriftImage> images;

  ThriftProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.conditionStatus,
    required this.isSold,
    this.category,
    this.seller,
    required this.images,
  });

  factory ThriftProduct.fromJson(Map<String, dynamic> json) {
    return ThriftProduct(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      conditionStatus: json['condition_status'] ?? '',
      isSold: json['is_sold'] ?? false,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      seller: json['seller'] != null ? Owner.fromJson(json['seller']) : null,
      images: (json['images'] as List?)?.map((e) => ThriftImage.fromJson(e)).toList() ?? [],
    );
  }
}

class ThriftImage {
  final int id;
  final String imagePath;
  final String? url;

  ThriftImage({required this.id, required this.imagePath, this.url});

  factory ThriftImage.fromJson(Map<String, dynamic> json) {
    return ThriftImage(
      id: json['id'],
      imagePath: json['image_path'] ?? '',
      url: json['url'],
    );
  }
}

class Category {
  final int id;
  final String name;
  final String slug;

  Category({required this.id, required this.name, required this.slug});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class Owner {
  final int id;
  final String name;
  final String email;
  final String? phone;

  Owner({required this.id, required this.name, required this.email, this.phone});

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }
}
