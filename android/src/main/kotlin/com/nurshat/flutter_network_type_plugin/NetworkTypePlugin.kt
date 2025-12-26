package com.nurshat.flutter_network_type_plugin

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.net.HttpURLConnection
import java.net.URL

class NetworkTypePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private val mainScope = MainScope()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_network_type_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getNetworkType") {
      val url: String? = call.argument("url")
      val speedThreshold: Double? = call.argument("speedThreshold")
      val maxRetries: Int = call.argument("maxRetries") ?: 0
      val retryDelay: Double = call.argument("retryDelay") ?: 1.0
      val timeout: Double = call.argument("timeout") ?: 5.0

      mainScope.launch {
        val networkType = getNetworkType(context, url, speedThreshold, maxRetries, retryDelay, timeout)
        result.success(networkType)
      }
    } else {
      result.notImplemented()
    }
  }

  private suspend fun getNetworkType(context: Context, url: String?, speedThreshold: Double?, maxRetries: Int, retryDelay: Double, timeout: Double): String = withContext(Dispatchers.IO) {
    val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    val networkCapabilities = connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)

    if (networkCapabilities == null || !networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)) {
      return@withContext "NO INTERNET"
    }

    val networkType = when {
      networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "WiFi"
      networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> {
        getMobileNetworkType(context)
      }
      else -> "Unknown"
    }

    // Only perform speed check if both url and speedThreshold are provided
    if (networkType == "4G" && url != null && speedThreshold != null) {
      val speedMbps = measureSpeed(url, timeout)
      if (speedMbps > speedThreshold) {
        "4G"
      } else {
        "3G or less"
      }
    } else if (networkType == "WiFi" && url != null && speedThreshold != null) {
      val speedMbps = measureSpeed(url, timeout)
      if (speedMbps > speedThreshold) {
        "WiFi"
      } else {
        "WiFi (Slow)"
      }
    } else {
      // Return network type directly without speed check
      networkType
    }
  }

  private fun getMobileNetworkType(context: Context): String {
    val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
    return if (ActivityCompat.checkSelfPermission(context, android.Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
      val networkType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        telephonyManager.dataNetworkType
      } else {
        @Suppress("DEPRECATION")
        telephonyManager.networkType
      }
      when (networkType) {
        TelephonyManager.NETWORK_TYPE_NR -> "5G"
        TelephonyManager.NETWORK_TYPE_LTE -> "4G"
        TelephonyManager.NETWORK_TYPE_HSPAP, TelephonyManager.NETWORK_TYPE_EHRPD,
        TelephonyManager.NETWORK_TYPE_EVDO_B, TelephonyManager.NETWORK_TYPE_HSPA,
        TelephonyManager.NETWORK_TYPE_HSDPA, TelephonyManager.NETWORK_TYPE_HSUPA,
        TelephonyManager.NETWORK_TYPE_EVDO_0, TelephonyManager.NETWORK_TYPE_EVDO_A,
        TelephonyManager.NETWORK_TYPE_UMTS -> "3G"
        TelephonyManager.NETWORK_TYPE_GPRS, TelephonyManager.NETWORK_TYPE_EDGE,
        TelephonyManager.NETWORK_TYPE_CDMA, TelephonyManager.NETWORK_TYPE_1xRTT,
        TelephonyManager.NETWORK_TYPE_IDEN -> "2G"
        TelephonyManager.NETWORK_TYPE_UNKNOWN -> "Unknown"
        else -> "Unknown"
      }
    } else {
      requestPermissions()
      "Permission required"
    }
  }

  private fun requestPermissions() {
    if (context is Activity) {
      ActivityCompat.requestPermissions(context as Activity, arrayOf(android.Manifest.permission.READ_PHONE_STATE), 1)
    }
  }

  private suspend fun measureSpeed(urlString: String, timeout: Double): Double = withContext(Dispatchers.IO) {
    val url = URL(urlString)
    val connection = url.openConnection() as HttpURLConnection
    connection.connectTimeout = (timeout * 1000).toInt()
    connection.readTimeout = (timeout * 1000).toInt()

    return@withContext try {
      val startTime = System.currentTimeMillis()
      connection.connect()

      val inputStream = connection.inputStream
      val buffer = ByteArray(1024)
      var bytesRead: Int
      var totalBytesRead = 0

      while (inputStream.read(buffer).also { bytesRead = it } != -1) {
        totalBytesRead += bytesRead
      }

      val endTime = System.currentTimeMillis()
      val timeTaken = (endTime - startTime) / 1000.0 // Convert milliseconds to seconds
      val speedMbps = (totalBytesRead * 8) / (timeTaken * 1_000_000) // Convert bytes to megabits and calculate Mbps

      speedMbps
    } catch (e: Exception) {
      0.0
    } finally {
      connection.disconnect()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    context = binding.activity
  }
  override fun onDetachedFromActivityForConfigChanges() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
  override fun onDetachedFromActivity() {}
}
