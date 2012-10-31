//
//  AppDelegate.h
//  Gun Runner
//
//  Created by Kristian Bauer on 10/17/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "BBNavigationController.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	BBNavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) BBNavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
