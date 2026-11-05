enum BudgetStatus { NORMAL, WARNING, EXCEEDED }

class Budget {
  final String id;
  final String userId;
  final String categoryId;
  final int year;
  final int month;
  final int limitCents;
  final String syncStatus;
  final String createdAt;
  final String updatedAt;

  const Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.year,
    required this.month,
    required this.limitCents,
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'year': year,
      'month': month,
      'limit_cents': limitCents,
      'sync_status': syncStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String,
      year: map['year'] as int,
      month: map['month'] as int,
      limitCents: map['limit_cents'] as int,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}

