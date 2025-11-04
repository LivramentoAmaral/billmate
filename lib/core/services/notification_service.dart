import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Serviço de notificações do Billmate
/// Gerencia notificações push (Firebase) e locais
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Solicitar permissão para notificações
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Permissão de notificações concedida');
      } else {
        debugPrint('❌ Permissão de notificações negada');
        return;
      }

      // Configurar notificações locais
      await _initializeLocalNotifications();

      // Obter token FCM
      final token = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $token');

      // Configurar handlers de mensagens
      _setupMessageHandlers();

      _initialized = true;
    } catch (e) {
      debugPrint('❌ Erro ao inicializar notificações: $e');
    }
  }

  /// Inicializa notificações locais
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Configura handlers de mensagens do Firebase
  void _setupMessageHandlers() {
    // Mensagens em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          '📨 Mensagem recebida em foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Mensagens quando o app é aberto por uma notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          '📨 App aberto por notificação: ${message.notification?.title}');
      _handleNotificationTap(message.data);
    });

    // Verificar se o app foi aberto por uma notificação
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint(
            '📨 App iniciado por notificação: ${message.notification?.title}');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Exibe notificação local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'billmate_channel',
      'Billmate Notificações',
      channelDescription: 'Notificações do Billmate',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Callback quando notificação local é tocada
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📨 Notificação tocada: ${response.payload}');
    // Implementar navegação baseada no payload
  }

  /// Manipula o toque em notificações
  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('📨 Dados da notificação: $data');
    // Implementar lógica de navegação baseada nos dados
    // Exemplo: navegar para despesa específica, grupo, etc.
  }

  /// Agenda notificação local
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'billmate_scheduled',
      'Lembretes Billmate',
      channelDescription: 'Lembretes de pagamentos e despesas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTimezone(scheduledDate),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: data?.toString(),
    );
  }

  /// Agenda lembrete de pagamento
  Future<void> schedulePaymentReminder({
    required String expenseId,
    required String title,
    required DateTime dueDate,
  }) async {
    // Lembrete 1 dia antes
    final reminderDate = dueDate.subtract(const Duration(days: 1));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: expenseId.hashCode,
        title: '💰 Lembrete de Pagamento',
        body: 'A despesa "$title" vence amanhã!',
        scheduledDate: reminderDate,
        data: {'type': 'payment_reminder', 'expense_id': expenseId},
      );
    }
  }

  /// Cancela notificação agendada
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Envia notificação instantânea
  Future<void> showInstantNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'billmate_instant',
      'Notificações Instantâneas',
      channelDescription: 'Notificações imediatas do Billmate',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: data?.toString(),
    );
  }

  /// Converte DateTime para TZDateTime
  tz.TZDateTime _convertToTimezone(DateTime dateTime) {
    final location = tz.getLocation('America/Sao_Paulo');
    return tz.TZDateTime.from(dateTime, location);
  }
}
