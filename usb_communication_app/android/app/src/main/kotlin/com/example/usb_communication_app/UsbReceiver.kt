package com.example.usb_communication_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbManager
import io.flutter.plugin.common.EventChannel

class UsbReceiver : BroadcastReceiver() {
    companion object {
        private var eventSink: EventChannel.EventSink? = null

        fun setEventSink(sink: EventChannel.EventSink?) {
            eventSink = sink
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                eventSink?.success("connect")
            }
            UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                eventSink?.success("disconnect")
            }
        }
    }
}
