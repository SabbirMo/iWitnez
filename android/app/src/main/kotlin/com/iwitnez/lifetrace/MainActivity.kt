package com.iwitnez.lifetrace

import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val RINGTONE_CHANNEL = "com.iwitnez.lifetrace/system_ringtone"
    private var systemRingtone: Ringtone? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RINGTONE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playSystemRingtone" -> {
                    try {
                        stopRingtone()
                        val ringtoneUri = RingtoneManager.getActualDefaultRingtoneUri(context, RingtoneManager.TYPE_RINGTONE)
                            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                        systemRingtone = RingtoneManager.getRingtone(context, ringtoneUri)
                        systemRingtone?.let { ring ->
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                ring.audioAttributes = AudioAttributes.Builder()
                                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                    .build()
                            }
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                ring.isLooping = true
                            }
                            ring.play()
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("RINGTONE_ERROR", e.localizedMessage, null)
                    }
                }
                "stopSystemRingtone" -> {
                    stopRingtone()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun stopRingtone() {
        try {
            systemRingtone?.stop()
        } catch (_: Exception) {}
        systemRingtone = null
    }

    override fun onDestroy() {
        stopRingtone()
        super.onDestroy()
    }
}
