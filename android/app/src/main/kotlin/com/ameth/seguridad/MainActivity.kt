package com.ameth.seguridad

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity con un MethodChannel nativo que expone a Dart el estado
 * real de la Depuración USB (USB Debugging) del dispositivo.
 *
 * Se lee directamente el flag del sistema operativo:
 *   Settings.Global.ADB_ENABLED
 *
 * Esto es la fuente de verdad oficial de Android para saber si el
 * puente ADB está habilitado, no depende de heurísticas ni de
 * paquetes de terceros que puedan quedar desactualizados entre
 * versiones de Android.
 *
 * Canal: "com.ameth.seguridad/security"
 * Método: "isAdbEnabled" -> Boolean
 */
class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.ameth.seguridad/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAdbEnabled" -> {
                        try {
                            val adbEnabled = Settings.Global.getInt(
                                contentResolver,
                                Settings.Global.ADB_ENABLED,
                                0
                            ) == 1
                            result.success(adbEnabled)
                        } catch (e: Exception) {
                            // Si por cualquier razón no se puede leer el setting
                            // (dispositivo no estándar, restricción de OEM, etc.),
                            // se reporta un error explícito a Dart en vez de
                            // asumir un valor por defecto que podría enmascarar
                            // un entorno inseguro.
                            result.error(
                                "ADB_CHECK_FAILED",
                                "No se pudo leer Settings.Global.ADB_ENABLED",
                                e.localizedMessage
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}