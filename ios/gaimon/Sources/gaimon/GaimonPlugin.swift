import Flutter
import UIKit
import CoreHaptics

@available(iOS 13.0, *)
let hapticManager = HapticEngineManager()

public class GaimonPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "gaimon", binaryMessenger: registrar.messenger())
    let instance = GaimonPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addSceneDelegate(instance)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
    case "canSupportsHaptic":
      if #available(iOS 13.0, *) {
        result(CHHapticEngine.capabilitiesForHardware().supportsHaptics)
      } else {
        result(false)
      }
      break
    case "selection":
      if #available(iOS 10.0, *) {
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        feedback.selectionChanged()
      }
      break
    case "error":
      if #available(iOS 10.0, *) {
        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()
        feedback.notificationOccurred(.error)
      }
      break
    case "success":
      if #available(iOS 10.0, *) {
        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()
        feedback.notificationOccurred(.success)
      }
      break
    case "warning":
      if #available(iOS 10.0, *) {
        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()
        feedback.notificationOccurred(.warning)
      }
      break
    case "heavy":
      if #available(iOS 10.0, *) {
        let feedback = UIImpactFeedbackGenerator(style: .heavy)
        feedback.prepare()
        feedback.impactOccurred()
      }
      break
    case "medium":
      if #available(iOS 10.0, *) {
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        feedback.impactOccurred()
      }
      break
    case "light":
      if #available(iOS 10.0, *) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.prepare()
        feedback.impactOccurred()
      }
      break
    case "rigid":
      if #available(iOS 13.0, *) {
        let feedback = UIImpactFeedbackGenerator(style: .rigid)
        feedback.prepare()
        feedback.impactOccurred()
      }
      break
    case "soft":
      if #available(iOS 13.0, *) {
        let feedback = UIImpactFeedbackGenerator(style: .soft)
        feedback.prepare()
        feedback.impactOccurred()
      }
      break
    case "stop":
      if #available(iOS 13.0, *) {
        hapticManager.stopHaptics()
      }
      break
    case "pattern":
      if #available(iOS 13.0, *) {
        if let args = call.arguments as? Dictionary<String, Any>,
           let data = args["data"] as? String {
          hapticManager.prepareHaptics()
          hapticManager.startVibrationIOS(data: data)
        } else {
          result(FlutterError.init(code: "bad args", message: nil, details: nil))
        }
      }
      break
    default:
      break
    }
  }
}