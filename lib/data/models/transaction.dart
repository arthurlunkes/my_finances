enum TransactionType {
  income, // Receita
  expense, // Despesa
  tithe, // Dízimo
  offering, // Oferta
}

enum TransactionStatus {
  pending, // Pendente
  paid, // Pago
  overdue, // Atrasado
  scheduled, // Agendado
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;
  final String category;
  final bool isRecurrent;
  final String? notes;
  final String? creditCardId;
  final int? installments;
  final int? currentInstallment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    required this.category,
    this.isRecurrent = false,
    this.notes,
    this.creditCardId,
    this.installments,
    this.currentInstallment,
    required this.createdAt,
    this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    TransactionType? type,
    TransactionStatus? status,
    String? category,
    bool? isRecurrent,
    String? notes,
    String? creditCardId,
    int? installments,
    int? currentInstallment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      isRecurrent: isRecurrent ?? this.isRecurrent,
      notes: notes ?? this.notes,
      creditCardId: creditCardId ?? this.creditCardId,
      installments: installments ?? this.installments,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'category': category,
      'isRecurrent': isRecurrent ? 1 : 0,
      'notes': notes,
      'creditCardId': creditCardId,
      'installments': installments,
      'currentInstallment': currentInstallment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.parse(json['date']),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      category: json['category'],
      isRecurrent:
          json['isRecurrent'] == 1 ||
          json['isRecurrent'] == true ||
          json['isRecurrent'] == '1',
      notes: json['notes'],
      creditCardId: json['creditCardId'],
      installments: json['installments'] is int
          ? json['installments'] as int
          : (json['installments'] != null
                ? int.tryParse(json['installments'].toString())
                : null),
      currentInstallment: json['currentInstallment'] is int
          ? json['currentInstallment'] as int
          : (json['currentInstallment'] != null
                ? int.tryParse(json['currentInstallment'].toString())
                : null),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTithe => type == TransactionType.tithe;
  bool get isOffering => type == TransactionType.offering;
  bool get isPaid => status == TransactionStatus.paid;
  bool get isPending => status == TransactionStatus.pending;
  bool get isOverdue => status == TransactionStatus.overdue;
}
