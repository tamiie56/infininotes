class LabelModel {
  final String id;
  final String name;

  LabelModel({
    required this.id,
    required this.name,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}