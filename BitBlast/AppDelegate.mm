//
//  AppDelegate.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright Bauerkraut 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "BBGameLayer.h"
#import "RootViewController.h"
#import "SettingsManager.h"
#import "PromoManager.h"
#import "Chartboost.h"
#import "BBDailyBonus.h"
#import "SessionMWrapper.h"

@implementation AppDelegate

@synthesize window, viewController;

- (void) removeStartupFlicker
{

}

- (void) applicationDidFinishLaunching:(UIApplication*)application

{
	// make sure audio engine is set up
	[SimpleAudioEngine sharedEngine];
    // attempt to connect to game center if available
	[GameCenter sharedSingleton];
	// attempt to get IAP
	[IAPManager sharedSingleton];
	// load saved game data
	[[SettingsManager sharedSingleton] loadFromFile:@"player.plist"];
	// load SessionM queue. also, start SessionM!
	[[SessionMWrapper sharedSingleton] loadQueue];
	
	// seed the random number generator
	srandom(time(NULL));
	
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	// enable multi-touch
	[glView setMultipleTouchEnabled:YES];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	//[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
    if([BBDeviceManager iOSVersionGreaterThan:@"6.0"]) {
        window.rootViewController = viewController;
    }
    else {
        [window addSubview: viewController.view];
    }
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene:[BBGameLayer scene]];
	
	// Override point for customization after application launch.
	[[LocalyticsSession sharedLocalyticsSession] startSession:@"7f34f42eb738225af85f165-2d1da334-6f9f-11e1-200b-00a68a4c01fc"];
	
	// Configure Chartboost
    Chartboost *cb = [Chartboost sharedChartboost];
    cb.appId = @"4f98d76ef77659e64f000023";
    cb.appSignature = @"9d0624026bada35dc30be246e209880b0848f681";
    
    // Notify the beginning of a user session
    [cb startSession];
    
    // Show an interstitial
    [cb showInterstitial];
    
    // start the TestFlight session
    [TestFlight takeOff:@"0062c6fa2e325ad3ac0770b55f750df5_MTExNjM5MjAxMi0wOC0yMyAyMzowNzozMi43ODA3NDU"];
    
    // keep track of device ID
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
	
	self.window.rootViewController = viewController;
	[self.window makeKeyAndVisible];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self applicationDidFinishLaunching:application];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// save sessionM queue
	[[SessionMWrapper sharedSingleton] saveQueue];
	// save game data first
	[[SettingsManager sharedSingleton] saveToFile:@"player.plist"];
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
	[[PromoManager sharedSingleton] resume];
	[[BBDailyBonus sharedSingleton] checkDailyStreak];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector].runningScene onExit];
    
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
	[[CCDirector sharedDirector].runningScene onEnter];
	
	// let everything know that the game is pausing
    if([Globals sharedSingleton].gameState == kStateGame) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavPauseNotification object:nil]];
    }
    
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// save sessionM queue
	[[SessionMWrapper sharedSingleton] saveQueue];
	// save game data first
	[[SettingsManager sharedSingleton] saveToFile:@"player.plist"];
    
	
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
    
    // Close Localytics Session
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else  /* iphone */
        return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
