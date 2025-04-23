class WorkCategory {
  final int id;
  final DateTime createdAt;
  final String category;

  WorkCategory({
    required this.id,
    required this.createdAt,
    required this.category,
  });

  factory WorkCategory.fromJson(Map<String, dynamic> json) {
    return WorkCategory(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'category': category,
    };
  }
}
