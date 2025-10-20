# 💰 Billmate - Aplicativo de Gerenciamento Financeiro

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Clean%20Architecture-00D9FF?style=for-the-badge" alt="Clean Architecture" />
  <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white" alt="MongoDB" />
</p>

**Billmate** é um aplicativo Flutter completo para gerenciamento de finanças pessoais e compartilhadas em grupo. Construído seguindo princípios de **Clean Architecture**, com sistema robusto de gerenciamento de estado e suporte a múltiplas plataformas.

## ✨ Principais Diferenciais

- 🏗️ **Arquitetura escalável** seguindo Clean Architecture e SOLID
- 🔄 **Gerenciamento de estado otimizado** com Provider + BaseProvider customizado
- 💾 **Dual persistence** - SQLite (local) e MongoDB (remoto)
- 👥 **Compartilhamento em grupo** com sincronização em tempo real
- 📊 **Relatórios visuais** com gráficos interativos
- 🎨 **UI/UX moderna** com Material Design 3
- 🔐 **Autenticação segura** com Firebase Auth

## 🚀 Funcionalidades Implementadas

### ✅ **Sistema de Autenticação**
- Login com validação de email e senha
- Registro de novos usuários com verificação
- Logout seguro com limpeza de sessão
- Splash screen com verificação automática
- Persistência de sessão
- Recuperação de senha

### ✅ **Gerenciamento de Despesas**
- Criar, editar e excluir despesas
- Categorização customizável
- Anexar comprovantes (imagens)
- Filtros por período, categoria e status
- Despesas pessoais e compartilhadas
- Status de pagamento (pago/pendente/vencido)
- Divisão proporcional entre membros

### ✅ **Sistema de Grupos**
- Criar e gerenciar grupos
- Adicionar/remover membros
- Controle de permissões (admin/membro)
- Compartilhar código QR para convite
- Visualizar membros e suas despesas
- Relatórios consolidados do grupo
- Sincronização automática

### ✅ **Categorias e Organização**
- Categorias padrão pré-configuradas
- Criar categorias personalizadas
- Ícones e cores customizáveis
- Categorização automática (futuro)

### ✅ **Relatórios e Análises**
- Gráficos de despesas por categoria
- Relatórios mensais e anuais
- Análise de tendências de gastos
- Comparativos entre períodos
- Exportação de relatórios

### ✅ **Interface e Experiência**
- Material Design 3 moderno
- Modo escuro/claro
- Componentes reutilizáveis customizados
- Navegação intuitiva com bottom navigation
- Animações fluidas
- Feedback visual em tempo real
- Responsivo para tablets

### ✅ **Arquitetura e Qualidade**
- Clean Architecture (Domain, Data, Presentation)
- Dependency Injection com GetIt
- State Management otimizado com Provider
- Repository Pattern com cache inteligente
- Use Cases para lógica de negócio
- Tratamento robusto de erros
- Sistema de logging

## 📱 Início Rápido

### **Pré-requisitos**
- Flutter 3.5.3 ou superior
- Dart SDK 3.0+
- Android Studio / VS Code
- Git

### **Instalação**

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/billmate.git
cd billmate
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure o Firebase** (opcional para autenticação)
- Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
- Baixe o `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
- Coloque os arquivos nas pastas apropriadas

4. **Execute o aplicativo**
```bash
flutter run
```

### **Usuários de Teste**

Para facilitar o teste, o app vem com usuários pré-configurados:

| Email | Senha | Descrição |
|-------|-------|-----------|
| `joao@teste.com` | `123456` | Usuário com despesas pessoais |
| `maria@teste.com` | `123456` | Usuário com grupos compartilhados |
| `admin@teste.com` | `admin123` | Admin com acesso completo |

**Ou crie sua própria conta:**
1. Clique em "Criar conta" na tela de login
2. Preencha nome, email e senha (mínimo 6 caracteres)
3. Confirme a senha
4. Faça login automaticamente!

## 🎯 Como Usar

### **1. Dashboard (Home)**
- Visualize o resumo financeiro do mês
- Acesse ações rápidas (Nova despesa, Criar grupo)
- Veja suas despesas recentes
- Analise gastos por categoria

### **2. Despesas Pessoais**
- **Adicionar despesa:** Botão FAB (+)
  - Preencha descrição, valor, categoria
  - Anexe comprovante (opcional)
  - Defina data e status de pagamento
- **Filtrar:** Por período, categoria ou status
- **Editar/Excluir:** Toque na despesa
- **Compartilhar:** Gere relatório em PDF

### **3. Grupos**
- **Criar grupo:** 
  - Defina nome e descrição
  - Adicione membros por email
  - Escolha avatar do grupo
- **Gerenciar:**
  - Visualize membros
  - Altere permissões (admin/membro)
  - Compartilhe código QR para convite
- **Despesas compartilhadas:**
  - Adicione despesas ao grupo
  - Divida entre membros (igual ou customizado)
  - Acompanhe status de pagamento

### **4. Relatórios**
- Gráficos por categoria (pizza/barras)
- Comparativo mensal/anual
- Evolução de gastos
- Exportar para PDF/Excel

### **5. Perfil**
- Edite informações pessoais
- Altere senha
- Configure notificações
- Gerencie categorias personalizadas
- Faça logout

## 🏗️ Arquitetura do Projeto

O projeto segue **Clean Architecture** com separação clara de responsabilidades:

```
lib/
├── main.dart                           # Entry point da aplicação
│
├── core/                               # Configurações centrais
│   ├── constants/                      # Constantes globais
│   │   ├── app_colors.dart            # Paleta de cores
│   │   ├── app_strings.dart           # Textos e mensagens
│   │   └── app_routes.dart            # Rotas nomeadas
│   ├── errors/                         # Tratamento de erros
│   │   ├── failures.dart              # Classes de falha
│   │   └── exceptions.dart            # Exceções customizadas
│   ├── utils/                          # Utilitários
│   │   ├── validators.dart            # Validações de formulário
│   │   ├── formatters.dart            # Formatadores (moeda, data)
│   │   └── extensions.dart            # Extensions Dart
│   └── dependency_injection.dart       # Configuração GetIt
│
├── domain/                             # Camada de Domínio (Regras de Negócio)
│   ├── entities/                       # Entidades de negócio
│   │   ├── user.dart                  # Entidade Usuário
│   │   ├── expense.dart               # Entidade Despesa
│   │   ├── group.dart                 # Entidade Grupo
│   │   └── category.dart              # Entidade Categoria
│   ├── repositories/                   # Contratos de repositórios
│   │   ├── auth_repository.dart
│   │   ├── expense_repository.dart
│   │   ├── group_repository.dart
│   │   └── category_repository.dart
│   └── usecases/                       # Casos de uso (Use Cases)
│       ├── auth_usecases.dart         # Login, Registro, Logout
│       ├── expense_usecases.dart      # CRUD de despesas
│       ├── group_usecases.dart        # CRUD de grupos
│       └── category_usecases.dart     # CRUD de categorias
│
├── data/                               # Camada de Dados
│   ├── datasources/                    # Fontes de dados
│   │   ├── local/                     # Dados locais (SQLite)
│   │   │   ├── database_helper.dart
│   │   │   ├── expense_local_datasource.dart
│   │   │   ├── group_local_datasource.dart
│   │   │   └── category_local_datasource.dart
│   │   └── remote/                    # Dados remotos (API/Firebase)
│   │       ├── firebase_auth_datasource.dart
│   │       ├── expense_remote_datasource.dart
│   │       └── group_remote_datasource.dart
│   ├── models/                         # Modelos de dados (DTO)
│   │   ├── user_model.dart            # User + fromJson/toJson
│   │   ├── expense_model.dart
│   │   ├── group_model.dart
│   │   └── category_model.dart
│   └── repositories/                   # Implementação dos repositórios
│       ├── auth_repository_impl.dart
│       ├── sqlite_expense_repository.dart
│       ├── sqlite_group_repository.dart
│       └── sqlite_category_repository.dart
│
└── presentation/                       # Camada de Apresentação (UI)
    ├── pages/                          # Telas do aplicativo
    │   ├── splash_page.dart           # Splash screen inicial
    │   ├── login_page.dart            # Tela de login
    │   ├── register_page.dart         # Tela de registro
    │   ├── home_page.dart             # Dashboard principal
    │   ├── personal_expenses_page.dart # Despesas pessoais
    │   ├── add_expense_page.dart      # Adicionar/editar despesa
    │   ├── groups_page.dart           # Lista de grupos
    │   ├── group_details_page.dart    # Detalhes do grupo
    │   ├── group_expenses_page.dart   # Despesas do grupo
    │   ├── group_members_page.dart    # Membros do grupo
    │   ├── reports_page.dart          # Relatórios e gráficos
    │   └── profile_page.dart          # Perfil do usuário
    ├── widgets/                        # Componentes reutilizáveis
    │   ├── custom_button.dart         # Botão customizado
    │   ├── custom_text_field.dart     # Campo de texto
    │   ├── expense_card.dart          # Card de despesa
    │   ├── category_icon.dart         # Ícone de categoria
    │   └── loading_indicator.dart     # Indicador de carregamento
    └── providers/                      # Gerenciamento de Estado
        ├── base_provider.dart         # Provider base com cache e debounce
        ├── auth_provider.dart         # Estado de autenticação
        ├── expense_provider.dart      # Estado de despesas
        ├── group_provider.dart        # Estado de grupos
        ├── category_provider.dart     # Estado de categorias
        └── theme_provider.dart        # Estado de tema (dark/light)
```

### **Fluxo de Dados**

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐      ┌──────────────┐
│ Presentation│ ───> │   Provider   │ ───> │  Use Case   │ ───> │  Repository  │
│   (UI)      │      │   (State)    │      │  (Business) │      │   (Data)     │
└─────────────┘      └──────────────┘      └─────────────┘      └──────────────┘
       ▲                     │                     │                     │
       │                     │                     │                     ▼
       │                     │                     │              ┌──────────────┐
       │                     │                     │              │  DataSource  │
       │                     │                     │              │ (SQLite/API) │
       │                     │                     │              └──────────────┘
       │                     ▼                     ▼
       └──────────────────── Notify ────────────────────────────────────┘
```

### **Princípios Aplicados**

- ✅ **SOLID:** Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- ✅ **DRY:** Don't Repeat Yourself - Código reutilizável
- ✅ **KISS:** Keep It Simple, Stupid - Simplicidade
- ✅ **Separation of Concerns:** Camadas bem definidas
- ✅ **Dependency Inversion:** Abstrações em vez de implementações concretas

## 🎨 Gerenciamento de Estado

O Billmate utiliza um sistema **customizado e otimizado** de gerenciamento de estado baseado em **Provider**:

### **BaseProvider**

Todos os providers herdam de `BaseProvider`, que oferece:

- ✅ **Controle de ciclo de vida** - Previne chamadas após dispose
- ✅ **Tratamento de erros padronizado** - Captura e expõe erros
- ✅ **Loading states automáticos** - Gerencia estados de carregamento
- ✅ **Debounce de notificações** - Reduz rebuilds desnecessários
- ✅ **Cache inteligente** (via mixin) - Evita requisições duplicadas
- ✅ **Paginação** (via mixin) - Suporte a listas paginadas

### **Exemplo de Uso**

```dart
// Provider
class ExpenseProvider extends BaseProvider with CacheMixin<List<Expense>> {
  Future<void> loadExpenses(String userId) async {
    // Verifica cache
    final cached = getCached('expenses_$userId');
    if (cached != null) return;
    
    // Carrega dados com tratamento automático
    final expenses = await runAsync(
      operation: () => getUserExpensesUseCase.execute(userId),
      errorMessage: 'Erro ao carregar despesas',
    );
    
    if (expenses != null) {
      setCached('expenses_$userId', expenses);
      notifyListeners();
    }
  }
}

// Widget
Consumer<ExpenseProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) return LoadingIndicator();
    if (provider.error != null) return ErrorWidget(provider.error);
    return ExpenseList(provider.expenses);
  },
)
```

📖 **Documentação completa:** Veja `GERENCIAMENTO_ESTADO.md` para guia detalhado

## 🛠️ Tecnologias e Pacotes

### **Core**
- `flutter`: ^3.5.3
- `dart`: ^3.0.0

### **State Management**
- `provider`: ^6.1.1
- `get_it`: ^7.6.4

### **Storage**
- `sqflite`: ^2.3.0
- `path_provider`: ^2.1.1
- `shared_preferences`: ^2.2.2

### **Firebase**
- `firebase_core`: ^2.24.2
- `firebase_auth`: ^4.15.3
- `firebase_messaging`: ^14.7.9

### **UI/UX**
- `flutter_localizations`: SDK
- `intl`: ^0.18.1
- `cached_network_image`: ^3.3.0
- `image_picker`: ^1.0.4
- `qr_flutter`: ^4.1.0
- `fl_chart`: ^0.65.0

### **Utilities**
- `uuid`: ^4.2.1
- `share_plus`: ^7.2.1

### **Development**
- `flutter_test`: SDK
- `flutter_lints`: ^3.0.0

## 📋 Comandos Úteis

### **Desenvolvimento**
```bash
# Executar em modo debug
flutter run

# Executar em dispositivo específico
flutter run -d <device-id>

# Hot reload (r no terminal)
# Hot restart (R no terminal)
```

### **Build**
```bash
# Android APK (debug)
flutter build apk --debug

# Android APK (release)
flutter build apk --release

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios --release
```

### **Testes e Qualidade**
```bash
# Executar todos os testes
flutter test

# Teste com coverage
flutter test --coverage

# Análise estática
flutter analyze

# Formatar código
dart format lib/

# Verificar dependências desatualizadas
flutter pub outdated
```

### **Manutenção**
```bash
# Limpar build
flutter clean

# Reinstalar dependências
flutter clean && flutter pub get

# Upgrade de dependências
flutter pub upgrade

# Verificar problemas
flutter doctor -v
```

## 🧪 Testes

### **Estrutura de Testes**
```
test/
├── unit/                    # Testes unitários
│   ├── domain/
│   │   ├── entities/       # Teste de entidades
│   │   └── usecases/       # Teste de casos de uso
│   ├── data/
│   │   ├── models/         # Teste de modelos
│   │   └── repositories/   # Teste de repositórios
│   └── presentation/
│       └── providers/      # Teste de providers
├── widget/                  # Testes de widgets
│   └── pages/              # Teste de telas
└── integration/            # Testes de integração
    └── flows/              # Fluxos completos
```

### **Executar Testes**
```bash
# Todos os testes
flutter test

# Testes unitários
flutter test test/unit/

# Testes de widget
flutter test test/widget/

# Com coverage
flutter test --coverage
flutter pub global activate coverage
genhtml coverage/lcov.info -o coverage/html
```

### **Boas Práticas de Teste**
- ✅ Use mocks para dependências externas
- ✅ Teste casos de sucesso e erro
- ✅ Mantenha testes isolados e independentes
- ✅ Use arrange-act-assert pattern
- ✅ Nomeie testes descritivamente

## 🔐 Segurança

### **Implementações de Segurança**
- ✅ Autenticação segura com Firebase Auth
- ✅ Validação de inputs no client e server
- ✅ Sanitização de dados
- ✅ Criptografia de dados sensíveis no SQLite
- ✅ Token-based authentication
- ✅ Controle de permissões por grupo
- ✅ Rate limiting em operações críticas

### **Boas Práticas**
- 🔒 Nunca commitar credenciais no Git
- 🔒 Use variáveis de ambiente para secrets
- 🔒 Mantenha dependências atualizadas
- 🔒 Implemente logout automático após inatividade
- 🔒 Valide permissões no backend

## 🐛 Troubleshooting

### **Problemas Comuns**

#### **1. Erro de build no Android**
```bash
# Limpar cache e rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### **2. Dependências desatualizadas**
```bash
flutter pub upgrade --major-versions
```

#### **3. Erro no Firebase**
- Verifique se `google-services.json` está na pasta correta
- Confirme que o package name está correto
- Reconfigure no Firebase Console se necessário

#### **4. SQLite não funciona**
```bash
# Desinstale e reinstale o app
flutter clean
flutter run --uninstall-first
```

#### **5. Estado não atualiza**
- Verifique se está usando `Consumer` ou `context.watch`
- Confirme que `notifyListeners()` é chamado
- Veja logs de erro no console
- Consulte `GERENCIAMENTO_ESTADO.md`

#### **6. Hot reload não funciona**
```bash
# Use hot restart
# Pressione 'R' no terminal (maiúsculo)
# Ou
flutter run --hot
```

## 📈 Roadmap

### **Versão 1.0 (Atual)**
- ✅ Sistema de autenticação completo
- ✅ CRUD de despesas pessoais
- ✅ Sistema de grupos
- ✅ Categorias customizáveis
- ✅ Relatórios básicos
- ✅ Interface responsiva

### **Versão 1.1 (Próxima)**
- 🔲 Notificações push
- 🔲 Lembretes de pagamento
- 🔲 Exportação de relatórios (PDF/Excel)
- 🔲 Backup automático
- 🔲 Sincronização multi-dispositivo

### **Versão 1.2**
- 🔲 Integração bancária (Open Banking)
- 🔲 Reconhecimento de recibos com OCR
- 🔲 Assistente virtual com IA
- 🔲 Metas financeiras
- 🔲 Análise preditiva de gastos

### **Versão 2.0**
- 🔲 Modo offline completo
- 🔲 Widgets para home screen
- 🔲 Apple Pay / Google Pay
- 🔲 Suporte a múltiplas moedas
- 🔲 Compartilhamento social

## 🤝 Contribuindo

Contribuições são bem-vindas! Siga estas diretrizes:

### **Como Contribuir**

1. **Fork o projeto**
2. **Crie uma branch** para sua feature
   ```bash
   git checkout -b feature/minha-feature
   ```
3. **Commit suas mudanças**
   ```bash
   git commit -m 'feat: adiciona nova funcionalidade'
   ```
4. **Push para a branch**
   ```bash
   git push origin feature/minha-feature
   ```
5. **Abra um Pull Request**

### **Padrões de Commit**

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `docs:` - Documentação
- `style:` - Formatação, ponto e vírgula, etc
- `refactor:` - Refatoração de código
- `test:` - Adição de testes
- `chore:` - Atualização de build, configs, etc

### **Code Style**

- Siga o [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` antes de commitar
- Formate código com `dart format`
- Adicione comentários em código complexo
- Escreva testes para novas features

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Autor

**Marcos Amaral**

- GitHub: [@seu-usuario](https://github.com/seu-usuario)
- LinkedIn: [Seu Nome](https://linkedin.com/in/seu-perfil)
- Email: seu-email@example.com

## 🙏 Agradecimentos

- Flutter Team pela excelente documentação
- Comunidade Flutter Brasil
- Todos os contribuidores open-source

## 📞 Suporte

Encontrou um bug? Tem uma sugestão?

- 🐛 **Issues:** [GitHub Issues](https://github.com/seu-usuario/billmate/issues)
- 💬 **Discussões:** [GitHub Discussions](https://github.com/seu-usuario/billmate/discussions)
- 📧 **Email:** suporte@billmate.com

## � Status do Projeto

**✅ APLICAÇÃO PRONTA PARA PRODUÇÃO**

O Billmate está completamente funcional com:
- ✅ Arquitetura robusta e escalável
- ✅ Sistema de autenticação seguro
- ✅ Gerenciamento de estado otimizado
- ✅ CRUD completo de despesas e grupos
- ✅ Interface moderna e responsiva
- ✅ Persistência dual (local + remoto)
- ✅ Tratamento robusto de erros
- ✅ Documentação completa

---

<p align="center">
  <strong>Desenvolvido com ❤️ usando Flutter e Clean Architecture</strong>
  <br>
  <sub>© 2025 Billmate - Todos os direitos reservados</sub>
</p>

<p align="center">
  <a href="#-billmate---aplicativo-de-gerenciamento-financeiro">⬆ Voltar ao topo</a>
</p>
