# 🔄 Resetar Banco de Dados - Billmate

## Como Resetar o Banco de Dados

### Opção 1: Resetar via Terminal (Recomendado)

1. **Abra o terminal/console do app rodando** (if you're using Chrome DevTools or similar)

2. **Execute este comando no Dart Debug Console:**

```dart
// Copie e cole isto no Dart Debug Console
import 'package:billmate/core/database_reset.dart';
resetDatabaseForDevelopment();
```

### Opção 2: Resetar Manualmente (Desenvolvimento)

1. **Desinstale o app completamente:**
```bash
flutter clean
flutter pub get
flutter run --uninstall-first
```

### Opção 3: Adicionar ao main.dart temporariamente

Descomente a linha abaixo no `main.dart` para executar o reset na primeira inicialização:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // DESCOMENTE PARA RESETAR: await resetDatabaseForDevelopment();
  
  await setupDependencies();
  runApp(BillmateApp());
}
```

---

## ✅ O que é Criado Após o Reset

### Categorias Padrão:
- **🍔 Alimentação** - Comida e refeições
- **🚗 Transporte** - Combustível e transporte
- **🏥 Saúde** - Medicamentos e saúde
- **📚 Educação** - Cursos e educação
- **🎮 Lazer** - Entretenimento
- **💡 Utilidades** - Água, luz, internet
- **👕 Roupas** - Roupas e acessórios
- **🏠 Casa** - Mobília e manutenção
- **💰 Outros** - Despesas diversas

### Banco de Dados:
- ✅ Todas as tabelas criadas (users, groups, expenses, categories, etc)
- ✅ Índices de performance adicionados
- ✅ Categorias padrão inseridas
- ✅ Pronto para usar!

---

## 📋 Estrutura do Banco

### Tabelas Criadas:
1. **users** - Usuários cadastrados
2. **groups_table** - Grupos de despesas
3. **group_members** - Membros dos grupos
4. **categories** - Categorias de despesas
5. **expenses** - Despesas registradas
6. **expense_participants** - Participantes de despesas

---

## 🛠️ Funções Disponíveis

### `resetDatabaseForDevelopment()`
- Deleta banco existente
- Recria todas as tabelas
- Adiciona categorias padrão
- Pronto para desenvolvimento

### `deleteDatabase()`
- Remove apenas o banco de dados
- Próxima inicialização vai recriar tudo vazio

---

## 📝 Nota Importante

Estes são **dados de desenvolvimento apenas**. Não use em produção sem cuidado.

Se precisar adicionar mais dados padrão, edite `lib/core/database_reset.dart`.
