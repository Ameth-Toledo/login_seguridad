import 'package:firebase_messaging/firebase_messaging.dart';
import '../core/network/http.dart';
import '../services/secure_storage_service.dart';

class NotificationService {
  static final _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _httpClient = HttpClient();

  static Future<String?> getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await SecureStorageService.saveFcmToken(token);
      }
      return token;
    } catch (e) {
      print('Error obteniendo FCM token: $e');
      return null;
    }
  }

  /// Registra el FCM token del dispositivo en el backend.
  Future<bool> registerFcmToken({
    required String authToken,
    required String fcmToken,
  }) async {
    try {
      await _httpClient.post(
        '/api/notifications/fcm-token',
        {'fcm_token': fcmToken},
        token: authToken,
      );
      return true;
    } catch (e) {
      print('Error registrando FCM token: $e');
      return false;
    }
  }

  /// Solicita al backend que envíe la notificación de remote wipe.
  Future<RemoteWipeResponse> requestRemoteWipe({
    required String userId,
    required String authToken,
    String? reason,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/notifications/request-remote-wipe',
        {
          'target_user_id': int.parse(userId),
          'reason': reason ?? 'Usuario solicitó wipe remoto',
        },
        token: authToken,
      );

      return RemoteWipeResponse(
        success: true,
        message: response['message']?.toString() ?? 'Notificación enviada',
      );
    } on Exception catch (e) {
      return RemoteWipeResponse(
        success: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

class RemoteWipeResponse {
  final bool success;
  final String message;

  RemoteWipeResponse({required this.success, required this.message});
}