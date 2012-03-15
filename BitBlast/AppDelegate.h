//
//  AppDelegate.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright Bauerkraut 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsManager.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
