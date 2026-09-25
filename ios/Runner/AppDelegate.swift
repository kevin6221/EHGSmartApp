import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var isPluginRegistered = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     registerBandPlugin(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    guard !isPluginRegistered else { return }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerBandPlugin(with: engineBridge.pluginRegistry)
  }

  private func registerBandPlugin(with registry: FlutterPluginRegistry) {
    guard !isPluginRegistered else { return }
    if let registrar = registry.registrar(forPlugin: "EHGBandNativePlugin") {
      EHGBandNativePlugin.register(with: registrar)
      isPluginRegistered = true
    }
  }
}
