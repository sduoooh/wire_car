package com.example.usb_communication_app

import android.content.IntentFilter
import android.hardware.usb.UsbManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private lateinit var usbReceiver: UsbReceiver

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册 USB 事件通道
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "usb_events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    UsbReceiver.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    UsbReceiver.setEventSink(null)
                }
            }
        )

        // 注册 USB 广播接收器
        usbReceiver = UsbReceiver()
        val filter = IntentFilter().apply {
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        }
        registerReceiver(usbReceiver, filter)
    }

    override fun onDestroy() {
        super.onDestroy()
        // 取消注册 USB 广播接收器
        unregisterReceiver(usbReceiver)
    }
}