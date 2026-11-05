enum AccountType { CHECKING, SAVINGS, CASH, INVESTMENT }

class Account {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final int balanceCents;
  final String color;
  final bool isArchived;
  final String syncStatus;
  final String createdAt;
  final String updatedAt;

  const Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balanceCents,
    required this.color,
    this.isArchived = false,
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.name,
      'balance_cents': balanceCents,
      'color': color,
      'is_archived': isArchived ? 1 : 0,
      'sync_status': syncStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      type: AccountType.values.byName(map['type'] as String),
      balanceCents: map['balance_cents'] as int,
      color: map['color'] as String,
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Account copyWith({
    String? name,
    AccountType? type,
    int? balanceCents,
    String? color,
    bool? isArchived,
    String? syncStatus,
    String? updatedAt,
  }) {
    return Account(
      id: id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balanceCents: balanceCents ?? this.balanceCents,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

