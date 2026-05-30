package com.ameth.seguridad

import android.app.AppOpsManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ameth.seguridad/security"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isFakeGpsInstalled" -> result.success(isFakeGpsInstalled())
                    else -> result.notImplemented()
                }
            }
    }

    private fun isFakeGpsInstalled(): Boolean {
        // API < 23: verificar ajuste de sistema (método antiguo)
        @Suppress("DEPRECATION")
        if (Build.VERSION.SDK_INT < 23) {
            if (Settings.Secure.getInt(contentResolver, Settings.Secure.ALLOW_MOCK_LOCATION, 0) != 0)
                return true
        }

        // API 23+: verificar con AppOpsManager qué app tiene mock location autorizada
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val packages = packageManager.getInstalledPackages(0)

        for (pkg in packages) {
            if (pkg.packageName == packageName) continue
            val uid = pkg.applicationInfo?.uid ?: continue
            val mode = if (Build.VERSION.SDK_INT >= 29) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_MOCK_LOCATION, uid, pkg.packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_MOCK_LOCATION, uid, pkg.packageName
                )
            }
            if (mode == AppOpsManager.MODE_ALLOWED) return true
        }

        return false
    }
}
