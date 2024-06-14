package com.nurshat.flutter_network_type_plugin

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.NetworkInfo
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.net.HttpURLConnection
import java.net.URL

class NetworkTypePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private val mainScope = MainScope()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "network_type_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getNetworkType") {
      val url: String? = call.argument("url")
      val speedThreshold: Double? = call.argument("speedThreshold")
      val maxRetries: Int? = call.argument("maxRetries") ?: 0
      val retryDelay: Double? = call.argument("retryDelay") ?: 1.0
      val timeout: Double? = call.argument("timeout") ?: 5.0

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
    val activeNetwork = connectivityManager.activeNetwork
    val networkCapabilities = connectivityManager.getNetworkCapabilities(activeNetwork)
    val networkInfo: NetworkInfo? = connectivityManager.activeNetworkInfo

    if (networkInfo == null || !networkInfo.isConnected) {
      return@withContext "NO INTERNET"
    }

    val networkType = when (networkInfo.type) {
      ConnectivityManager.TYPE_WIFI -> "WiFi"
      ConnectivityManager.TYPE_MOBILE -> {
        when (networkInfo.subtype) {
          NetworkInfo.TYPE_LTE -> "4G"
          NetworkInfo.TYPE_NR -> "5G"
          else -> "Mobile"
        }
      }
      else -> "Unknown"
    }

    if (networkType == "4G" && url != null && speedThreshold != null) {
      val speedMbps = measureSpeed(url, timeout)
      if (speedMbps > speedThreshold) {
        "4G: $speedMbps Mbps"
      } else {
        "3G or less: $speedMbps Mbps"
      }
    } else {
      networkType
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

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {}
  override fun onDetachedFromActivityForConfigChanges() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
  override fun onDetachedFromActivity() {}
}
