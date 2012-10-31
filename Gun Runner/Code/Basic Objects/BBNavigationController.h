//
//  BBNavigationController.h
//  Gun Runner
//
//  Created by Kristian Bauer on 10/31/12.
//
//

#import <UIKit/UIKit.h>
#import "SimpleAudioEngine.h"
#import "GameCenter.h"
#import "IAPManager.h"
#import "SessionMWrapper.h"
#import "ChartBoost.h"
#import "TestFlight.h"
#import "PromoManager.h"
#import "BBDailyBonus.h"
#import "LocalyticsSession.h"

@interface BBNavigationController : UINavigationController

- (void) applicationWillResignActive;
- (void) applicationDidBecomeActive;
- (void) applicationDidEnterBackground;
- (void) applicationWillEnterForeground;
- (void) applicationWillTerminate;
- (void) applicationDidReceiveMemoryWarning;

@end
