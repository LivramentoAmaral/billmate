# 🚀 Reset do Banco de Dados - Guia Rápido

## Para Resetar Agora (Mais Fácil):

### Opção 1: Uninstall Completo (MAIS SEGURO)
```bash
cd /home/marcos-amaral/Documentos/meus-projetos-git/Billmate/billmate
flutter clean
flutter pub get
flutter run --uninstall-first
```

Isso vai:
1. ✅ Limpar o cache
2. ✅ Deletar o app do dispositivo/emulador
3. ✅ Reinstalar do zero
4. ✅ Banco vazio e recriado automaticamente
5. ✅ Categorias padrão adicionadas

### Opção 2: Apenas Delete via Code
Se o app já está rodando, abra o **Dart DevTools** e execute:

```dart
import 'package:billmate/data/datasources/local_database.dart';
import 'package:billmate/core/database_reset.dart';

// Resetar com dados padrão
await resetDatabaseForDevelopment();

// OU apenas deletar
// await deleteDatabase();
```

---

## 📦 O que Será Criado

**9 Categorias Padrão:**
| Emoji | Nome | Descrição |
|-------|------|-----------|
| 🍔 | Alimentação | Comida e refeições |
| 🚗 | Transporte | Combustível e transporte |
| 🏥 | Saúde | Medicamentos e saúde |
| 📚 | Educação | Cursos e educação |
| 🎮 | Lazer | Entretenimento |
| 💡 | Utilidades | Água, luz, internet |
| 👕 | Roupas | Roupas e acessórios |
| 🏠 | Casa | Mobília e manutenção |
| 💰 | Outros | Despesas diversas |

**Banco de Dados:**
- ✅ Todas as 6 tabelas criadas
- ✅ Índices de performance
- ✅ Chaves estrangeiras configuradas
- ✅ Pronto para uso

---

## 🎯 Recomendação

**Use a Opção 1** (uninstall completo) - é a mais limpa e garante que tudo será recriado do zero.

Você pode rodar vários testes assim sem problema!

---

## 📝 Arquivo de Configuração

Se quiser adicionar mais categorias ou dados padrão, edite:
- `lib/core/database_reset.dart` - Função `resetDatabaseWithDefaults()`
- `lib/data/datasources/local_database.dart` - Função `resetDatabaseWithDefaults()`
