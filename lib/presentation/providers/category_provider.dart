import '../../domain/entities/category.dart' as domain;
import '../../domain/repositories/category_repository.dart';
import 'base_provider.dart';

class CategoryProvider extends BaseProvider {
  final CategoryRepository _categoryRepository;

  List<domain.Category> _categories = [];
  bool _isInitialized = false;

  List<domain.Category> get categories => List.unmodifiable(_categories);
  bool get isInitialized => _isInitialized;

  CategoryProvider(this._categoryRepository) {
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    if (_isInitialized || isDisposed) return;

    await runAsync(
      operation: () async {
        // Inicializar categorias padrão se não existirem
        await _categoryRepository.initializeDefaultCategories();

        // Carregar todas as categorias
        final categories = await _categoryRepository.getAllCategories();

        if (!isDisposed) {
          _categories = categories;
          _isInitialized = true;
        }
      },
      errorMessage: 'Erro ao inicializar categorias',
      showLoading: true,
    );
  }

  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _categories.isNotEmpty) return;

    final categories = await runAsync<List<domain.Category>>(
      operation: () => _categoryRepository.getAllCategories(),
      errorMessage: 'Erro ao carregar categorias',
      showLoading: true,
    );

    if (!isDisposed && categories != null) {
      _categories = categories;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> loadUserCategories(String userId) async {
    final categories = await runAsync<List<domain.Category>>(
      operation: () => _categoryRepository.getUserCategories(userId),
      errorMessage: 'Erro ao carregar categorias do usuário',
      showLoading: true,
    );

    if (!isDisposed && categories != null) {
      _categories = categories;
      notifyListeners();
    }
  }

  domain.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  domain.Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addCustomCategory(domain.Category category) async {
    return await runAsyncBool(
      operation: () async {
        final createdCategory =
            await _categoryRepository.createCategory(category);
        if (!isDisposed && createdCategory != null) {
          _categories.add(createdCategory);
          notifyListeners();
          return true;
        }
        return false;
      },
      errorMessage: 'Erro ao criar categoria',
      showLoading: false,
    );
  }

  Future<bool> removeCategory(String categoryId) async {
    final category = getCategoryById(categoryId);
    if (category == null || category.isDefault) {
      setError('Não é possível remover categorias padrão');
      return false;
    }

    return await runAsyncBool(
      operation: () async {
        final success = await _categoryRepository.deleteCategory(categoryId);
        if (!isDisposed && success) {
          _categories.removeWhere((cat) => cat.id == categoryId);
          notifyListeners();
          return true;
        }
        return false;
      },
      errorMessage: 'Erro ao remover categoria',
      showLoading: false,
    );
  }

  Future<bool> updateCategory(domain.Category updatedCategory) async {
    return await runAsyncBool(
      operation: () async {
        final result =
            await _categoryRepository.updateCategory(updatedCategory);
        if (!isDisposed && result != null) {
          final index =
              _categories.indexWhere((cat) => cat.id == updatedCategory.id);
          if (index != -1) {
            _categories[index] = result;
            notifyListeners();
            return true;
          }
        }
        return false;
      },
      errorMessage: 'Erro ao atualizar categoria',
      showLoading: false,
    );
  }

  Future<void> forceInitializeDefaultCategories() async {
    await runAsync(
      operation: () async {
        await _categoryRepository.initializeDefaultCategories();
        final categories = await _categoryRepository.getAllCategories();
        if (!isDisposed) {
          _categories = categories;
          _isInitialized = true;
        }
      },
      errorMessage: 'Erro ao inicializar categorias padrão',
      showLoading: true,
    );
  }
}
