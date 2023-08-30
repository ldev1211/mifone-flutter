package mitek.build.phone.mifone.flutter

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "my_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Khởi tạo MethodChannel
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "checkFlagAnswer") {
                    val sharedPreference =  context.getSharedPreferences("PREFERENCE_NAME",Context.MODE_PRIVATE)
                    result.success(sharedPreference.getBoolean("isAnswerCall",false))
                } else if(call.method == "disable_flag_answer"){
                    val sharedPreference =  context.getSharedPreferences("PREFERENCE_NAME",Context.MODE_PRIVATE)
                    var editor = sharedPreference.edit()
                    editor.putBoolean("isAnswerCall",false)
                    editor.apply()
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Khởi tạo MethodChannel
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
            .setMethodCallHandler { call, result ->
                Log.d("DEBUGINVOKE", "onCreate: "+call.method+", "+CHANNEL)
                if (call.method == "open") {
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
