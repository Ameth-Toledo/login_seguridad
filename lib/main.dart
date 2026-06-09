import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/secure_storage_service.dart';
import 'services/wipe_events.dart';

/// Handler para cuando la app está en BACKGROUND o CERRADA.
/// Verifica que el target_user_id coincida antes de borrar.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.data['action'] == 'remote_wipe') {
    final targetUserId = message.data['target_user_id'] as String?;
    if (targetUserId != null) {
      await SecureStorageService.wipeIfTargetMatches(targetUserId);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Guarda el FCM token en almacén encriptado para mostrarlo en la UI.
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await SecureStorageService.saveFcmToken(fcmToken);
      debugPrint('FCM Token: $fcmToken');
    }
  } catch (e) {
    debugPrint('No se pudo obtener FCM token: $e');
  }

  // Escuchar notificaciones en FOREGROUND — verifica target_user_id.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.data['action'] == 'remote_wipe') {
      final targetUserId = message.data['target_user_id'] as String?;
      if (targetUserId != null) {
        final wiped = await SecureStorageService.wipeIfTargetMatches(targetUserId);
        if (wiped) {
          // Notifica a la UI para que refresque los datos mostrados.
          wipeEventStream.add(null);
          debugPrint('REMOTE WIPE ejecutado para usuario $targetUserId');
        } else {
          debugPrint('REMOTE WIPE ignorado — target_user_id no coincide');
        }
      }
    }
  });

  // Cuando el usuario toca la notificación con la app en background.
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if (message.data['action'] == 'remote_wipe') {
      final targetUserId = message.data['target_user_id'] as String?;
      if (targetUserId != null) {
        final wiped = await SecureStorageService.wipeIfTargetMatches(targetUserId);
        if (wiped) wipeEventStream.add(null);
      }
    }
  });

  runApp(
    DevicePreview(
      builder: (context) => const ProviderScope(child: App()),
    ),
  );
}
