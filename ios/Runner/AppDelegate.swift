import Flutter
import UIKit
import InMobiSDK
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      // 唯一且优化的ATT请求（延迟3.5秒）
         DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
             if #available(iOS 14, *) {
                 ATTrackingManager.requestTrackingAuthorization { status in
                     // 处理授权结果
                 }
             }
         }


    // 设置方法通道
    setupMethodChannel()
    
    // 初始化 InMobi SDK
    initializeInMobiSDK()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupMethodChannel() {
    // 延迟设置方法通道，确保window已经初始化
    DispatchQueue.main.async { [weak self] in
      guard let self = self,
            let controller = self.window?.rootViewController as? FlutterViewController else {
        print("无法获取 FlutterViewController")
        return
      }
      
      self.methodChannel = FlutterMethodChannel(name: "inmobi_ads", binaryMessenger: controller.binaryMessenger)
      self.methodChannel?.setMethodCallHandler { [weak self] (call, result) in
        self?.handleMethodCall(call, result: result)
      }
      print("方法通道设置完成")
    }
  }
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "showBannerAd":
      MediaAdController._displayBannerAd_show()
      result(nil)
      
    case "hideBannerAd":
      MediaAdController._concealBannerAd_hide()
      result(nil)
      
    case "showInterstitialAd":
      MediaAdController._presentInterstitialAd_display()
      result(nil)
      
    case "showRewardedVideoAd":
      MediaAdController._showRewardedVideoAd_play()
      result(nil)
      
    case "isRewardedVideoReady":
      let isReady = MediaAdController._isRewardedVideoReady_check()
      result(isReady)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func initializeInMobiSDK() {
    // 设置日志级别
    IMSdk.setLogLevel(.error)
    
    // 初始化 SDK
    IMSdk.initWithAccountID("40554dacd2664e479b98f1fc4a8b30b8") { error in
      if let error = error {
        print("InMobi SDK 初始化失败: \(error.localizedDescription)")
      } else {
        print("InMobi SDK 初始化成功")
        // 初始化广告控制器 - 使用 Objective-C 调用
        DispatchQueue.main.async {
          let mediaAdController = MediaAdController._sharedInstance_impl()
          MediaAdController._initializeAdPlatform_core()
        }
      }
    }
  }
  
  // 发送事件到 Flutter (匹配 Objective-C 调用)
  @objc func sendEventToFlutterWithEventName(_ eventName: String, data: [String: Any]?) {
    methodChannel?.invokeMethod(eventName, arguments: data)
  }
}
