import UIKit
import Flutter
import KakaoSDKCommon  // 카카오 SDK 임포트

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    KakaoSDK.initSDK(appKey: "8625c35abb8b7d85458067f6fff6cec5")  // 네이티브 앱 키 입력

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
