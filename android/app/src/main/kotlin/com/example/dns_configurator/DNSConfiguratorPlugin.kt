package com.example.dns_configurator

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DNSConfiguratorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var methodChannel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger, 
            "com.example.dns_configurator/dns_method"
        )
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "updateDNS" -> {
                val dnsIP = call.argument<String>("dnsIP")
                if (dnsIP != null) {
                    val success = updateSystemDNS(dnsIP)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGUMENT", "DNS IP is required", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun updateSystemDNS(dnsIP: String): Boolean {
        return try {
            // Check Android version and use appropriate method
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                updateDNSModern(dnsIP)
            } else {
                updateDNSLegacy(dnsIP)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun updateDNSModern(dnsIP: String): Boolean {
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) 
            as ConnectivityManager

        // Create a network request
        val networkRequest = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()

        // Network callback to set DNS
        val networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                try {
                    // Set DNS using reflection or system properties
                    setDNSUsingReflection(network, dnsIP)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }

        // Register network callback
        connectivityManager.requestNetwork(networkRequest, networkCallback)
        
        return true
    }

    private fun updateDNSLegacy(dnsIP: String): Boolean {
        // Legacy method for older Android versions
        // This might require root access or system permissions
        return try {
            val setpropMethod = Class.forName("android.os.SystemProperties")
                .getMethod("set", String::class.java, String::class.java)
            
            setpropMethod.invoke(null, "net.dns1", dnsIP)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun setDNSUsingReflection(network: Network, dnsIP: String): Boolean {
        // Advanced DNS setting using reflection
        return try {
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) 
                as ConnectivityManager
            
            val setDefaultNetworkMethod = ConnectivityManager::class.java.getMethod(
                "setDefaultNetwork", 
                Network::class.java
            )
            setDefaultNetworkMethod.invoke(connectivityManager, network)
            
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }
}