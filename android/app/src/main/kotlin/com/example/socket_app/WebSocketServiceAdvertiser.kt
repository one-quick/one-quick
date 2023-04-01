package com.example.socket_app

import android.content.Context
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.util.Log

class WebSocketServiceAdvertiser {

    private val TAG = "WebSocketServiceAdvertiser"
    private val SERVICE_TYPE = "_http._tcp."
    private val SERVICE_NAME = "one-quick"
    private lateinit var registrationListener: NsdManager.RegistrationListener
    private lateinit var nsdManager: NsdManager

    fun registerService(context: Context, port: Int) {
        val serviceInfo = NsdServiceInfo()
        serviceInfo.serviceName = SERVICE_NAME
        serviceInfo.serviceType = SERVICE_TYPE
        serviceInfo.port = port

        nsdManager = context.getSystemService(Context.NSD_SERVICE) as NsdManager

        initializeRegistrationListener()
        nsdManager.registerService(serviceInfo, NsdManager.PROTOCOL_DNS_SD, registrationListener)
    }

    fun unregisterService() {
        if (::nsdManager.isInitialized && ::registrationListener.isInitialized) {
            nsdManager.unregisterService(registrationListener)
        }
    }

    private fun initializeRegistrationListener() {
        registrationListener = object : NsdManager.RegistrationListener {
            override fun onServiceRegistered(serviceInfo: NsdServiceInfo) {
                Log.d(TAG, "Service registered: ${serviceInfo.serviceName}")
            }

            override fun onRegistrationFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {
                Log.e(TAG, "Service registration failed: $errorCode")
            }

            override fun onServiceUnregistered(serviceInfo: NsdServiceInfo) {
                Log.d(TAG, "Service unregistered: ${serviceInfo.serviceName}")
            }

            override fun onUnregistrationFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {
                Log.e(TAG, "Service unregistration failed: $errorCode")
            }
        }
    }
}
