enum TransactionType { INCOME, EXPENSE, INVESTMENT, TRANSFER }
enum TransactionStatus { PAID, PENDING }

class TransactionModel {
  final String id;
  final String userId;
  final String? accountId;
  final String? creditCardId;
  final String categoryId;
  final TransactionType type;
  final int amountCents;
  final String date; // YYYY-MM-DD
  final int year;
  final int month;
  final String description;
  final TransactionStatus status;
  final int? installmentIndex;
  final int? totalInstallments;
  final String? recurringRule;
  final String? recurringGroupId;
  final String? receiptPath;
  final String? receiptUrl;
  final String syncStatus;
  final String createdAt;
  final String updatedAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    this.accountId,
    this.creditCardId,
    required this.categoryId,
    required this.type,
    required this.amountCents,
    required this.date,
    required this.year,
    required this.month,
    required this.description,
    this.status = TransactionStatus.PAID,
    this.installmentIndex,
    this.totalInstallments,
    this.recurringRule,
    this.recurringGroupId,
    this.receiptPath,
    this.receiptUrl,
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'credit_card_id': creditCardId,
      'category_id': categoryId,
      'type': type.name,
      'amount_cents': amountCents,
      'date': date,
      'year': year,
      'month': month,
      'description': description,
      'status': status.name,
      'installment_index': installmentIndex,
      'total_installments': totalInstallments,
      'recurring_rule': recurringRule,
      'recurring_group_id': recurringGroupId,
      'receipt_path': receiptPath,
      'receipt_url': receiptUrl,
      'sync_status': syncStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      accountId: map['account_id'] as String?,
      creditCardId: map['credit_card_id'] as String?,
      categoryId: map['category_id'] as String,
      type: TransactionType.values.byName(map['type'] as String),
      amountCents: map['amount_cents'] as int,
      date: map['date'] as String,
      year: map['year'] as int,
      month: map['month'] as int,
      description: map['description'] as String,
      status: TransactionStatus.values.byName(map['status'] as String? ?? 'PAID'),
      installmentIndex: map['installment_index'] as int?,
      totalInstallments: map['total_installments'] as int?,
      recurringRule: map['recurring_rule'] as String?,
      recurringGroupId: map['recurring_group_id'] as String?,
      receiptPath: map['receipt_path'] as String?,
      receiptUrl: map['receipt_url'] as String?,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}

