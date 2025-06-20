import UIKit
import Flutter
import GoogleMaps  // 구글 맵 SDK 임포트

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyA2wZ7oeefZ_gSV20nLhSyex41WAwSYD4Y")  // 구글 맵 API 키 입력

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
