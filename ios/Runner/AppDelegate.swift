import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Read Google Maps API key from .env
    let envPath = Bundle.main.path(forResource: FlutterDartProject.lookupKey(forAsset: ".env"), ofType: nil)
    if let path = envPath, let envString = try? String(contentsOfFile: path) {
      for line in envString.components(separatedBy: .newlines) where line.hasPrefix("GOOGLE_MAPS_API_KEY=") {
        let key = line.replacingOccurrences(of: "GOOGLE_MAPS_API_KEY=", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        GMSServices.provideAPIKey(key)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
