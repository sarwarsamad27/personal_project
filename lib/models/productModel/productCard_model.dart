class ProductCard {
  final String? productId;
  final String? productName;
  final String? productImage;
  final String? productPrice;
  final String? productDescription;
  final String? brandName;
  final String? sellerId;

  ProductCard({
    this.productId,
    this.productName,
    this.productImage,
    this.productPrice,
    this.productDescription,
    this.brandName,
    this.sellerId,
  });

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    return ProductCard(
      productId: json["productId"]?.toString(),
      productName: json["productName"]?.toString(),
      productImage: json["productImage"]?.toString(),
      productPrice: json["productPrice"]?.toString(),
      productDescription: json["productDescription"]?.toString(),
      brandName: json["brandName"]?.toString(),
      sellerId: json["sellerId"]?.toString(),
    );
  }
}