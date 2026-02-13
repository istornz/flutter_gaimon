package com.dimitridessus.gaimon

import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** GaimonPlugin */
class GaimonPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var vibrator: Vibrator


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "gaimon")
    channel.setMethodCallHandler(this)

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      vibrator = flutterPluginBinding.applicationContext.getSystemService(Vibrator::class.java)
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "canSupportsHaptic" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          result.success(vibrator.hasVibrator())
        } else {
          result.success(false)
        }
      }
      "selection" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val effect = VibrationEffect.createOneShot(5, VibrationEffect.DEFAULT_AMPLITUDE)
          vibrate(effect)
        }
      }
      "light" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val effect = VibrationEffect.createWaveform(longArrayOf(3, 100), intArrayOf(
                  VibrationEffect.DEFAULT_AMPLITUDE, 0), -1)
          vibrate(effect)
        }
      }
      "medium" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val effect = VibrationEffect.createWaveform(longArrayOf(40, 100), intArrayOf(
                  VibrationEffect.DEFAULT_AMPLITUDE, 0), -1)
          vibrate(effect)
        }
      }
      "heavy" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val effect = VibrationEffect.createWaveform(longArrayOf(90, 100), intArrayOf(
                  VibrationEffect.DEFAULT_AMPLITUDE, 0), -1)
          vibrate(effect)
        }
      }
      "rigid" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val effect = VibrationEffect.createWaveform(longArrayOf(90, 70), intArrayOf(
                  VibrationEffect.DEFAULT_AMPLITUDE, 0), -1)
          vibrate(effect)
        }
      }
      "soft" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val effect = VibrationEffect.createWaveform(longArrayOf(40, 60), intArrayOf(
                  VibrationEffect.DEFAULT_AMPLITUDE, 0), -1)
          vibrate(effect)
        }
      }
      "success" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val mVibratePattern = longArrayOf(0, 40, 170, 100)
          val mAmplitudes = intArrayOf(0, 50, 0, 100)

          if (vibrator.hasAmplitudeControl()) {
            val effect = VibrationEffect.createWaveform(mVibratePattern, mAmplitudes, -1)
            vibrate(effect)
          }
        }
      }
      "error" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val mVibratePattern = longArrayOf(0, 40, 170, 40)
          val mAmplitudes = intArrayOf(0, 50, 0, 50)

          if (vibrator.hasAmplitudeControl()) {
            val effect = VibrationEffect.createWaveform(mVibratePattern, mAmplitudes, -1)
            vibrate(effect)
          }
        }
      }
      "warning" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val mVibratePattern = longArrayOf(0, 40, 100, 40)
          val mAmplitudes = intArrayOf(0, 50, 0, 50)

          if (vibrator.hasAmplitudeControl()) {
            val effect = VibrationEffect.createWaveform(mVibratePattern, mAmplitudes, -1)
            vibrate(effect)
          }
        }
      }
      "stop" -> {
        vibrator.cancel()
      }
      "pattern" -> {
        var callArgs: HashMap<String, Any> = call.arguments as HashMap<String, Any>

        val mVibratePattern = (callArgs["timings"] as ArrayList<Long>).toLongArray()
        val mAmplitudes = (callArgs["amplitudes"] as ArrayList<Int>).toIntArray()

        val repeat = if (callArgs["repeat"] as Boolean) 1 else -1

        if (vibrator.hasAmplitudeControl()) {
          val effect = VibrationEffect.createWaveform(mVibratePattern, mAmplitudes, repeat)
          vibrate(effect)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }


  fun vibrate(effect: VibrationEffect) {
    vibrator.cancel()
    vibrator.vibrate(effect)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
