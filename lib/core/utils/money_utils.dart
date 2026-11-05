import 'package:intl/intl.dart';

/// Utilitario para manipulacao financeira estrita em centavos inteiros (RNF-1).
/// Evita erros de arredondamento inerentes a numeros de ponto flutuante.
class MoneyUtils {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  /// Converte centavos inteiros para string monetaria BRL formatada (ex: 125050 -> "R$ 1.250,50").
  static String formatCents(int amountCents) {
    final double value = amountCents / 100.0;
    return _currencyFormat.format(value);
  }

  /// Converte valor formatado ou string numerica para centavos inteiros.
  static int parseToCents(String input) {
    if (input.trim().isEmpty) return 0;
    
    // Remove simbolos de moeda e espacos
    String cleaned = input
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final double? parsed = double.tryParse(cleaned);
    if (parsed == null) return 0;
    return (parsed * 100).round();
  }

  /// Retorna o percentual inteiro ou decimal com 2 casas
  static double calculatePercentage(int partCents, int totalCents) {
    if (totalCents <= 0) return 0.0;
    return double.parse(((partCents / totalCents) * 100).toStringAsFixed(2));
  }
}

