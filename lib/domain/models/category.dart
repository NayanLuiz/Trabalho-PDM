enum CategoryType { INCOME, EXPENSE, INVESTMENT }

class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String nameNormalized;
  final CategoryType type;
  final String color;
  final bool isArchived;
  final String syncStatus;
  final String createdAt;
  final String updatedAt;

  const CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.nameNormalized,
    required this.type,
    required this.color,
    this.isArchived = false,
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  static String normalizeName(String name) {
    return name.trim().toLowerCase();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'name_normalized': nameNormalized,
      'type': type.name,
      'color': color,
      'is_archived': isArchived ? 1 : 0,
      'sync_status': syncStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      nameNormalized: map['name_normalized'] as String,
      type: CategoryType.values.byName(map['type'] as String),
      color: map['color'] as String,
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
