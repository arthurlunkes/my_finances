class CreditCard {
  final String id;
  final String name;
  final String lastDigits;
  final double limit;
  final int closingDay;
  final int dueDay;
  final String brand; // Visa, Mastercard, etc.
  final String? color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CreditCard({
    required this.id,
    required this.name,
    required this.lastDigits,
    required this.limit,
    required this.closingDay,
    required this.dueDay,
    required this.brand,
    this.color,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  CreditCard copyWith({
    String? id,
    String? name,
    String? lastDigits,
    double? limit,
    int? closingDay,
    int? dueDay,
    String? brand,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCard(
      id: id ?? this.id,
      name: name ?? this.name,
      lastDigits: lastDigits ?? this.lastDigits,
      limit: limit ?? this.limit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastDigits': lastDigits,
      'cardLimit': limit,
      'closingDay': closingDay,
      'dueDay': dueDay,
      'brand': brand,
      'color': color,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'],
      name: json['name'],
      lastDigits: json['lastDigits'],
      limit: (json['cardLimit'] ?? json['limit'])?.toDouble() ?? 0.0,
      closingDay: json['closingDay'],
      dueDay: json['dueDay'],
      brand: json['brand'],
      color: json['color'],
      isActive: json['isActive'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  String get displayName => '$name •••• $lastDigits';

  DateTime getCurrentInvoiceDueDate() {
    final now = DateTime.now();
    var dueDate = DateTime(now.year, now.month, dueDay);

    // Se já passou o dia de vencimento, próxima fatura
    if (now.day > dueDay) {
      dueDate = DateTime(now.year, now.month + 1, dueDay);
    }

    return dueDate;
  }

  DateTime getCurrentInvoiceClosingDate() {
    final now = DateTime.now();
    var closingDate = DateTime(now.year, now.month, closingDay);

    // Se já passou o dia de fechamento, próxima fatura
    if (now.day > closingDay) {
      closingDate = DateTime(now.year, now.month + 1, closingDay);
    }

    return closingDate;
  }
}
