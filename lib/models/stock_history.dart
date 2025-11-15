class StockHistory {
  int? id;
  int productId;
  String type; // "IN" or "OUT"
  int amount;
  String date;
  String? note;

  StockHistory({
    this.id,
    required this.productId,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
  });

  factory StockHistory.fromMap(Map<String, dynamic> map) => StockHistory(
    id: map['id'] as int?,
    productId: map['product_id'] as int,
    type: map['type'] as String,
    amount: map['amount'] as int,
    date: map['date'] as String,
    note: map['note'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'product_id': productId,
    'type': type,
    'amount': amount,
    'date': date,
    'note': note,
  };
}
