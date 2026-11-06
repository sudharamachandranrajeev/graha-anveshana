package dev.brahma.anveshana

import android.app.KeyguardManager
import android.app.admin.DevicePolicyManager
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hands anveshana:// links to Dart (lib/app/links.dart): the camera app opens
 * them when it scans a pairing QR code. Also tells Dart the device's name
 * for the pairing request, and what Sentinel asks about the device. A
 * fragment activity, which local_auth needs for the app lock's fingerprint
 * and face prompt. Text shared to the app (an advert link from a portal's
 * app) goes to Dart too (lib/ui/share_inbox.dart).
 */
class MainActivity : FlutterFragmentActivity() {
    private var channel: MethodChannel? = null
    private var pending: String? = null
    private var shareChannel: MethodChannel? = null
    private var pendingShare: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pending = linkOf(intent)
        pendingShare = sharedText(intent)
        shareChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dev.brahma.anveshana/share").apply {
            setMethodCallHandler { call, result ->
                if (call.method == "takeShared") {
                    result.success(pendingShare)
                    pendingShare = null
                } else {
                    result.notImplemented()
                }
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dev.brahma.anveshana/device").setMethodCallHandler { call, result ->
            if (call.method == "security") result.success(securityFacts()) else result.notImplemented()
        }
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dev.brahma.anveshana/links").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "takeLink" -> {
                        result.success(pending)
                        pending = null
                    }
                    "deviceName" -> result.success(deviceName())
                    else -> result.notImplemented()
                }
            }
        }
    }

    /**
     * What Sentinel reads about the device (core's device_checks.dart): whether
     * a screen lock is set, storage is encrypted, and the newest security patch.
     */
    private fun securityFacts(): Map<String, Any?> {
        val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        val policy = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val status = policy.storageEncryptionStatus
        return mapOf(
            "screenLock" to keyguard.isDeviceSecure,
            "encrypted" to (status == DevicePolicyManager.ENCRYPTION_STATUS_ACTIVE ||
                status == DevicePolicyManager.ENCRYPTION_STATUS_ACTIVE_PER_USER),
            "patched" to Build.VERSION.SECURITY_PATCH.takeIf { it.isNotEmpty() },
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        linkOf(intent)?.let { channel?.invokeMethod("link", it) }
        sharedText(intent)?.let { shareChannel?.invokeMethod("shared", it) }
    }

    private fun sharedText(intent: Intent?): String? =
        intent?.takeIf { it.action == Intent.ACTION_SEND && it.type == "text/plain" }
            ?.getStringExtra(Intent.EXTRA_TEXT)?.takeIf { it.isNotBlank() }

    private fun linkOf(intent: Intent?): String? =
        intent?.takeIf { it.action == Intent.ACTION_VIEW }?.data?.takeIf { it.scheme == "anveshana" }?.toString()

    private fun deviceName(): String {
        val maker = Build.MANUFACTURER.replaceFirstChar { it.uppercase() }
        val model = Build.MODEL
        return if (model.startsWith(maker, ignoreCase = true)) model else "$maker $model"
    }
}
