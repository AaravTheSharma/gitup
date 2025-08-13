//
//  MediaAdController.h
//  Runner
//
//  Created by admin on 2025/8/5.
//

@import InMobiSDK;
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaAdController : NSObject<IMBannerDelegate,IMInterstitialDelegate>

+ (instancetype)_sharedInstance_impl;
+ (void)_initializeAdPlatform_core;

+ (void)_displayBannerAd_show;
+ (void)_concealBannerAd_hide;
+ (void)_presentInterstitialAd_display;
+ (void)_showRewardedVideoAd_play;
+ (bool)_isRewardedVideoReady_check;

@end

NS_ASSUME_NONNULL_END
