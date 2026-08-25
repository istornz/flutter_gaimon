package com.dimitridessus.gaimon

import android.content.Context
import android.os.Build
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
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
  private var vibrator: Vibrator? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "gaimon")
    channel.setMethodCallHandler(this)

    vibrator = resolveVibrator(flutterPluginBinding.applicationContext)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val vibrator = this.vibrator

    if (call.method == "canSupportsHaptic") {
      result.success(vibrator != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && vibrator.hasVibrator())
      return
    }

    // Every branch below drives the vibrator, which needs VibrationEffect (API 26).
    if (vibrator == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      result.success(null)
      return
    }

    when (call.method) {
      "selection" -> vibrate(VibrationEffect.createOneShot(5, VibrationEffect.DEFAULT_AMPLITUDE), vibrator)
      "light" -> vibrate(oneShot(LIGHT_MS, LIGHT_AMPLITUDE, LIGHT_FALLBACK_MS, vibrator), vibrator)
      "medium" -> vibrate(oneShot(MEDIUM_MS, MEDIUM_AMPLITUDE, MEDIUM_FALLBACK_MS, vibrator), vibrator)
      "heavy" -> vibrate(oneShot(HEAVY_MS, HEAVY_AMPLITUDE, HEAVY_FALLBACK_MS, vibrator), vibrator)
      "rigid" -> vibrate(oneShot(RIGID_MS, RIGID_AMPLITUDE, RIGID_FALLBACK_MS, vibrator), vibrator)
      "soft" -> vibrate(oneShot(SOFT_MS, SOFT_AMPLITUDE, SOFT_FALLBACK_MS, vibrator), vibrator)
      "success" -> vibrate(waveform(SUCCESS_TIMINGS, SUCCESS_AMPLITUDES, -1, vibrator), vibrator)
      "error" -> vibrate(waveform(ERROR_TIMINGS, ERROR_AMPLITUDES, -1, vibrator), vibrator)
      "warning" -> vibrate(waveform(WARNING_TIMINGS, WARNING_AMPLITUDES, -1, vibrator), vibrator)
      "stop" -> vibrator.cancel()
      "pattern" -> {
        val callArgs = call.arguments as Map<*, *>

        // The standard codec sends Dart ints as Integer when they fit in 32 bits, so the
        // elements cannot be cast to Long directly.
        val timings = (callArgs["timings"] as List<*>).map { (it as Number).toLong() }.toLongArray()
        val amplitudes = (callArgs["amplitudes"] as List<*>).map { (it as Number).toInt() }.toIntArray()
        val repeat = if (callArgs["repeat"] as Boolean) 1 else -1

        if (timings.isEmpty()) {
          result.success(null)
          return
        }

        vibrate(waveform(timings, amplitudes, repeat, vibrator), vibrator)
      }
      else -> {
        result.notImplemented()
        return
      }
    }

    result.success(null)
  }

  // `getSystemService(Class)` only exists from API 23, and this plugin still ships a
  // minSdk of 16.
  @Suppress("DEPRECATION")
  private fun resolveVibrator(context: Context): Vibrator? = when {
    Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ->
      context.getSystemService(VibratorManager::class.java)?.defaultVibrator
    Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ->
      context.getSystemService(Vibrator::class.java)
    else -> context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
  }

  /**
   * Grades by amplitude where the device supports it, and falls back to grading by
   * duration where it does not — without that fallback every intensity collapses onto
   * the same default-amplitude buzz.
   */
  @RequiresApi(Build.VERSION_CODES.O)
  private fun oneShot(durationMs: Long, amplitude: Int, fallbackDurationMs: Long, vibrator: Vibrator): VibrationEffect =
    if (vibrator.hasAmplitudeControl()) {
      VibrationEffect.createOneShot(durationMs, amplitude)
    } else {
      VibrationEffect.createOneShot(fallbackDurationMs, VibrationEffect.DEFAULT_AMPLITUDE)
    }

  /** A device without amplitude control keeps the rhythm; only the strengths are dropped. */
  @RequiresApi(Build.VERSION_CODES.O)
  private fun waveform(timings: LongArray, amplitudes: IntArray, repeat: Int, vibrator: Vibrator): VibrationEffect =
    if (vibrator.hasAmplitudeControl() && amplitudes.size == timings.size) {
      VibrationEffect.createWaveform(timings, amplitudes, repeat)
    } else {
      VibrationEffect.createWaveform(timings, repeat)
    }

  @RequiresApi(Build.VERSION_CODES.O)
  private fun vibrate(effect: VibrationEffect, vibrator: Vibrator) {
    vibrator.cancel()

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      // USAGE_TOUCH puts these under the system's touch-feedback setting, which is what
      // someone who muted UI haptics expects to govern them.
      vibrator.vibrate(effect, VibrationAttributes.createForUsage(VibrationAttributes.USAGE_TOUCH))
    } else {
      vibrator.vibrate(effect)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    vibrator = null
  }

  /**
   * Impact durations and strengths mirror the iOS feedback generators, so a given call
   * feels like its counterpart on both platforms. This is the tuning surface: the
   * `*_FALLBACK_MS` values are what a device without amplitude control plays instead,
   * where duration is the only lever left.
   */
  private companion object {
    const val LIGHT_MS = 55L
    const val LIGHT_AMPLITUDE = 153
    const val LIGHT_FALLBACK_MS = 10L

    const val MEDIUM_MS = 51L
    const val MEDIUM_AMPLITUDE = 204
    const val MEDIUM_FALLBACK_MS = 40L

    const val HEAVY_MS = 55L
    const val HEAVY_AMPLITUDE = 255
    const val HEAVY_FALLBACK_MS = 90L

    const val RIGID_MS = 34L
    const val RIGID_AMPLITUDE = 229
    const val RIGID_FALLBACK_MS = 25L

    const val SOFT_MS = 82L
    const val SOFT_AMPLITUDE = 178
    const val SOFT_FALLBACK_MS = 60L

    val SUCCESS_TIMINGS = longArrayOf(0, 55, 55, 53)
    val SUCCESS_AMPLITUDES = intArrayOf(0, 178, 0, 255)

    val WARNING_TIMINGS = longArrayOf(0, 55, 91, 55)
    val WARNING_AMPLITUDES = intArrayOf(0, 229, 0, 178)

    val ERROR_TIMINGS = longArrayOf(0, 51, 45, 55, 43, 55, 41, 68)
    val ERROR_AMPLITUDES = intArrayOf(0, 204, 0, 204, 0, 255, 0, 153)
  }
}
