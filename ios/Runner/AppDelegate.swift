import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var isPluginRegistered = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    guard !isPluginRegistered else { return }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerBandPlugin(with: engineBridge.pluginRegistry)
    isPluginRegistered = true
  }

  private func registerBandPlugin(with registry: FlutterPluginRegistry) {
    if let registrar = registry.registrar(forPlugin: "EHGBandNativePlugin") {
      EHGBandNativePlugin.register(with: registrar)
    }
  }
}
