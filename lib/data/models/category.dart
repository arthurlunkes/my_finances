class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final bool isIncome;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isIncome = false,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isIncome': isIncome ? 1 : 0,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      isIncome: json['isIncome'] == 1,
      isDefault: json['isDefault'] == 1,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    bool? isIncome,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isIncome: isIncome ?? this.isIncome,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

// Categorias padrão
class DefaultCategories {
  static final List<Category> expenseCategories = [
    Category(
      id: 'cat_housing',
      name: 'Moradia',
      icon: '🏠',
      color: 'FF6B6B',
      isDefault: true,
    ),
    Category(
      id: 'cat_transport',
      name: 'Transporte',
      icon: '🚗',
      color: '4ECDC4',
      isDefault: true,
    ),
    Category(
      id: 'cat_food',
      name: 'Alimentação',
      icon: '🍔',
      color: 'FFD93D',
      isDefault: true,
    ),
    Category(
      id: 'cat_health',
      name: 'Saúde',
      icon: '⚕️',
      color: '95E1D3',
      isDefault: true,
    ),
    Category(
      id: 'cat_education',
      name: 'Educação',
      icon: '📚',
      color: 'A8E6CF',
      isDefault: true,
    ),
    Category(
      id: 'cat_entertainment',
      name: 'Lazer',
      icon: '🎮',
      color: 'C7CEEA',
      isDefault: true,
    ),
    Category(
      id: 'cat_shopping',
      name: 'Compras',
      icon: '🛍️',
      color: 'FFDAC1',
      isDefault: true,
    ),
    Category(
      id: 'cat_bills',
      name: 'Contas',
      icon: '📄',
      color: 'B5EAD7',
      isDefault: true,
    ),
    Category(
      id: 'cat_tithe',
      name: 'Dízimo',
      icon: '⛪',
      color: 'FFB300',
      isDefault: true,
    ),
    Category(
      id: 'cat_offering',
      name: 'Oferta',
      icon: '🙏',
      color: 'FF6F00',
      isDefault: true,
    ),
    Category(
      id: 'cat_other',
      name: 'Outros',
      icon: '📦',
      color: '9E9E9E',
      isDefault: true,
    ),
  ];

  static final List<Category> incomeCategories = [
    Category(
      id: 'cat_salary',
      name: 'Salário',
      icon: '💰',
      color: '4CAF50',
      isIncome: true,
      isDefault: true,
    ),
    Category(
      id: 'cat_extra',
      name: 'Renda Extra',
      icon: '💵',
      color: '66BB6A',
      isIncome: true,
      isDefault: true,
    ),
    Category(
      id: 'cat_investment',
      name: 'Investimento',
      icon: '📈',
      color: '81C784',
      isIncome: true,
      isDefault: true,
    ),
    Category(
      id: 'cat_bonus',
      name: 'Bônus',
      icon: '🎁',
      color: '26A69A',
      isIncome: true,
      isDefault: true,
    ),
    Category(
      id: 'cat_other_income',
      name: 'Outros',
      icon: '💳',
      color: '00897B',
      isIncome: true,
      isDefault: true,
    ),
  ];

  static List<Category> get all => [...expenseCategories, ...incomeCategories];
}
