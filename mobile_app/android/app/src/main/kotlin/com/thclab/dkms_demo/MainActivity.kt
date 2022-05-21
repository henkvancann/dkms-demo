package com.thclab.dkms_demo

import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.util.Base64.DEFAULT
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.goterl.lazysodium.LazySodiumAndroid
import com.goterl.lazysodium.SodiumAndroid
import com.goterl.lazysodium.interfaces.Sign
import com.goterl.lazysodium.utils.Key
import com.goterl.lazysodium.utils.KeyPair
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.IvParameterSpec


class MainActivity: FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/getkey"
    var lazySodium = LazySodiumAndroid(SodiumAndroid())

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            // Note: this method is invoked on the main thread.
            if(call.method == "verify"){
                val message = call.argument<String>("message")
                val signature = call.argument<String>("signature")
                val key = call.argument<String>("key")
                var res = verify(key!!, message!!, lazySodium, signature!!)
                result.success(res);
            }
            else {
                result.notImplemented()
            }
        }
    }

    fun verify(
        key : String,
        message: String,
        lazySodium: LazySodiumAndroid,
        signature: String
    ): Boolean {
        return lazySodium.cryptoSignVerifyDetached(
            signature, message, Key.fromBase64String(key)
        )
        //return true
    }

}
