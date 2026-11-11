package com.ahmedhassan.passthephone

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.media.AudioAttributes
import android.os.Build
import android.os.SystemClock
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings

class MainActivity : FlutterActivity() {
    private var lastPulse: Long? = null

    @Suppress("DEPRECATION")
    private fun vibrator(): Vibrator? = if (Build.VERSION.SDK_INT >= 31) {
        getSystemService(VibratorManager::class.java)?.defaultVibrator
    } else {
        getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.ahmedhassan.passthephone/haptics").setMethodCallHandler { call, result ->
            if (call.method != "pulse") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            try {
                val args = call.arguments as? Map<*, *>
                val duration = (args?.get("durationMs") as? Number)?.toLong()
                val now = SystemClock.elapsedRealtime()
                if (args?.get("enabled") != true || duration !in listOf(20L, 30L, 50L)
                    || !hasWindowFocus()
                    || Settings.System.getInt(contentResolver,
                        Settings.System.HAPTIC_FEEDBACK_ENABLED, 0) == 0
                    || lastPulse?.let { now - it < 120 } == true) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                val motor = vibrator()
                if (motor?.hasVibrator() != true) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                lastPulse = now
                val attributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION).build()
                if (Build.VERSION.SDK_INT >= 26) {
                    motor.vibrate(VibrationEffect.createOneShot(duration!!,
                        VibrationEffect.DEFAULT_AMPLITUDE), attributes)
                } else {
                    @Suppress("DEPRECATION")
                    motor.vibrate(duration!!, attributes)
                }
                // Accepted request does not assert physical perceptibility.
                result.success(true)
            } catch (error: RuntimeException) {
                // Missing hardware, permissions or vendor implementation must not interrupt play.
                result.success(false)
            }
        }
    }

    override fun onPause() {
        runCatching { vibrator()?.cancel() }
        super.onPause()
    }
}
