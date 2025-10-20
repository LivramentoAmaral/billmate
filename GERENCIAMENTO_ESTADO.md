# Guia de Gerenciamento de Estado Melhorado

## Resumo das Melhorias

O gerenciamento de estado da aplicação Billmate foi completamente refatorado para corrigir problemas de bugs e melhorar a performance e estabilidade.

## Mudanças Principais

### 1. BaseProvider
Criamos uma classe base `BaseProvider` que todos os providers estendem, fornecendo:

- **Controle automático de dispose**: Previne erros ao tentar notificar listeners após dispose
- **Debounce de notificações**: Reduz rebuilds desnecessários
- **Tratamento padronizado de erros**: Métodos `runAsync` e `runAsyncBool` para operações assíncronas
- **Estados de loading e error**: Gerenciamento centralizado de estados de carregamento e erro

### 2. Cache e Performance

Os providers agora implementam cache para evitar carregamentos duplicados:

**ExpenseProvider:**
- Cache de despesas por usuário e grupo
- Evita recarregar dados se já existirem
- Opção `forceRefresh` para atualizar dados quando necessário

**GroupProvider:**
- Cache de grupos por usuário
- Controle de grupo selecionado
- Sincronização automática ao alterar dados

**CategoryProvider:**
- Inicialização única de categorias
- Flag `isInitialized` para controlar estado

### 3. Providers como Singletons

Os providers foram mudados de `factory` para `lazySingleton` no GetIt, garantindo:
- Uma única instância por aplicação
- Estado compartilhado consistente
- Sem perda de dados ao navegar entre telas

### 4. Melhorias no AuthProvider

- Stream de autenticação com controle de ciclo de vida
- Flag `isInitialized` para saber quando o provider está pronto
- Getter `errorMessage` compatível com código existente
- Melhor controle de múltiplas notificações

## Como Usar

### Carregando Dados

#### Antes (problemático):
```dart
// Carregava sempre, mesmo se já tivesse dados
void initState() {
  super.initState();
  context.read<ExpenseProvider>().loadUserExpenses(userId);
}
```

#### Agora (otimizado):
```dart
void initState() {
  super.initState();
  // Carrega apenas se necessário (usa cache automaticamente)
  context.read<ExpenseProvider>().loadUserExpenses(userId);
  
  // Para forçar atualização:
  // context.read<ExpenseProvider>().loadUserExpenses(userId, forceRefresh: true);
}
```

### Verificando Estados

```dart
Consumer<ExpenseProvider>(
  builder: (context, provider, child) {
    // Verificar loading
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    // Verificar erro
    if (provider.hasError) {
      return Text('Erro: ${provider.error}');
    }
    
    // Usar dados
    return ListView(
      children: provider.expenses.map((expense) => ...).toList(),
    );
  },
)
```

### Aguardando Inicialização do AuthProvider

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    // Esperar inicialização
    if (!authProvider.isInitialized) {
      return CircularProgressIndicator();
    }
    
    if (authProvider.isAuthenticated) {
      return HomePage();
    }
    
    return LoginPage();
  },
)
```

### Limpando Cache Quando Necessário

```dart
// Ao fazer logout, limpar todos os dados
void logout() async {
  final authProvider = context.read<AuthProvider>();
  final expenseProvider = context.read<ExpenseProvider>();
  final groupProvider = context.read<GroupProvider>();
  
  await authProvider.signOut();
  expenseProvider.clearExpenses();
  groupProvider.clearCache();
}
```

## Boas Práticas

### 1. Use `context.read` para Ações

```dart
// Correto: não reconstrói o widget
onPressed: () {
  context.read<ExpenseProvider>().createExpense(...);
}

// Errado: reconstrói desnecessariamente
onPressed: () {
  context.watch<ExpenseProvider>().createExpense(...);
}
```

### 2. Use `Consumer` ou `context.watch` para UI

```dart
// Correto: reconstrói quando dados mudam
Consumer<ExpenseProvider>(
  builder: (context, provider, child) {
    return Text('Total: ${provider.currentMonthTotal}');
  },
)

// Ou com watch:
Widget build(BuildContext context) {
  final expenses = context.watch<ExpenseProvider>().expenses;
  return ListView(...);
}
```

### 3. Evite Carregar Dados no build()

```dart
// Errado: causa loops infinitos
Widget build(BuildContext context) {
  context.read<ExpenseProvider>().loadUserExpenses(userId); // ❌
  return ...;
}

// Correto: carregue no initState ou use FutureBuilder
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<ExpenseProvider>().loadUserExpenses(userId); // ✅
  });
}
```

### 4. Verifique Estados Antes de Usar Dados

```dart
// Correto: trata todos os casos
Consumer<ExpenseProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return LoadingWidget();
    if (provider.hasError) return ErrorWidget(provider.error);
    if (provider.expenses.isEmpty) return EmptyWidget();
    return DataWidget(provider.expenses);
  },
)
```

## Mixins Disponíveis

### CacheMixin<T>
Para providers que precisam de cache:

```dart
class MyProvider extends BaseProvider with CacheMixin<List<Data>> {
  Future<void> loadData() async {
    final cached = getCached('mykey');
    if (cached != null) {
      _data = cached;
      return;
    }
    
    final data = await _loadFromApi();
    setCached('mykey', data);
  }
}
```

### PaginationMixin<T>
Para providers com paginação (futuro):

```dart
class MyProvider extends BaseProvider with PaginationMixin<Item> {
  Future<void> loadMore() async {
    if (!hasMore) return;
    final newItems = await _loadPage(currentPage);
    addItems(newItems, pageSize: 20);
  }
}
```

## Debugging

### Verificar se Provider está Disposed

```dart
if (provider.isDisposed) {
  print('Provider foi disposed, não pode mais ser usado');
}
```

### Ver Logs de Erro

Os erros são automaticamente logados no console:
```
BaseProvider Error: Erro ao carregar despesas do usuário
```

## Problemas Comuns e Soluções

### Provider não atualiza a UI

**Causa**: Esqueceu de chamar `notifyListeners()` ou usar `Consumer`/`watch`

**Solução**: Sempre use `Consumer` ou `context.watch` para dados reativos

### Dados desaparecem ao navegar

**Causa**: Providers eram factory e criavam nova instância

**Solução**: ✅ Agora são singletons, problema resolvido!

### Loading infinito

**Causa**: Carregamento sendo chamado repetidamente

**Solução**: O sistema de cache agora previne isso automaticamente

### Erro "Don't use BuildContext across async gaps"

**Causa**: Usar context depois de operação assíncrona

**Solução**: 
```dart
// Errado:
await someAsyncOperation();
Navigator.push(context, ...); // ❌

// Correto:
if (!mounted) return;
Navigator.push(context, ...); // ✅

// Ou melhor ainda, use os métodos do BaseProvider
await runAsync(operation: () async {
  // operação assíncrona
  // notifyListeners é chamado automaticamente
});
```

## Próximos Passos

1. Migrar todos os widgets para usar o novo sistema
2. Adicionar testes unitários para providers
3. Implementar retry automático em caso de erro
4. Adicionar analytics de performance

## Suporte

Se encontrar problemas:
1. Verifique se o provider está inicializado corretamente
2. Verifique os logs no console
3. Use `provider.error` para ver mensagens de erro
4. Confirme que está usando `Consumer` ou `watch` para dados reativos
