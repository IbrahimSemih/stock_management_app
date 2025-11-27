class Brand {
  int? id;
  String name;

  Brand({this.id, required this.name});

  factory Brand.fromMap(Map<String, dynamic> map) =>
      Brand(id: map['id'] as int?, name: map['name'] as String);

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}

