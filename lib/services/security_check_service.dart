import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Servicio de seguridad en tiempo de ejecución (RASP) que verifica si la
/// Depuración USB (USB Debugging) está habilitada en el dispositivo.
///
/// ── Mecanismo de detección ──────────────────────────────────────────────
/// Se usa un MethodChannel nativo hacia Kotlin (`MainActivity.kt`) que lee
/// directamente el flag oficial del sistema operativo Android:
///
///     Settings.Global.ADB_ENABLED
///
/// Se eligió esta vía (Opción B: código nativo) en lugar de un paquete de
/// terceros porque:
///   1. Es la fuente de verdad real del sistema operativo, sin intermediarios.
///   2. No depende del mantenimiento de un paquete externo que podría
///      quedar desactualizado entre versiones de Android.
///   3. Da control total y transparencia sobre exactamente qué se está
///      leyendo y cómo, lo cual es más fácil de auditar y justificar.
///
/// ── Excepción de entorno de desarrollo ──────────────────────────────────
/// La restricción NUNCA se aplica si `kDebugMode` es `true`, ya que de
/// lo contrario sería imposible depurar la app durante el desarrollo
/// (Flutter usa el propio puente de depuración para hot reload, etc.).
/// La validación real solo tiene efecto en builds de Release/Profile,
/// simulando un entorno de producción.
class SecurityCheckService {
  SecurityCheckService._();

  static const MethodChannel _channel =
  MethodChannel('com.ameth.seguridad/security');

  /// Determina si la app debe bloquearse por Depuración USB activa.
  ///
  /// Devuelve `true` únicamente si:
  ///   - NO estamos en `kDebugMode` (es decir, simulando un entorno de
  ///     producción/release), Y
  ///   - El sistema operativo reporta ADB_ENABLED == 1.
  ///
  /// En caso de error al consultar el canal nativo, se falla "cerrado"
  /// (fail-closed): se considera el entorno como inseguro y se bloquea,
  /// en vez de asumir que todo está bien. Esto es una decisión de
  /// seguridad deliberada — es preferible un falso bloqueo ocasional
  /// a un falso negativo que permita ejecutar la app con ADB activo.
  static Future<bool> shouldBlockForAdbDebugging() async {
    // Excepción de entorno de desarrollo: nunca bloquear en modo debug.
    if (kDebugMode) {
      return false;
    }

    try {
      final bool isAdbEnabled =
          await _channel.invokeMethod<bool>('isAdbEnabled') ?? false;
      return isAdbEnabled;
    } on PlatformException catch (e) {
      debugPrint(
        '[SecurityCheckService] Error consultando ADB_ENABLED: '
            '${e.code} - ${e.message}',
      );
      // Fail-closed: si no se puede verificar el estado real, se
      // bloquea por precaución en entornos no-debug.
      return true;
    } on MissingPluginException {
      // Ocurre típicamente en plataformas distintas de Android
      // (iOS, web, desktop) donde este canal no está implementado.
      // ADB es un mecanismo exclusivo de Android, así que en otras
      // plataformas simplemente no aplica esta verificación.
      return false;
    }
  }
}