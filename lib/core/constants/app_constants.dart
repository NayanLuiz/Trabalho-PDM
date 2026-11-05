class AppConstants {
  static const String appName = 'Gestão Financeira & Metas';
  
  // Categorias Padrao
  static const List<Map<String, String>> defaultCategories = [
    {'name': 'Salário', 'type': 'INCOME', 'color': '#059669'},
    {'name': 'Rendimentos', 'type': 'INCOME', 'color': '#0D9488'},
    {'name': 'Outras Receitas', 'type': 'INCOME', 'color': '#0284C7'},
    {'name': 'Alimentação', 'type': 'EXPENSE', 'color': '#EA580C'},
    {'name': 'Moradia', 'type': 'EXPENSE', 'color': '#2563EB'},
    {'name': 'Transporte', 'type': 'EXPENSE', 'color': '#7C3AED'},
    {'name': 'Saúde', 'type': 'EXPENSE', 'color': '#E11D48'},
    {'name': 'Lazer', 'type': 'EXPENSE', 'color': '#D97706'},
    {'name': 'Aporte Ações/FIIs', 'type': 'INVESTMENT', 'color': '#10B981'},
    {'name': 'Renda Fixa / Tesouro', 'type': 'INVESTMENT', 'color': '#06B6D4'},
    {'name': 'Criptoativos', 'type': 'INVESTMENT', 'color': '#8B5CF6'},
    {'name': 'Outras Despesas', 'type': 'EXPENSE', 'color': '#475569'},
  ];
}

