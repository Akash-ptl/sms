package com.example.sms

import android.telephony.SmsManager
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }

    private val methodChannelName = "com.example.sms"
    private var methodChannel: MethodChannel? = null
    private var result: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    Log.d(TAG, "sendSMSsendSMS:1")
                    val num: String? = call.argument("mobileNumber")
                    val msg: String? = call.argument("message")
                    val subscriptionId: String? = call.argument("subscriptionId")
                    val _result = this.sendSMS(num, msg, subscriptionId, result)
                    if (_result != null) {
                        result.success("SMS Sent")
                    } else {
                        result.error("Err", "Sms Not Sent", "")
                    }
                }
            }
        }
        super.configureFlutterEngine(flutterEngine)
    }

    private fun sendSMS(
        phoneNo: String?,
        msg: String?,
        subscriptionId: String?,
        result: MethodChannel.Result?
    ): String? {
        try {
            val smsManager = SmsManager.getSmsManagerForSubscriptionId(subscriptionId?.toInt() ?: 0)
            smsManager.sendTextMessage(phoneNo, null, msg, null, null)
            return "SMS Sent"
        } catch (ex: Exception) {
            ex.printStackTrace()
            return null
        }
    }
}
