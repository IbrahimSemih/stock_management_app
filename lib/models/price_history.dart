class PriceHistory {
  int? id;
  int productId;
  double? oldPurchasePrice;
  double? newPurchasePrice;
  double? oldSalePrice;
  double? newSalePrice;
  String date;

  PriceHistory({
    this.id,
    required this.productId,
    this.oldPurchasePrice,
    this.newPurchasePrice,
    this.oldSalePrice,
    this.newSalePrice,
    required this.date,
  });

  factory PriceHistory.fromMap(Map<String, dynamic> map) => PriceHistory(
    id: map['id'] as int?,
    productId: map['product_id'] as int,
    oldPurchasePrice: map['old_purchase_price'] as double?,
    newPurchasePrice: map['new_purchase_price'] as double?,
    oldSalePrice: map['old_sale_price'] as double?,
    newSalePrice: map['new_sale_price'] as double?,
    date: map['date'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'product_id': productId,
    'old_purchase_price': oldPurchasePrice,
    'new_purchase_price': newPurchasePrice,
    'old_sale_price': oldSalePrice,
    'new_sale_price': newSalePrice,
    'date': date,
  };
}

