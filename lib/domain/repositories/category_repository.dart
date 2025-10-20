import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Category?> getCategoryById(String id);
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getDefaultCategories();
  Future<List<Category>> getUserCategories(String userId);
  Future<Category?> createCategory(Category category);
  Future<Category?> updateCategory(Category category);
  Future<bool> deleteCategory(String id);
  Future<void> syncCategory(Category category);
  Future<void> initializeDefaultCategories();
  Stream<List<Category>> watchCategories();
}
