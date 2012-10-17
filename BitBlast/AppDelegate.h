//
//  AppDelegate.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright Bauerkraut 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsManager.h"
#import "LocalyticsSession.h"
#import "GameCenter.h"
#import "IAPManager.h"
#import "SimpleAudioEngine.h"
#import "BBDeviceManager.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, readonly) RootViewController *viewController;

@end
