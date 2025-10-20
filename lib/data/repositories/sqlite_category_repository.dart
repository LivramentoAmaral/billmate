import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local_database.dart';
import '../models/category_model.dart';

class SqliteCategoryRepository implements CategoryRepository {
  final LocalDatabase _database;

  SqliteCategoryRepository(this._database);

  @override
  Future<Category?> getCategoryById(String id) async {
    final db = await _database.database;
    final results = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;

    final categoryModel = CategoryModel.fromMap(results.first);
    return categoryModel.toEntity();
  }

  @override
  Future<List<Category>> getAllCategories() async {
    print('SqliteCategoryRepository: Obtendo todas as categorias...');
    final db = await _database.database;
    final results = await db.query(
      'categories',
      orderBy: 'isDefault DESC, name ASC',
    );
    print(
        'SqliteCategoryRepository: ${results.length} registros encontrados no banco');

    final categories =
        results.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
    print(
        'SqliteCategoryRepository: ${categories.length} categorias convertidas');
    for (var cat in categories) {
      print('  - ${cat.name} (${cat.id}, isDefault: ${cat.isDefault})');
    }
    return categories;
  }

  @override
  Future<List<Category>> getDefaultCategories() async {
    final db = await _database.database;
    final results = await db.query(
      'categories',
      where: 'isDefault = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return results.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<List<Category>> getUserCategories(String userId) async {
    final db = await _database.database;
    final results = await db.query(
      'categories',
      where: 'createdByUserId = ? OR isDefault = ?',
      whereArgs: [userId, 1],
      orderBy: 'isDefault DESC, name ASC',
    );

    return results.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<Category?> createCategory(Category category) async {
    final db = await _database.database;

    final categoryModel = CategoryModel.fromEntity(category);

    try {
      await db.insert(
        'categories',
        categoryModel.toMap(),
      );
      return category;
    } catch (e) {
      print('Error creating category: $e');
      return null;
    }
  }

  @override
  Future<Category?> updateCategory(Category category) async {
    final db = await _database.database;

    final categoryModel =
        CategoryModel.fromEntity(category).copyWith(updatedAt: DateTime.now());

    try {
      final count = await db.update(
        'categories',
        categoryModel.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );

      if (count > 0) {
        return categoryModel.toEntity();
      }
      return null;
    } catch (e) {
      print('Error updating category: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteCategory(String id) async {
    final db = await _database.database;

    try {
      // Verificar se a categoria não está sendo usada em despesas
      final expenseCount = await db.query(
        'expenses',
        where: 'categoryId = ?',
        whereArgs: [id],
      );

      if (expenseCount.isNotEmpty) {
        print('Cannot delete category: it is being used by expenses');
        return false;
      }

      final count = await db.delete(
        'categories',
        where: 'id = ? AND isDefault = ?',
        whereArgs: [id, 0], // Só permite deletar categorias não-padrão
      );

      return count > 0;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  @override
  Future<void> syncCategory(Category category) async {
    final db = await _database.database;

    final categoryModel = CategoryModel.fromEntity(category).copyWith(
      isSynced: true,
      updatedAt: DateTime.now(),
    );

    try {
      await db.update(
        'categories',
        categoryModel.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      print('Error syncing category: $e');
    }
  }

  @override
  Future<void> initializeDefaultCategories() async {
    print('SqliteCategoryRepository: Verificando categorias padrão...');
    final existingCategories = await getDefaultCategories();
    print(
        'SqliteCategoryRepository: ${existingCategories.length} categorias padrão existentes');

    if (existingCategories.isNotEmpty) {
      print(
          'SqliteCategoryRepository: Categorias padrão já existem, pulando inicialização');
      return; // Categorias padrão já existem
    }

    print('SqliteCategoryRepository: Criando categorias padrão...');
    final defaultCategories = [
      Category(
        id: 'default-food',
        name: 'Alimentação',
        description: 'Despesas com comida e bebida',
        color: '#FF6B6B',
        iconCode: '🍽️',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'default-transport',
        name: 'Transporte',
        description: 'Despesas com locomoção',
        color: '#4ECDC4',
        iconCode: '🚗',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'default-housing',
        name: 'Moradia',
        description: 'Despesas com habitação',
        color: '#45B7D1',
        iconCode: '🏠',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'default-health',
        name: 'Saúde',
        description: 'Despesas médicas e farmácia',
        color: '#96CEB4',
        iconCode: '🏥',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'default-education',
        name: 'Educação',
        description: 'Despesas com ensino e cursos',
        color: '#FFEAA7',
        iconCode: '📚',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'default-entertainment',
        name: 'Lazer',
        description: 'Despesas com entretenimento',
        color: '#DDA0DD',
        iconCode: '🎮',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'default-shopping',
        name: 'Compras',
        description: 'Despesas com compras diversas',
        color: '#FAB1A0',
        iconCode: '🛍️',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'default-services',
        name: 'Serviços',
        description: 'Despesas com serviços diversos',
        color: '#81ECEC',
        iconCode: '⚙️',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'default-others',
        name: 'Outros',
        description: 'Outras despesas não categorizadas',
        color: '#B2BEC3',
        iconCode: '📋',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
    ];

    print(
        'SqliteCategoryRepository: Criando ${defaultCategories.length} categorias padrão...');
    for (final category in defaultCategories) {
      print('SqliteCategoryRepository: Criando categoria: ${category.name}');
      final result = await createCategory(category);
      if (result != null) {
        print(
            'SqliteCategoryRepository: Categoria criada com sucesso: ${category.name}');
      } else {
        print(
            'SqliteCategoryRepository: Falha ao criar categoria: ${category.name}');
      }
    }
    print(
        'SqliteCategoryRepository: Inicialização das categorias padrão concluída');
  }

  @override
  Stream<List<Category>> watchCategories() async* {
    // Por simplicidade, implementamos uma versão básica
    // Em uma implementação mais avançada, poderíamos usar um stream controller
    // que reage a mudanças no banco de dados
    yield await getAllCategories();
  }
}
