package id.eabsensi.app

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INTEGRITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "isRooted") {
                    result.success(isDeviceRooted())
                } else {
                    result.notImplemented()
                }
            }
    }

    // Pemeriksaan sederhana; hasilnya hanya tanda untuk ditinjau di server.
    private fun isDeviceRooted(): Boolean =
        Build.TAGS?.contains("test-keys") == true || SU_PATHS.any { File(it).exists() }

    private companion object {
        const val INTEGRITY_CHANNEL = "id.eabsensi.app/device_integrity"

        val SU_PATHS = listOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
        )
    }
}
