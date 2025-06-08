package com.example.shieldplay

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.shieldplay.screenshot"
    private var isScreenshotProtectionEnabled = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecureMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setSecureMode(enabled)
                    result.success(null)
                }
                "initializeScreenshotProtection" -> {
                    setSecureMode(true)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setSecureMode(enabled: Boolean) {
        isScreenshotProtectionEnabled = enabled
        if (enabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
