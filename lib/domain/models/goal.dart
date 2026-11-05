class Goal {
  final String id;
  final String userId;
  final String name;
  final int targetCents;
  final int currentCents;
  final String? targetDate; // YYYY-MM-DD
  final String? categoryId;
  final String color;
  final String icon;
  final String syncStatus;
  final String createdAt;
  final String updatedAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetCents,
    this.currentCents = 0,
    this.targetDate,
    this.categoryId,
    required this.color,
    required this.icon,
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage {
    if (targetCents <= 0) return 0.0;
    final pct = (currentCents / targetCents) * 100.0;
    return pct > 100.0 ? 100.0 : pct;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'target_cents': targetCents,
      'current_cents': currentCents,
      'target_date': targetDate,
      'category_id': categoryId,
      'color': color,
      'icon': icon,
      'sync_status': syncStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      targetCents: map['target_cents'] as int,
      currentCents: map['current_cents'] as int? ?? 0,
      targetDate: map['target_date'] as String?,
      categoryId: map['category_id'] as String?,
      color: map['color'] as String,
      icon: map['icon'] as String,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}

