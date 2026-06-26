import 'dart:async';

/// Stream global que emite un evento cada vez que se ejecuta un
/// remote wipe (borrado remoto de datos sensibles).
///
/// Se usa para que widgets como `HomePage` puedan escuchar el evento
/// y refrescar la UI inmediatamente (por ejemplo, releyendo
/// `secureDataProvider`) sin tener que hacer polling.
///
/// El emisor (normalmente `main.dart`, en los listeners de
/// `FirebaseMessaging.onMessage` / `onMessageOpenedApp`) llama:
///   wipeEventStream.add(null);
///
/// El receptor (normalmente un StatefulWidget/ConsumerStatefulWidget)
/// se suscribe en `initState`:
///   wipeEventStream.stream.listen((_) { ... });
/// y cancela la suscripción en `dispose`.
class WipeEventStream {
  WipeEventStream._();

  static final WipeEventStream _instance = WipeEventStream._();

  factory WipeEventStream() => _instance;

  final StreamController<void> _controller =
  StreamController<void>.broadcast();

  /// Stream público al que los widgets pueden suscribirse.
  Stream<void> get stream => _controller.stream;

  /// Emite un evento de wipe. No requiere argumentos: es solo una señal.
  void add(void _) => _controller.add(null);

  /// Cierra el controller. No se llama normalmente, ya que esta
  /// instancia vive durante todo el ciclo de vida de la app.
  void dispose() => _controller.close();
}

/// Instancia global única (singleton) que se usa en toda la app:
///   import 'wipe_events.dart';
///   wipeEventStream.add(null);          // emitir
///   wipeEventStream.stream.listen(...); // escuchar
final WipeEventStream wipeEventStream = WipeEventStream();