package com.example.socket_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.socket_app/WebSocketAdvertiser"

    private lateinit var webSocketServiceAdvertiser: WebSocketServiceAdvertiser

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        webSocketServiceAdvertiser = WebSocketServiceAdvertiser()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "registerService" -> {
                    val port = call.argument<Int>("port") ?: 8080
                    webSocketServiceAdvertiser.registerService(applicationContext, port)
                    result.success(null)
                }
                "unregisterService" -> {
                    webSocketServiceAdvertiser.unregisterService()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
