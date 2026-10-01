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
      "light" -> vibrate(impact(LIGHT, vibrator), vibrator)
      "medium" -> vibrate(impact(MEDIUM, vibrator), vibrator)
      "heavy" -> vibrate(impact(HEAVY, vibrator), vibrator)
      "rigid" -> vibrate(impact(RIGID, vibrator), vibrator)
      "soft" -> vibrate(impact(SOFT, vibrator), vibrator)
      "success" -> vibrate(notification(SUCCESS, vibrator), vibrator)
      "error" -> vibrate(notification(ERROR, vibrator), vibrator)
      "warning" -> vibrate(notification(WARNING, vibrator), vibrator)
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
   * Prefers the device's own haptic primitives, then the system's predefined effects, and
   * only then drives the motor directly. A primitive or predefined effect is tuned by the
   * manufacturer for its actuator — a crisp click that the system intensity setting governs
   * — where a one-shot of several tens of milliseconds is felt as a buzz on most actuators.
   * Primitives are used from API 31, where every id in [Impact] exists.
   */
  @RequiresApi(Build.VERSION_CODES.O)
  private fun impact(impact: Impact, vibrator: Vibrator): VibrationEffect = when {
    Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && vibrator.areAllPrimitivesSupported(impact.primitive) ->
      VibrationEffect.startComposition().addPrimitive(impact.primitive, impact.scale).compose()
    Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q ->
      VibrationEffect.createPredefined(impact.predefined)
    else ->
      oneShot(impact.durationMs, impact.amplitude, impact.fallbackDurationMs, vibrator)
  }

  /** Plays the notification as a sequence of primitives when the device has them, as a waveform otherwise. */
  @RequiresApi(Build.VERSION_CODES.O)
  private fun notification(notification: Notification, vibrator: Vibrator): VibrationEffect {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
      vibrator.areAllPrimitivesSupported(VibrationEffect.Composition.PRIMITIVE_CLICK)) {
      val composition = VibrationEffect.startComposition()
      notification.clicks.forEach { (delayMs, scale) ->
        composition.addPrimitive(VibrationEffect.Composition.PRIMITIVE_CLICK, scale, delayMs)
      }

      return composition.compose()
    }

    return waveform(notification.timings, notification.amplitudes, -1, vibrator)
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
   * One impact, in each of the three forms [impact] can play it. `primitive` and `scale`
   * grade the strength on devices with composition primitives, `predefined` is the closest
   * system effect where they are missing (it carries no strength), and the one-shot values
   * are the last resort for devices older than API 29.
   */
  private class Impact(
    val primitive: Int,
    val scale: Float,
    val predefined: Int,
    val durationMs: Long,
    val amplitude: Int,
    val fallbackDurationMs: Long,
  )

  /**
   * `clicks` pairs each click's delay — counted from the end of the previous click — with its
   * strength. The delays are the waveform's onset spacing, which a click's own few
   * milliseconds barely shift; the waveform stays the fallback for devices without primitives.
   */
  private class Notification(
    val clicks: List<Pair<Int, Float>>,
    val timings: LongArray,
    val amplitudes: IntArray,
  )

  /**
   * Strengths and rhythms mirror the iOS feedback generators, so a given call feels like
   * its counterpart on both platforms. This is the tuning surface.
   */
  private companion object {
    // Composition and predefined-effect ids are compile-time constants, inlined into the
    // bytecode, so referencing them does not require their API level at runtime.
    val LIGHT = Impact(VibrationEffect.Composition.PRIMITIVE_CLICK, 0.5f, VibrationEffect.EFFECT_TICK, 55L, 153, 10L)
    val MEDIUM = Impact(VibrationEffect.Composition.PRIMITIVE_CLICK, 0.75f, VibrationEffect.EFFECT_CLICK, 51L, 204, 40L)
    val HEAVY = Impact(VibrationEffect.Composition.PRIMITIVE_CLICK, 1f, VibrationEffect.EFFECT_HEAVY_CLICK, 55L, 255, 90L)
    val RIGID = Impact(VibrationEffect.Composition.PRIMITIVE_TICK, 1f, VibrationEffect.EFFECT_CLICK, 34L, 229, 25L)
    val SOFT = Impact(VibrationEffect.Composition.PRIMITIVE_LOW_TICK, 1f, VibrationEffect.EFFECT_TICK, 82L, 178, 60L)

    val SUCCESS = Notification(
      clicks = listOf(0 to 0.7f, 110 to 1f),
      timings = longArrayOf(0, 55, 55, 53),
      amplitudes = intArrayOf(0, 178, 0, 255),
    )

    val WARNING = Notification(
      clicks = listOf(0 to 0.9f, 146 to 0.7f),
      timings = longArrayOf(0, 55, 91, 55),
      amplitudes = intArrayOf(0, 229, 0, 178),
    )

    val ERROR = Notification(
      clicks = listOf(0 to 0.8f, 96 to 0.8f, 98 to 1f, 96 to 0.6f),
      timings = longArrayOf(0, 51, 45, 55, 43, 55, 41, 68),
      amplitudes = intArrayOf(0, 204, 0, 204, 0, 255, 0, 153),
    )
  }
}
