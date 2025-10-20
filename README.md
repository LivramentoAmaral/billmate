# 💰 Billmate - Aplicativo de Gerenciamento Financeiro

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Clean%20Architecture-00D9FF?style=for-the-badge" alt="Clean Architecture" />
</p>

Um aplicativo Flutter para gerenciamento de finanças pessoais e em grupo, construído com Clean Architecture e funcionalidades completas de autenticação.

## 🚀 Funcionalidades Implementadas

### ✅ **Sistema de Autenticação Completo**
- **Login** com validação de email e senha
- **Registro** de novos usuários
- **Logout** seguro
- **Splash Screen** com verificação automática de autenticação
- **Navegação automática** baseada no estado de login

### ✅ **Interface de Usuário Moderna**
- **Material Design 3** com tema personalizado
- **Modo escuro/claro** (ThemeProvider)
- **Componentes customizados** (CustomTextField, CustomButton)
- **Navegação bottom navigation** com 4 abas principais
- **Animações** e feedback visual

### ✅ **Arquitetura Robusta**
- **Clean Architecture** com separação de camadas
- **Dependency Injection** com GetIt
- **State Management** com Provider
- **Repository Pattern** para abstração de dados
- **Use Cases** para lógica de negócio

## 📱 Como Usar o Aplicativo

### 1. **Primeira Execução**
```bash
cd /home/marcos-amaral/Documentos/meus-projetos-git/Billmate/billmate
flutter run
```

### 2. **Tela de Login**
Use uma das credenciais de teste disponíveis:

**Usuários de Teste:**
- **Email:** `joao@teste.com` | **Senha:** qualquer senha com 6+ caracteres
- **Email:** `maria@teste.com` | **Senha:** qualquer senha com 6+ caracteres

### 3. **Ou Crie uma Conta Nova**
- Clique em "Criar conta"
- Preencha: Nome, Email, Senha (6+ caracteres)
- Confirme a senha
- Sua conta será criada automaticamente!

### 4. **Navegação no App**
Após fazer login, você terá acesso a 4 abas:

#### 🏠 **Dashboard**
- Saudação personalizada
- Cards com resumo financeiro
- Ações rápidas para adicionar despesas e criar grupos

#### 📊 **Despesas**
- Gerenciamento de despesas (em desenvolvimento)
- Categorização e filtros

#### 👥 **Grupos**
- Criação e gerenciamento de grupos (em desenvolvimento)
- Compartilhamento de despesas

#### 👤 **Perfil**
- **Informações do usuário** (nome, email, data de cadastro)
- **Botão de logout** para sair da conta

## 🛠️ Comandos Úteis

### **Executar o App**
```bash
flutter run
```

### **Executar Testes**
```bash
flutter test
```

### **Análise de Código**
```bash
flutter analyze
```

### **Compilar para Android**
```bash
flutter build apk --debug
```

### **Limpar Build**
```bash
flutter clean && flutter pub get
```

## 🏗️ Arquitetura do Projeto

```
lib/
├── core/                    # Configurações e utilitários
│   ├── constants/          # Constantes da aplicação
│   ├── errors/             # Tratamento de erros
│   ├── utils/              # Utilitários e helpers
│   └── dependency_injection.dart
├── domain/                  # Camada de domínio (regras de negócio)
│   ├── entities/           # Entidades de negócio
│   ├── repositories/       # Interfaces dos repositórios
│   └── usecases/           # Casos de uso
├── data/                    # Camada de dados
│   ├── datasources/        # Fontes de dados (local/remoto)
│   ├── models/             # Modelos de dados
│   └── repositories/       # Implementação dos repositórios
└── presentation/            # Camada de apresentação
    ├── pages/              # Telas do aplicativo
    ├── widgets/            # Componentes reutilizáveis
    └── providers/          # Gerenciamento de estado
```

## 🎯 **Principais Tecnologias**

- **Flutter 3.5.3** - Framework multiplataforma
- **Provider** - Gerenciamento de estado
- **GetIt** - Injeção de dependência
- **SQLite** - Banco de dados local
- **Mock Data Source** - Autenticação local para desenvolvimento
- **Material Design 3** - Interface moderna

## 🔄 **Estado Atual**

### **✅ Funcionalidades Completas**
- Sistema de autenticação end-to-end
- Navegação entre telas
- Interface de usuário responsiva
- Arquitetura escalável
- Gerenciamento de estado

### **🚧 Em Desenvolvimento**
- CRUD completo de despesas
- Sistema de grupos e compartilhamento
- Gráficos e relatórios
- Sincronização em nuvem
- Notificações

## 📋 **Como Testar**

1. **Teste de Login:**
   - Use `joao@teste.com` com senha `123456`
   - Verifique se navega para HomePage

2. **Teste de Registro:**
   - Crie uma conta com email único
   - Verifique se faz login automaticamente

3. **Teste de Navegação:**
   - Teste todas as 4 abas
   - Verifique informações do perfil

4. **Teste de Logout:**
   - Clique em "Sair" no perfil
   - Verifique se volta para tela de login

## 🎉 **Status**

**✅ APLICAÇÃO FUNCIONANDO COMPLETAMENTE!**

O app está 100% funcional para as funcionalidades básicas de autenticação e navegação. Pronto para expansão com funcionalidades avançadas!

---

**Desenvolvido com ❤️ usando Flutter e Clean Architecture**
