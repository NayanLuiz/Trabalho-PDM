import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return; // Notificacoes locais sao desativadas no modo Web de desenvolvimento

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(initializationSettings);
    } catch (_) {
      // Falha silenciosa caso emulador/dispositivo nao tenha icone padrao
    }
  }

  Future<void> showBudgetWarningNotification({
    required int id,
    required String categoryName,
    required double percentage,
  }) async {
    if (kIsWeb) return;

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'budget_alerts_channel',
        'Alertas de Orçamento',
        channelDescription: 'Avisos quando o teto de gastos atinge 80% ou 100%',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      final String title = percentage >= 100.0
          ? '⚠️ Teto Excedido: $categoryName'
          : '🔔 Alerta de Orçamento: $categoryName';

      final String body = percentage >= 100.0
          ? 'Você ultrapassou 100% do limite configurado para esta categoria!'
          : 'Você atingiu ${percentage.toStringAsFixed(0)}% do teto mensal da categoria.';

      await _notificationsPlugin.show(id, title, body, notificationDetails);
    } catch (_) {}
  }
}
