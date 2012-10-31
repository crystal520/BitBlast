//
//  BBNavigationController.m
//  Gun Runner
//
//  Created by Kristian Bauer on 10/31/12.
//
//

#import "BBNavigationController.h"

@interface BBNavigationController ()

@end

@implementation BBNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    
    // start Localytics session
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
    
    // keep track of device ID, for testing purposes
#ifdef DEBUG_TEST_FLIGHT_DEVICE
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void) applicationWillResignActive {
    // save sessionM queue
	[[SessionMWrapper sharedSingleton] saveQueue];
	// save game data first
	[[SettingsManager sharedSingleton] saveToFile:@"player.plist"];
}

- (void) applicationDidBecomeActive {
    [[PromoManager sharedSingleton] resume];
	[[BBDailyBonus sharedSingleton] checkDailyStreak];
}

- (void) applicationDidEnterBackground {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void) applicationWillEnterForeground {
    // let everything know that the game is pausing
    if([Globals sharedSingleton].gameState == kStateGame) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavPauseNotification object:nil]];
    }
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void) applicationWillTerminate {
    // save sessionM queue
	[[SessionMWrapper sharedSingleton] saveQueue];
	// save game data first
	[[SettingsManager sharedSingleton] saveToFile:@"player.plist"];
    // close Localytics session
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void) applicationDidReceiveMemoryWarning {
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

@end
