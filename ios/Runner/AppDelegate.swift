import Flutter
import UIKit
import GoogleMobileAds
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
  // AdMob管理器
  private var adMobManager: AdMobManager?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 唯一且优化的ATT请求（延迟3.5秒）
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
        if #available(iOS 14, *) {
           ATTrackingManager.requestTrackingAuthorization { status in
               // 处理授权结果
           }
        }
    }
    GeneratedPluginRegistrant.register(with: self)
    
    // 设置AdMob方法通道
    setupAdMobMethodChannel()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupAdMobMethodChannel() {
    let controller = window?.rootViewController as! FlutterViewController
    let adMobChannel = FlutterMethodChannel(
      name: "com.florsovivexa.admob",
      binaryMessenger: controller.binaryMessenger
    )
    
    // 创建AdMob管理器并设置方法通道
    adMobManager = AdMobManager()
    adMobManager?.setMethodChannel(adMobChannel)
    
    // 启动时预加载所有广告
    adMobManager?.preloadAllAds()
  }
}

// MARK: - AdMob管理器
@objc class AdMobManager: NSObject {
    static let shared = AdMobManager()
    
    // 广告位ID
    private let bannerAdUnitID = "ca-app-pub-7204507376897037/4662666059"
    private let interstitialAdUnitID = "ca-app-pub-7204507376897037/5253677088"
    private let rewardedAdUnitID = "ca-app-pub-7204507376897037/6447339258"
    
    // 广告实例
    private var bannerView: BannerView?
    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
    
    // Flutter通信通道
    private var methodChannel: FlutterMethodChannel?
    
    // 当前显示的横幅广告容器
    private var bannerContainer: UIView?
    
    // 广告加载状态
    private var isBannerLoaded = false
    private var isInterstitialLoaded = false
    private var isRewardedLoaded = false
    
    // 广告加载重试次数
    private var interstitialRetryCount = 0
    private var rewardedRetryCount = 0
    private let maxRetryCount = 3
    
    // 激励视频奖励状态跟踪
    private var rewardedAdRewardEarned = false
    
    override init() {
        super.init()
        setupAdMob()
    }
    
    // 设置AdMob
    private func setupAdMob() {
        MobileAds.shared.start { [weak self] status in
            print("AdMob初始化状态: \(status)")
            // AdMob初始化完成后，预加载所有广告
            DispatchQueue.main.async {
                self?.preloadAllAds()
            }
        }
    }
    
    // 设置Flutter通信通道
    @objc func setMethodChannel(_ channel: FlutterMethodChannel) {
        self.methodChannel = channel
        setupMethodCallHandler()
    }
    
    // 设置方法调用处理器
    private func setupMethodCallHandler() {
        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "showBannerAd":
                self.showBannerAd(result: result)
            case "hideBannerAd":
                self.hideBannerAd(result: result)
            case "showInterstitialAd":
                self.showInterstitialAd(result: result)
            case "showRewardedAd":
                self.showRewardedAd(result: result)
            case "getAdLoadStatus":
                self.getAdLoadStatus(result: result)
            case "preloadAds":
                self.preloadAllAds()
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // 预加载所有广告
    @objc func preloadAllAds() {
        print("开始预加载所有广告...")
        
        // 预加载横幅广告
        preloadBannerAd()
        
        // 预加载插页广告
        preloadInterstitialAd()
        
        // 预加载激励视频广告
        preloadRewardedAd()
    }
    
    // 预加载横幅广告
    private func preloadBannerAd() {
        guard !isBannerLoaded else { 
            print("iOS: 横幅广告已加载，跳过预加载")
            return 
        }
        
        print("iOS: 开始预加载横幅广告")
        print("iOS: 使用测试广告ID: \(bannerAdUnitID)")
        
        // 创建新的横幅广告视图
        bannerView = BannerView(adSize: AdSizeBanner)
        bannerView?.adUnitID = bannerAdUnitID
        bannerView?.delegate = self
        
        let request = Request()
        bannerView?.load(request)
        print("iOS: 横幅广告预加载请求已发送")
    }
    
    // 处理横幅广告加载失败
    private func handleBannerLoadFailure() {
        print("iOS: 横幅广告加载失败，尝试重新加载...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.preloadBannerAd()
        }
    }
    
    // 预加载插页广告
    private func preloadInterstitialAd() {
        guard !isInterstitialLoaded else { return }
        
        let request = Request()
        InterstitialAd.load(with: interstitialAdUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("插页广告预加载失败: \(error)")
                    self?.handleInterstitialLoadFailure()
                } else {
                    print("插页广告预加载成功")
                    self?.interstitialAd = ad
                    self?.interstitialAd?.fullScreenContentDelegate = self
                    self?.isInterstitialLoaded = true
                    self?.interstitialRetryCount = 0
                    self?.notifyAdLoadStatus()
                }
            }
        }
    }
    
    // 预加载激励视频广告
    private func preloadRewardedAd() {
        guard !isRewardedLoaded else { return }
        
        let request = Request()
        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("激励视频广告预加载失败: \(error)")
                    self?.handleRewardedLoadFailure()
                } else {
                    print("激励视频广告预加载成功")
                    self?.rewardedAd = ad
                    self?.rewardedAd?.fullScreenContentDelegate = self
                    self?.isRewardedLoaded = true
                    self?.rewardedRetryCount = 0
                    self?.notifyAdLoadStatus()
                }
            }
        }
    }
    
    // 处理插页广告加载失败
    private func handleInterstitialLoadFailure() {
        if interstitialRetryCount < maxRetryCount {
            interstitialRetryCount += 1
            print("插页广告加载失败，\(interstitialRetryCount)/\(maxRetryCount) 次重试...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                self?.preloadInterstitialAd()
            }
        } else {
            print("插页广告加载失败，已达到最大重试次数")
            interstitialRetryCount = 0
        }
    }
    
    // 处理激励视频广告加载失败
    private func handleRewardedLoadFailure() {
        if rewardedRetryCount < maxRetryCount {
            rewardedRetryCount += 1
            print("激励视频广告加载失败，\(rewardedRetryCount)/\(maxRetryCount) 次重试...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                self?.preloadRewardedAd()
            }
        } else {
            print("激励视频广告加载失败，已达到最大重试次数")
            rewardedRetryCount = 0
        }
    }
    
    // 获取广告加载状态
    private func getAdLoadStatus(result: @escaping FlutterResult) {
        let status = [
            "banner": isBannerLoaded,
            "interstitial": isInterstitialLoaded,
            "rewarded": isRewardedLoaded
        ]
        result(status)
    }
    
    // 通知Flutter广告加载状态
    private func notifyAdLoadStatus() {
        let status = [
            "banner": isBannerLoaded,
            "interstitial": isInterstitialLoaded,
            "rewarded": isRewardedLoaded
        ]
        methodChannel?.invokeMethod("onAdLoadStatusChanged", arguments: status)
    }
    
    // MARK: - 横幅广告
    @objc func showBannerAd(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("iOS: 开始显示横幅广告")
            print("iOS: 横幅广告加载状态: \(self.isBannerLoaded)")
            print("iOS: 横幅广告视图是否存在: \(self.bannerView != nil)")
            
            // 如果横幅广告未加载，先加载再显示
            if !self.isBannerLoaded {
                print("iOS: 横幅广告未加载，开始加载...")
                self.preloadBannerAd()
                
                // 等待一段时间让广告加载，然后再次尝试显示
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    print("iOS: 检查横幅广告加载状态: \(self.isBannerLoaded)")
                    if self.isBannerLoaded {
                        print("iOS: 横幅广告加载完成，现在显示")
                        self.showBannerAdInternal(result: result)
                    } else {
                        print("iOS: 横幅广告加载超时，返回失败")
                        result(FlutterError(code: "TIMEOUT", message: "横幅广告加载超时", details: nil))
                    }
                }
            } else {
                print("iOS: 横幅广告已加载，直接显示")
                self.showBannerAdInternal(result: result)
            }
        }
    }
    
    // 内部显示横幅广告的方法
    private func showBannerAdInternal(result: @escaping FlutterResult) {
        guard let bannerView = self.bannerView else {
            print("iOS: 横幅广告视图为空")
            result(FlutterError(code: "ERROR", message: "横幅广告视图为空", details: nil))
            return
        }
        
        // 获取根视图控制器
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            print("iOS: 无法获取根视图控制器")
            result(FlutterError(code: "ERROR", message: "无法获取根视图控制器", details: nil))
            return
        }
        
        print("iOS: 开始设置横幅广告视图")
        print("iOS: 横幅广告视图frame: \(bannerView.frame)")
        print("iOS: 横幅广告视图adUnitID: \(bannerView.adUnitID ?? "nil")")
        
        // 直接添加横幅广告到根视图，不使用容器
        rootViewController.view.addSubview(bannerView)
        
        // 设置横幅广告约束 - 显示在屏幕最底部
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor, constant: 0), // 显示在屏幕最底部
            bannerView.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: 320),
            bannerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 确保横幅广告在最前面显示
        rootViewController.view.bringSubviewToFront(bannerView)
        
        print("iOS: 横幅广告视图设置完成")
        print("iOS: 横幅广告位置: bottom: 0, centerX, width: 320, height: 50")
        print("iOS: 横幅广告视图最终frame: \(bannerView.frame)")
        
        // 验证横幅广告是否真的被添加到了视图中
        if rootViewController.view.subviews.contains(bannerView) {
            print("iOS: 横幅广告已成功添加到根视图")
        } else {
            print("iOS: 横幅广告未能添加到根视图")
        }
        
        result(true)
    }
    
    @objc func hideBannerAd(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("iOS: 开始隐藏横幅广告")
            
            if let bannerView = self.bannerView {
                print("iOS: 移除横幅广告视图")
                bannerView.removeFromSuperview()
            }
            
            // 清理容器引用（如果存在）
            self.bannerContainer = nil
            
            print("iOS: 横幅广告隐藏成功")
            result(true)
        }
    }
    
    // MARK: - 插页广告
    @objc func showInterstitialAd(result: @escaping FlutterResult) {
        if isInterstitialLoaded, let interstitialAd = interstitialAd {
            // 广告已加载，直接显示
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                result(FlutterError(code: "ERROR", message: "无法获取根视图控制器", details: nil))
                return
            }
            
            interstitialAd.present(from: rootViewController)
            result(true)
            
            // 显示后立即预加载下一个插页广告
            isInterstitialLoaded = false
            preloadInterstitialAd()
        } else {
            // 广告未加载，尝试加载后显示
            preloadInterstitialAd()
            result(FlutterError(code: "ERROR", message: "插页广告未加载完成", details: nil))
        }
    }
    
    // MARK: - 激励视频广告
    @objc func showRewardedAd(result: @escaping FlutterResult) {
        if isRewardedLoaded, let rewardedAd = rewardedAd {
            // 广告已加载，直接显示
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                result(FlutterError(code: "ERROR", message: "无法获取根视图控制器", details: nil))
                return
            }
            
            // 重置奖励状态
            rewardedAdRewardEarned = false
            
            // 设置激励视频广告的委托来处理观看完成和关闭事件
            rewardedAd.fullScreenContentDelegate = self
            
            rewardedAd.present(from: rootViewController) {
                // 用户完整观看视频，获得奖励
                print("iOS: 用户完整观看激励视频，获得奖励")
                self.rewardedAdRewardEarned = true
                self.notifyRewardedAdSuccess()
            }
            result(true)
            
            // 显示后立即预加载下一个激励视频广告
            isRewardedLoaded = false
            preloadRewardedAd()
        } else {
            // 广告未加载，尝试加载后显示
            preloadRewardedAd()
            result(FlutterError(code: "ERROR", message: "激励视频广告未加载完成", details: nil))
        }
    }
    
    // 通知Flutter激励视频观看成功
    private func notifyRewardedAdSuccess() {
        methodChannel?.invokeMethod("onRewardedAdSuccess", arguments: nil)
    }
    
    // 通知Flutter激励视频观看失败或未完成
    private func notifyRewardedAdFailed() {
        methodChannel?.invokeMethod("onRewardedAdFailed", arguments: nil)
    }
}

// MARK: - BannerViewDelegate
extension AdMobManager: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("iOS: 横幅广告加载成功")
        print("iOS: 横幅广告adUnitID: \(bannerView.adUnitID ?? "nil")")
        print("iOS: 横幅广告frame: \(bannerView.frame)")
        isBannerLoaded = true
        notifyAdLoadStatus()
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("iOS: 横幅广告加载失败: \(error)")
        print("iOS: 横幅广告adUnitID: \(bannerView.adUnitID ?? "nil")")
        isBannerLoaded = false
        notifyAdLoadStatus()
        handleBannerLoadFailure()
    }
    
    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        print("iOS: 横幅广告即将展示全屏内容")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        print("iOS: 横幅广告全屏内容已关闭")
    }
}

// MARK: - FullScreenContentDelegate
extension AdMobManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("全屏广告已关闭")
        
        // 重置广告实例并重新预加载
        if ad is InterstitialAd {
            interstitialAd = nil
            isInterstitialLoaded = false
            preloadInterstitialAd()
        } else if ad is RewardedAd {
            // 激励视频广告关闭时，如果没有获得奖励，则触发失败回调
            print("激励视频广告已关闭，奖励状态: \(rewardedAdRewardEarned)")
            
            // 如果没有获得奖励，说明用户提前关闭了视频
            if !rewardedAdRewardEarned {
                print("iOS: 用户提前关闭激励视频，触发失败回调")
                notifyRewardedAdFailed()
            }
            
            rewardedAd = nil
            isRewardedLoaded = false
            preloadRewardedAd()
        }
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("全屏广告展示失败: \(error)")
        
        // 广告展示失败，重新预加载
        if ad is InterstitialAd {
            isInterstitialLoaded = false
            preloadInterstitialAd()
        } else if ad is RewardedAd {
            // 激励视频广告展示失败，触发失败回调
            notifyRewardedAdFailed()
            isRewardedLoaded = false
            preloadRewardedAd()
        }
    }
}
