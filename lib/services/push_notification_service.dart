import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Para manejar mensajes en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Notificación en segundo plano: ${message.messageId}");
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Canal para Android
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'Notificaciones Importantes',
    description: 'Canal para notificaciones importantes',
    importance: Importance.high,
  );
  
  // Singleton
  factory PushNotificationService() {
    return _instance;
  }
  
  PushNotificationService._internal();
  
  // Inicializar el servicio
  Future<void> initialize() async {
    try {
      // Inicializar Firebase
      await Firebase.initializeApp();
      
      // Configurar manejador para mensajes en segundo plano
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Solicitar permisos
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      debugPrint('Estado de permisos: ${settings.authorizationStatus}');
      
      // Configurar notificaciones locales para iOS/Android
      await _setupLocalNotifications();
      
      // Escuchar mensajes en primer plano
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Manejar cuando se abre la app desde una notificación
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);
      
      // Obtener y guardar token FCM
      await _updateFcmToken();
      
      // Suscribir a temas
      await _subscribeToTopics();
      
      debugPrint('✅ Servicio de notificaciones inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando servicio de notificaciones: $e');
    }
  }
  
  // Configurar notificaciones locales
  Future<void> _setupLocalNotifications() async {
    // Configuración para Android
    await _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_channel);
    
    // Inicializar configuración para Android/iOS
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          _handleNotificationPayload(payload);
        }
      },
    );
  }
  
  // Manejar notificación en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Notificación recibida en primer plano: ${message.notification?.title}');
    
    // Mostrar notificación local cuando la app está abierta
    if (message.notification != null) {
      _localNotifications.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }
  
  // Manejar cuando se abre la app desde una notificación
  void _handleNotificationOpened(RemoteMessage message) {
    debugPrint('App abierta desde notificación: ${message.notification?.title}');
    _processNotificationData(message.data);
  }
  
  // Manejar payload de notificación local
  void _handleNotificationPayload(String payload) {
    debugPrint('Payload de notificación: $payload');
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _processNotificationData(data);
    } catch (e) {
      debugPrint('Error procesando payload: $e');
    }
  }
  
  // Procesar datos de la notificación para navegación
  void _processNotificationData(Map<String, dynamic> data) {
    // Ejemplo: navegar según tipo de notificación
    if (data.containsKey('type')) {
      final type = data['type'];
      
      switch (type) {
        case 'reserva_confirmada':
          // Navegar a pantalla de reservas
          // Navigator.pushNamed(navigatorKey.currentContext!, '/reservas');
          break;
        
        case 'nueva_recomendacion':
          // Navegar a pantalla de recomendaciones
          // Navigator.pushNamed(navigatorKey.currentContext!, '/recomendaciones');
          break;
      }
    }
  }
  
  // Obtener y guardar token FCM
  Future<String?> _updateFcmToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      
      if (token != null) {
        // Guardar token localmente
        await _storage.write(key: 'fcm_token', value: token);
        
        // Enviar token al backend
        await _sendTokenToBackend(token);
      }
      
      // Configurar listener para actualización de token
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token actualizado: $newToken');
        _storage.write(key: 'fcm_token', value: newToken);
        _sendTokenToBackend(newToken);
      });
      
      return token;
    } catch (e) {
      debugPrint('Error obteniendo FCM token: $e');
      return null;
    }
  }
  
  // Enviar token al backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final clientId = await _storage.read(key: 'clienteId');
      final tenantId = await _storage.read(key: 'tenantId');
      
      if (clientId == null) return;
      
      // TODO: Implementar llamada al backend para registrar token
      debugPrint('Enviando token para clienteId: $clientId, tenantId: $tenantId');
      
      // Ejemplo: Enviar a través de una API REST o GraphQL
      // final response = await http.post(
      //   Uri.parse('https://api.tudominio.com/registrar-token'),
      //   body: {
      //     'cliente_id': clientId,
      //     'tenant_id': tenantId,
      //     'fcm_token': token,
      //     'platform': Platform.isAndroid ? 'android' : 'ios',
      //   },
      // );
      
    } catch (e) {
      debugPrint('Error enviando token al backend: $e');
    }
  }
  
  // Suscribirse a temas para notificaciones específicas
  Future<void> _subscribeToTopics() async {
    try {
      // Obtener tenantId para suscripción específica
      final tenantId = await _storage.read(key: 'tenantId') ?? '1';
      
      // Tema general para todos los usuarios de este tenant
      await _messaging.subscribeToTopic('tenant_$tenantId');
      
      // Tema para promociones
      await _messaging.subscribeToTopic('promociones');
      
      debugPrint('✅ Suscrito a temas de notificaciones');
    } catch (e) {
      debugPrint('❌ Error suscribiéndose a temas: $e');
    }
  }
  
  // Método para desuscribirse (útil al cerrar sesión)
  Future<void> unsubscribeFromTopics() async {
    try {
      final tenantId = await _storage.read(key: 'tenantId') ?? '1';
      await _messaging.unsubscribeFromTopic('tenant_$tenantId');
      await _messaging.unsubscribeFromTopic('promociones');
    } catch (e) {
      debugPrint('Error al desuscribirse: $e');
    }
  }
}