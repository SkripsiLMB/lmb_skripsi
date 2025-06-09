class LmbProduct {
  final String id;
  final String name;
  final double price;

  const LmbProduct({
    required this.id,
    required this.name,
    required this.price,
  });

  factory LmbProduct.fromJson(Map<String, dynamic> json) {
    return LmbProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
  };
}