//
//  MediaAdController.m
//  Runner
//
//  Created by admin on 2025/8/5.
//

#import <Foundation/Foundation.h>
#import "MediaAdController.h"
#import "Runner-Swift.h"
#import <Flutter/Flutter.h>
@implementation MediaAdController

NSDate *_lastInterstitialDisplayTime_cache;

IMBanner *_bannerAdInstance_view;
UIView *_adContainerView_holder;

IMInterstitial *_interstitialAdInstance_page;

IMInterstitial *_rewardedVideoInstance_media;


NSString* _accountIdentifier_key = @"40554dacd2664e479b98f1fc4a8b30b8";

int64_t _bannerPlacementId_slot = 10000450694;

int64_t _interstitialPlacementId_page = 10000450693;

int64_t _rewardedVideoPlacementId_video = 10000450695;

+ (void) _setupAdPlatform_init
{
    NSLog(@"开始初始化 InMobi SDK...");
    
    // 1. 创建广告容器
    _adContainerView_holder = [[UIView alloc] init];
    _adContainerView_holder.translatesAutoresizingMaskIntoConstraints = NO;
    _adContainerView_holder.backgroundColor = [UIColor clearColor];
    _adContainerView_holder.clipsToBounds = YES;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootVC = appDelegate.window.rootViewController;
    [rootVC.view addSubview:_adContainerView_holder];
    
    // 2. 设置容器约束（底部居中）
    [MediaAdController _configureContainerLayout_setup];
    
    // 3. 初始化横幅广告
    CGFloat adWidth = 320;
    CGFloat adHeight = 50;
    _bannerAdInstance_view = [[IMBanner alloc] initWithFrame:CGRectMake(0, 0, adWidth, adHeight)
                                       placementId:_bannerPlacementId_slot];
    _bannerAdInstance_view.delegate = MediaAdController._sharedInstance_impl;
    [_adContainerView_holder addSubview:_bannerAdInstance_view];
    _adContainerView_holder.hidden = YES;
    
    // 4. 加载广告
    [_bannerAdInstance_view load];
    
    // 加载插页广告
    _interstitialAdInstance_page = [[IMInterstitial alloc] initWithPlacementId:_interstitialPlacementId_page];
    _interstitialAdInstance_page.delegate = MediaAdController._sharedInstance_impl;
    [_interstitialAdInstance_page load];
    
    // 加载激励视频广告
    _rewardedVideoInstance_media = [[IMInterstitial alloc] initWithPlacementId:_rewardedVideoPlacementId_video];
    _rewardedVideoInstance_media.delegate = MediaAdController._sharedInstance_impl;
    [_rewardedVideoInstance_media load];
    
    NSLog(@"InMobi 广告初始化完成");
}

#pragma mark - 展示激励视频广告
+ (void)_showRewardedVideoAd_play {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootVC = appDelegate.window.rootViewController;
    if (_rewardedVideoInstance_media.isReady) {
        [_rewardedVideoInstance_media showFrom:rootVC];
    } else {
        NSLog(@"最高价激励视频广告尚未准备好");
        [_rewardedVideoInstance_media load];
        [MediaAdController _notifyRewardVideoFailure_callback];
    }
}

+ (bool)_isRewardedVideoReady_check
{
    if (_rewardedVideoInstance_media.isReady)//有一个加载成功就行
        return true;
    else
        return false;
}

+ (BOOL)_checkTimeIntervalExceeds15s_validate{
  NSDate *now = [NSDate date];
  NSTimeInterval timeIntervalBetweenNowAndLoadTime = [now timeIntervalSinceDate:_lastInterstitialDisplayTime_cache];
  return timeIntervalBetweenNowAndLoadTime > 15;
}

#pragma mark - 展示插页广告
+ (void)_presentInterstitialAd_display{
    if([self _checkTimeIntervalExceeds15s_validate])
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *rootVC = appDelegate.window.rootViewController;
        if (_interstitialAdInstance_page.isReady) {
            [_interstitialAdInstance_page showFrom:rootVC];
            _lastInterstitialDisplayTime_cache = [NSDate date];
        } else {
            NSLog(@"最高价插页广告尚未准备好");
            [_interstitialAdInstance_page load];
        }
    }
}


//以下部分是inmobi的delegate函数，请不要修改函数名及变量名。
#pragma mark - IMInterstitialDelegate
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    NSLog(@"插页广告加载成功");
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    NSLog(@"插页广告加载失败: %@", error.localizedDescription);
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    NSLog(@"插页广告已展示");
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    NSLog(@"插页广告已关闭");
    [interstitial load];
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    NSLog(@"用户与插页广告进行了交互");
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    NSLog(@"奖励动作完成: %@", rewards);
    [MediaAdController _notifyRewardVideoSuccess_callback];
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial {
    NSLog(@"用户即将离开应用");
}

#pragma mark - IMBannerDelegate
- (void)bannerDidFinishLoading:(IMBanner *)banner {
    NSLog(@"广告加载成功");
    [MediaAdController _centerBannerInContainer_align];
    // 横幅广告加载成功后不自动显示，保持隐藏状态
    // [MediaAdController _displayBannerAd_show];
}

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error {
    NSLog(@"广告加载失败: %@", error.localizedDescription);
}
///结束inmobi的delegate函数部分


+ (void)_displayBannerAd_show
{
    if(_adContainerView_holder!=NULL)
        _adContainerView_holder.hidden = NO;
}
+ (void)_concealBannerAd_hide
{
    if(_adContainerView_holder!=NULL)
        _adContainerView_holder.hidden = YES;
}

#pragma mark - 设置广告容器约束
+ (void)_configureContainerLayout_setup {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootVC = appDelegate.window.rootViewController;
    // 3. 初始化横幅广告
    CGFloat adWidth = 320;
    CGFloat adHeight = 50;
    // 容器高度 = 广告高度 + 安全区域底部间距
    [_adContainerView_holder.heightAnchor constraintEqualToConstant:adHeight].active = YES;
    
    // 容器宽度 = 广告宽度
    [_adContainerView_holder.widthAnchor constraintEqualToConstant:adWidth].active = YES;
    
    // 水平居中
    [_adContainerView_holder.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor].active = YES;
    
    // 底部约束（关键：考虑安全区域）
    if (@available(iOS 11.0, *)) {
        [_adContainerView_holder.bottomAnchor constraintEqualToAnchor:rootVC.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    } else {
        [_adContainerView_holder.bottomAnchor constraintEqualToAnchor:rootVC.view.bottomAnchor].active = YES;
    }
}

#pragma mark - 居中广告
+ (void)_centerBannerInContainer_align {
    // 确保在主线程更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat containerWidth = _adContainerView_holder.frame.size.width;
        CGFloat containerHeight = _adContainerView_holder.frame.size.height;
        CGFloat adWidth = _bannerAdInstance_view.frame.size.width;
        CGFloat adHeight = _bannerAdInstance_view.frame.size.height;
        
        // 计算居中位置
        CGFloat adX = (containerWidth - adWidth) / 2;
        CGFloat adY = (containerHeight - adHeight) / 2;
        
        // 更新广告位置
        _bannerAdInstance_view.frame = CGRectMake(adX, adY, adWidth, adHeight);
    });
}

// OC 端回调 Flutter 视频观看完成
+ (void)_notifyRewardVideoSuccess_callback {
    // 1. Get the AppDelegate instance (Corrected)
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    // 2. Call the Swift method (Corrected)
    if ([appDelegate respondsToSelector:@selector(sendEventToFlutterWithEventName:data:)]) {
        [appDelegate sendEventToFlutterWithEventName:@"onRewardVideoWatched" data:nil];
    } else {
        NSLog(@"AppDelegate does not respond to sendEventToFlutterWithEventName:data:");
    }
}

// OC 端回调 Flutter 视频观看失败
+ (void)_notifyRewardVideoFailure_callback {
    // 1. Get the AppDelegate instance (Corrected)
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    // 2. Call the Swift method (Corrected)
    if ([appDelegate respondsToSelector:@selector(sendEventToFlutterWithEventName:data:)]) {
        [appDelegate sendEventToFlutterWithEventName:@"onRewardVideoFailed" data:nil];
    } else {
        NSLog(@"AppDelegate does not respond to sendEventToFlutterWithEventName:data:");
    }
}

+ (instancetype)_sharedInstance_impl {
    static MediaAdController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)_initializeAdPlatform_core{
    
    [MediaAdController _setupAdPlatform_init];
    _lastInterstitialDisplayTime_cache = [NSDate date];
}

@end
