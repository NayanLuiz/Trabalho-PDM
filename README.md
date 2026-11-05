# Gestão Financeira Pessoal & Metas (Investimentos e Patrimônio)

Projeto desenvolvido para a disciplina de **Programação para Dispositivos Móveis (PDM 2026.2 - UFRN)**, ministrada pelo Prof. Taniro Chacon Rodrigues.

Segue as diretrizes da [Flutter App Architecture](https://docs.flutter.dev/app-architecture) e o padrão MVVM com fluxo unidirecional de dados (UDF) de referência (`todo_app_arch`).

---

## 🏗️ Arquitetura em Camadas (MVVM)

```
lib/
├── core/                         # Utilitários globais (Money em centavos, Datas Civis, Temas)
├── domain/                       # Camada de Domínio / Lógica Pura
│   ├── models/                   # Entidades (Account, CreditCard, Transaction, Goal, Budget)
│   └── use_cases/                # Casos de Uso (Patrimônio Líquido, Recorrência, Alertas de Teto)
├── data/                         # Camada de Dados (Model Layer)
│   ├── services/
│   │   ├── local/                # SQLite (Offline-First), Biometria/PIN, Notificações Locais
│   │   ├── remote/               # Firebase Auth (Email/Senha e Google), Firestore Sync Híbrido
│   │   └── export/               # Exportação de Extratos em PDF e Planilhas CSV
│   └── repositories/             # SSOT (Account, Transaction, Category, Goal, Budget)
└── ui/                           # Camada de Apresentação (Views & ViewModels 1:1)
    ├── auth/                     # LoginView, PinLockView <-> AuthViewModel
    ├── dashboard/                # DashboardView, Gráficos fl_chart <-> DashboardViewModel
    ├── accounts_cards/           # AccountsView <-> AccountsViewModel
    ├── transactions/             # TransactionsView, Form <-> TransactionsViewModel
    ├── goals/                    # GoalsView <-> GoalsViewModel
    ├── budgets/                  # BudgetsView <-> BudgetsViewModel
    ├── reports/                  # ReportsView (PDF/CSV)
    ├── settings/                 # SettingsView (Tema Escuro, Biometria, Sync) <-> SettingsViewModel
    └── home/                     # HomeNavScaffold (Navegação principal)
```

---

## 🎨 Integração com Stitch (UI / UX)

A interface e a experiência do usuário (UI/UX) foram projetadas no **Stitch**.

A camada de apresentação foi modelada com contratos estritos:
- Toda tela consome seu **ViewModel** correspondente via `context.watch<TViewModel>()`.
- Ações do usuário disparam métodos/comandos no ViewModel (`context.read<TViewModel>()`).
- Ao exportar ou renderizar os componentes do Stitch em Flutter, basta plugar os widgets nos ViewModels já instanciados no `MultiProvider` global.

---

## 💼 Regras de Negócio e Requisitos Atendidos

1. **Cadastro, Login e Segurança:** Firebase Authentication (E-mail/senha e Google) com bloqueio por biometria e PIN local (`LocalAuthService`).
2. **Contas e Cartões:** Múltiplas carteiras (Conta Corrente, Poupança, Dinheiro, Investimentos) e cartões de crédito com controle de fechamento e vencimento de fatura.
3. **Transações & Comprovantes:** Lançamentos de Receita, Despesa e Aporte (Investimentos), suporte a parcelamentos/recorrência e anexo de comprovante fotográfico/PDF (`image_picker`).
4. **Persistência Offline-First & Nuvem:** SQLite local como fonte primária da verdade e sincronização bidirecional em segundo plano com Firebase Cloud Firestore.
5. **Dashboard & fl_chart:** Gráfico de barras (Receitas x Despesas), gráfico de pizza (despesas por categoria) e gráfico de linha (evolução patrimonial).
6. **Metas & Caixinhas:** Metas financeiras com barra de progresso, depósitos e monitoramento de tetos de despesas com alertas locais automáticos aos 80% e 100%.
7. **Exportação de Extratos:** Geração mensal em PDF e CSV com compartilhamento nativo (`share_plus`).
8. **Dark Mode:** Suporte a tema claro, escuro ou sincronizado com o sistema operacional via `SharedPreferences`.

---

## 🧪 Testes Unitários

Executar a suíte de testes de casos de uso e domínio:
```bash
flutter test
```
- `test/unit/money_utils_test.dart`: precisão de centavos inteiros e formatação BRL.
- `test/unit/civil_date_utils_test.dart`: manipulação de datas sem desvio de fuso e clamping mensal.
- `test/unit/calculate_net_worth_use_case_test.dart`: cálculo de patrimônio líquido (ativos vs passivos).
- `test/unit/check_budget_limit_use_case_test.dart`: validação e disparos de alertas de teto (80% e 100%).

