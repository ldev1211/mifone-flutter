package mitek.build.phone.mifone.flutter

import android.content.Context
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

public class MainActivity: FlutterActivity() {
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
}
