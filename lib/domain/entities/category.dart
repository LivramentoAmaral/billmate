import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String iconCode;
  final bool isDefault;
  final String? createdByUserId;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.iconCode,
    this.isDefault = false,
    this.createdByUserId,
    required this.createdAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? iconCode,
    bool? isDefault,
    String? createdByUserId,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      iconCode: iconCode ?? this.iconCode,
      isDefault: isDefault ?? this.isDefault,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'iconCode': iconCode,
      'isDefault': isDefault,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      color: map['color'] ?? '',
      iconCode: map['iconCode'] ?? '',
      isDefault: map['isDefault'] ?? false,
      createdByUserId: map['createdByUserId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  factory Category.create({
    required String name,
    String? description,
    required String color,
    required String iconCode,
    bool isDefault = false,
    String? createdByUserId,
  }) {
    return Category(
      id: const Uuid().v4(),
      name: name,
      description: description,
      color: color,
      iconCode: iconCode,
      isDefault: isDefault,
      createdByUserId: createdByUserId,
      createdAt: DateTime.now(),
    );
  }

  // Categorias predefinidas
  static Category get alimentacao => Category.create(
        name: 'Alimentação',
        color: '#FF9800',
        iconCode: '0xe59a',
        isDefault: true,
      );

  static Category get transporte => Category.create(
        name: 'Transporte',
        color: '#2196F3',
        iconCode: '0xe59b',
        isDefault: true,
      );

  static Category get moradia => Category.create(
        name: 'Moradia',
        color: '#4CAF50',
        iconCode: '0xe59c',
        isDefault: true,
      );

  static Category get saude => Category.create(
        name: 'Saúde',
        color: '#F44336',
        iconCode: '0xe59d',
        isDefault: true,
      );

  static Category get educacao => Category.create(
        name: 'Educação',
        color: '#9C27B0',
        iconCode: '0xe59e',
        isDefault: true,
      );

  static Category get lazer => Category.create(
        name: 'Lazer',
        color: '#E91E63',
        iconCode: '0xe59f',
        isDefault: true,
      );

  static Category get compras => Category.create(
        name: 'Compras',
        color: '#673AB7',
        iconCode: '0xe5a0',
        isDefault: true,
      );

  static Category get servicos => Category.create(
        name: 'Serviços',
        color: '#607D8B',
        iconCode: '0xe5a1',
        isDefault: true,
      );

  static Category get outros => Category.create(
        name: 'Outros',
        color: '#795548',
        iconCode: '0xe5a2',
        isDefault: true,
      );

  static List<Category> get defaultCategories => [
        alimentacao,
        transporte,
        moradia,
        saude,
        educacao,
        lazer,
        compras,
        servicos,
        outros,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }
}
