import 'dart:async';
import 'package:flutter/foundation.dart';

/// Classe base para providers com gerenciamento de estado robusto
abstract class BaseProvider extends ChangeNotifier {
  bool _isDisposed = false;
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isDisposed => _isDisposed;

  /// Notifica listeners com debounce opcional
  @protected
  void notifyListenersDebounced(
      {Duration delay = const Duration(milliseconds: 50)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  /// Notifica listeners se não foi disposed
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  /// Define o estado de loading
  @protected
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Define um erro
  @protected
  void setError(String? error) {
    if (_error != error) {
      _error = error;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpa o erro
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Executa uma operação assíncrona com tratamento de erro automático
  @protected
  Future<T?> runAsync<T>({
    required Future<T> Function() operation,
    String? errorMessage,
    bool showLoading = true,
    bool clearErrorOnStart = true,
  }) async {
    try {
      if (clearErrorOnStart) {
        _error = null;
      }
      if (showLoading) {
        setLoading(true);
      }

      final result = await operation();

      if (showLoading) {
        setLoading(false);
      }

      return result;
    } catch (e) {
      final message = errorMessage ?? 'Erro ao executar operação: $e';
      setError(message);
      debugPrint('BaseProvider Error: $message');
      return null;
    }
  }

  /// Executa uma operação assíncrona e retorna sucesso/falha
  @protected
  Future<bool> runAsyncBool({
    required Future<bool> Function() operation,
    String? errorMessage,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        setLoading(true);
      }
      _error = null;

      final result = await operation();

      if (showLoading) {
        setLoading(false);
      }

      return result;
    } catch (e) {
      final message = errorMessage ?? 'Erro ao executar operação: $e';
      setError(message);
      debugPrint('BaseProvider Error: $message');
      return false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Mixin para providers que precisam de cache
mixin CacheMixin<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  Duration cacheDuration = const Duration(minutes: 5);

  T? getCached(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.value;
    }
    _cache.remove(key);
    return null;
  }

  void setCached(String key, T value) {
    _cache[key] = CacheEntry(value, DateTime.now().add(cacheDuration));
  }

  void clearCache() {
    _cache.clear();
  }

  void clearCacheKey(String key) {
    _cache.remove(key);
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  CacheEntry(this.value, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Mixin para providers que precisam de paginação
mixin PaginationMixin<T> {
  List<T> _items = [];
  bool _hasMore = true;
  int _currentPage = 0;

  List<T> get items => _items;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  void resetPagination() {
    _items.clear();
    _hasMore = true;
    _currentPage = 0;
  }

  void addItems(List<T> newItems, {int? pageSize}) {
    _items.addAll(newItems);
    _currentPage++;

    if (pageSize != null) {
      _hasMore = newItems.length >= pageSize;
    } else {
      _hasMore = newItems.isNotEmpty;
    }
  }

  void clearItems() {
    _items.clear();
    _hasMore = true;
    _currentPage = 0;
  }
}
