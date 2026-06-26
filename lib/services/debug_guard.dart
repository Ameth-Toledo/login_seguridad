import 'dart:io';
import 'package:flutter/material.dart';
import '../services/security_check_service.dart';

/// Widget de arranque (RASP - Runtime Application Self-Protection) que
/// envuelve la aplicación real y verifica, ANTES de permitir cualquier
/// interacción con la lógica de negocio, si la Depuración USB está
/// habilitada en un entorno que no es de desarrollo.
///
/// Flujo:
///   1. Mientras se realiza la verificación nativa, se muestra un splash
///      mínimo (pantalla en blanco con indicador de carga).
///   2. Si el entorno es seguro (ADB desactivado, o estamos en
///      kDebugMode), se monta el widget hijo (`child`) normalmente —
///      la app continúa su flujo habitual (login, etc.) sin ninguna
///      fricción adicional.
///   3. Si el entorno es inseguro, se congela la pantalla con un
///      `AlertDialog` persistente (`barrierDismissible: false`, sin
///      botón de back) que explica la razón del bloqueo. Al presionar
///      el único botón disponible, la app se cierra por completo.
///
/// Este widget debe colocarse en el punto más alto posible del árbol
/// de widgets (envolviendo el `MaterialApp`/`App` real), para que el
/// usuario no pueda llegar a ninguna pantalla de negocio (ni siquiera
/// el login) mientras el entorno se considere inseguro.
class DebugGuard extends StatefulWidget {
  final Widget child;

  const DebugGuard({super.key, required this.child});

  @override
  State<DebugGuard> createState() => _DebugGuardState();
}

enum _GuardStatus { checking, safe, blocked }

class _DebugGuardState extends State<DebugGuard> {
  _GuardStatus _status = _GuardStatus.checking;

  @override
  void initState() {
    super.initState();
    _runCheck();
  }

  Future<void> _runCheck() async {
    final shouldBlock = await SecurityCheckService.shouldBlockForAdbDebugging();
    if (!mounted) return;
    setState(() {
      _status = shouldBlock ? _GuardStatus.blocked : _GuardStatus.safe;
    });
  }

  /// Cierra la aplicación de forma limpia y completa.
  /// `exit(0)` termina el proceso Dart/Flutter por completo —
  /// es la forma más confiable de garantizar que el usuario no
  /// pueda seguir interactuando con la app de ninguna manera.
  void _closeApp() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _GuardStatus.checking:
        return const _CheckingSplash();

      case _GuardStatus.safe:
        return widget.child;

      case _GuardStatus.blocked:
      // Se sigue montando el árbol normal de fondo (para que el
      // AlertDialog tenga un Navigator/Material donde anclarse),
      // pero se superpone el diálogo bloqueante de inmediato y de
      // forma persistente.
        return _BlockedScreen(onAcknowledge: _closeApp);
    }
  }
}

/// Splash mínimo mostrado mientras se realiza la verificación nativa.
/// Es intencionalmente simple: no debe revelar lógica de negocio ni
/// datos sensibles mientras el entorno aún no ha sido validado.
class _CheckingSplash extends StatelessWidget {
  const _CheckingSplash();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      ),
    );
  }
}

/// Pantalla de bloqueo mostrada cuando se detecta Depuración USB activa
/// en un entorno que no es de desarrollo. Contiene un `AlertDialog`
/// persistente que no puede descartarse tocando fuera de él ni con el
/// botón de retroceso del sistema.
class _BlockedScreen extends StatelessWidget {
  final VoidCallback onAcknowledge;

  const _BlockedScreen({required this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Builder(
          builder: (context) {
            // Se programa la apertura del diálogo justo después del
            // primer frame, para asegurar que el contexto ya tiene un
            // Navigator/Overlay disponible.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showBlockingDialog(context);
            });
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showBlockingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera.
      builder: (dialogContext) {
        return PopScope(
          canPop: false, // No se puede cerrar con el botón de retroceso.
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Entorno no seguro detectado',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Se detectó que la Depuración USB (USB Debugging) está '
                  'activa en este dispositivo.\n\n'
                  'Por políticas de seguridad, esta aplicación no puede '
                  'ejecutarse mientras esa opción esté habilitada, ya que '
                  'representa un riesgo de manipulación o análisis no '
                  'autorizado de los datos sensibles que maneja.\n\n'
                  'Para usar la aplicación, ve a Ajustes del sistema → '
                  'Opciones de desarrollador y desactiva la Depuración USB. '
                  'Luego, vuelve a abrir la aplicación.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: onAcknowledge,
                child: const Text(
                  'Entendido, cerrar aplicación',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}