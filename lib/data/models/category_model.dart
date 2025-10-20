import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String iconCode;
  final bool isDefault;
  final String? createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.iconCode,
    this.isDefault = false,
    this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // Converter de entidade para modelo
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      color: category.color,
      iconCode: category.iconCode,
      isDefault: category.isDefault,
      createdByUserId: category.createdByUserId,
      createdAt: category.createdAt,
      updatedAt:
          DateTime.now(), // Adicionamos updatedAt quando criamos do entity
      isSynced: false,
    );
  }

  // Converter para entidade
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      color: color,
      iconCode: iconCode,
      isDefault: isDefault,
      createdByUserId: createdByUserId,
      createdAt: createdAt,
    );
  }

  // Converter para Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCode': iconCode,
      'color': color,
      'isDefault': isDefault ? 1 : 0,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Converter de Map (do SQLite)
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      iconCode: map['iconCode'] as String,
      color: map['color'] as String,
      isDefault: (map['isDefault'] as int) == 1,
      createdByUserId: map['createdByUserId'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isSynced: (map['isSynced'] as int) == 1,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconCode,
    String? color,
    bool? isDefault,
    String? createdByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
