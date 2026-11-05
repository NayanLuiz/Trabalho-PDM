class CreditCard {
  final String id;
  final String userId;
  final String name;
  final int limitCents;
  final int closingDay;
  final int dueDay;
  final String color;
  final int currentInvoiceCents;
  final String syncStatus;
  final String createdAt;
  final String updatedAt;

  const CreditCard({
    required this.id,
    required this.userId,
    required this.name,
    required this.limitCents,
    required this.closingDay,
    required this.dueDay,
    required this.color,
    this.currentInvoiceCents = 0,
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  int get availableLimitCents => limitCents - currentInvoiceCents;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'limit_cents': limitCents,
      'closing_day': closingDay,
      'due_day': dueDay,
      'color': color,
      'sync_status': syncStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map, {int currentInvoiceCents = 0}) {
    return CreditCard(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      limitCents: map['limit_cents'] as int,
      closingDay: map['closing_day'] as int,
      dueDay: map['due_day'] as int,
      color: map['color'] as String,
      currentInvoiceCents: currentInvoiceCents,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}

