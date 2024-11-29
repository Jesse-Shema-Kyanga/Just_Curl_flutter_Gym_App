package com.example.fitness_tracker

import android.os.Bundle
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.fitness_tracker/light_sensor"
    private var sensorManager: SensorManager? = null
    private var lightSensor: Sensor? = null
    private var sensorEventListener: SensorEventListener? = null
    private lateinit var powerManager: PowerManager
    private lateinit var wakeLock: PowerManager.WakeLock

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize PowerManager for screen management
        powerManager = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, "fitness_tracker:lightSensor")
    }

    override fun onResume() {
        super.onResume()

        // Initialize the sensor manager and light sensor
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        lightSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_LIGHT)

        if (lightSensor != null) {
            sensorEventListener = object : SensorEventListener {
                override fun onSensorChanged(event: SensorEvent?) {
                    if (event != null) {
                        val lux = event.values[0] // Light level in lux

                        // Ensure binaryMessenger is not null before passing it to MethodChannel
                        val binaryMessenger = flutterEngine?.dartExecutor?.binaryMessenger
                        if (binaryMessenger != null) {
                            // Send the light level to Flutter
                            MethodChannel(binaryMessenger, CHANNEL)
                                .invokeMethod("updateLight", lux)

                            // Handle screen off when light level is low
                            if (lux < 5.0) {
                                if (!wakeLock.isHeld) {
                                    wakeLock.acquire() // Dim or turn off the screen
                                }
                                // Optionally notify Flutter to update the screen state
                                MethodChannel(binaryMessenger, CHANNEL)
                                    .invokeMethod("screenOff", true)
                            } else {
                                if (wakeLock.isHeld) {
                                    wakeLock.release() // Release the wake lock to turn the screen back on
                                }
                                // Optionally notify Flutter to update the screen state
                                MethodChannel(binaryMessenger, CHANNEL)
                                    .invokeMethod("screenOff", false)
                            }
                        }
                    }
                }


                override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
            }

            // Register the listener
            sensorManager?.registerListener(sensorEventListener, lightSensor, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }

    override fun onPause() {
        super.onPause()
        // Unregister the listener to avoid memory leaks
        sensorManager?.unregisterListener(sensorEventListener)

        // Release the wake lock when the app is paused
        if (wakeLock.isHeld) {
            wakeLock.release()
        }
    }
}
