//
//  GameCenter.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/16/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "GameCenter.h"
#include <sys/sysctl.h>
#import "SettingsManager.h"
#import "AppDelegate.h"

@implementation GameCenter

+ (GameCenter*) sharedSingleton {
	
	static GameCenter *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[GameCenter alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		if([GameCenter getIsGameCenterAvailable]) {
			[self authenticateGameCenter];
			
			// register for notifications
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoLeaderboards) name:kNavLeaderboardsNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoAchievements) name:kNavAchievementsNotification object:nil];
		}
	}
	return self;
}

#pragma mark -
#pragma mark setters
- (void) setAchievementProgress:(NSString*)identifier percent:(float)percent {
	NSLog(@"Checking achievement: %@ --- progress: %.2f", identifier, percent);
	// see if this achievement has been earned
	NSString *earned = [[SettingsManager sharedSingleton] getString:[NSString stringWithFormat:@"achieve%@", identifier]];
	if([earned isEqualToString:@"2"] && percent >= 100) {
		NSLog(@"Achievement already earned");
		return;
	}
	// tell gamecenter to update achievement's progress
	GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
	if(achievement) {
		// update percent
		achievement.percentComplete = MIN(percent, 100);
		// popup telling player they got the achievement
		if(achievement.percentComplete >= 100 && !earned) {
			//TODO: popup notification here or slide something in letting player know they got an achievement
			[[SettingsManager sharedSingleton] setString:@"1" keyString:[NSString stringWithFormat:@"achieve%@", identifier]];
		}
		[achievement reportAchievementWithCompletionHandler:^(NSError *error) {
			if(error) {
				// try again later
				NSLog(@"Error reporting achievement: %@ --- error: %@", identifier, [error localizedDescription]);
			}
			else {
				// achievement updated successfully
				NSLog(@"Achievement successfully reported: %@", identifier);
				// if it's completed, no longer tell game center about it
				if(percent > 100) {
					[[SettingsManager sharedSingleton] setString:@"2" keyString:[NSString stringWithFormat:@"achieve%@", identifier]];
				}
			}
		}];
	}
}

#pragma mark -
#pragma mark getters
+ (BOOL) getIsGameCenterAvailable {
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	size_t size;  
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);  
	char *machine = malloc(size);  
	sysctlbyname("hw.machine", machine, &size, NULL, 0);  
	NSString *platform = [[NSString alloc] initWithCString:machine encoding:NSUTF8StringEncoding];  
	free(machine);
	BOOL isiPhone3G = [platform isEqualToString:@"iPhone1,2"];
	[platform release];
	
    return (gcClass && osVersionSupported && !isiPhone3G);
}

#pragma mark -
#pragma mark actions
- (void) authenticateGameCenter {
	// unregister and then register for game center authentication changed
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	// attempt to authenticate player with game center
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if(error) {
			NSLog(@"Game Center authentication failed");
		}
		else {
			NSLog(@"Game Center authentication success");
#ifdef RESET_ACHIEVEMENTS
				[self resetAchievements];
#endif
		}
	}];
}

- (void) resetAchievements {
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
		if(error) {
			NSLog(@"Error resetting achievements: %@", [error localizedDescription]);
		}
		else {
			NSLog(@"Success resetting achievements");
		}
	}];
}

- (void) checkStatAchievements {
	// coin related achievements
	int totalCoins = [[SettingsManager sharedSingleton] getInt:@"totalCoins"];
	[self setAchievementProgress:@"15" percent:totalCoins/1000.0 * 100];	// thousand-aire
	[self setAchievementProgress:@"16" percent:totalCoins/100000.0 * 100];	// hundred thousand-aire
	[self setAchievementProgress:@"17" percent:totalCoins/1000000.0 * 100];	// millionaire
	
	// distance related achievements
	int totalMeters = [[SettingsManager sharedSingleton] getInt:@"totalMeters"];
	[self setAchievementProgress:@"5" percent:totalMeters/500.0 * 100];			// 5k
	[self setAchievementProgress:@"6" percent:totalMeters/10000.0 * 100];		// 10k
	[self setAchievementProgress:@"7" percent:totalMeters/356400000.0 * 100];	// to the moon
	[self setAchievementProgress:@"8" percent:totalMeters/712800000.0 * 100];	// and back
	
	// dropship related achievements
	int totalDropships = [[SettingsManager sharedSingleton] getInt:@"totalDropships"];
	[self setAchievementProgress:@"2" percent:totalDropships/50.0 * 100];
	[self setAchievementProgress:@"4" percent:totalDropships/500.0 * 100];
	
	// enemy related achievements
	int totalEnemies = [[SettingsManager sharedSingleton] getInt:@"totalEnemies"];
	[self setAchievementProgress:@"1" percent:totalEnemies/50.0 * 100];
	[self setAchievementProgress:@"3" percent:totalEnemies/1000.0 * 100];
}

- (void) checkItemAchievements {
	int totalWeapons = [[SettingsManager sharedSingleton] getInt:@"totalWeapons"];
	[self setAchievementProgress:@"9" percent:totalWeapons/2.0 * 100];		// check 1 higher because pistol is included
	[self setAchievementProgress:@"10" percent:totalWeapons/4.0 * 100];		// check 1 higher because pistol is included
	[self setAchievementProgress:@"11" percent:totalWeapons/11.0 * 100];
	[self setAchievementProgress:@"12" percent:[[SettingsManager sharedSingleton] getBool:@"ripley"] * 100];
	[self setAchievementProgress:@"13" percent:[[SettingsManager sharedSingleton] getBool:@"ultraLaser"] * 100];
	[self setAchievementProgress:@"18" percent:[[SettingsManager sharedSingleton] getBool:@"spreadgun"] * 100];
	[self setAchievementProgress:@"19" percent:[[SettingsManager sharedSingleton] getBool:@"wavegun"] * 100];
	[self setAchievementProgress:@"20" percent:[[SettingsManager sharedSingleton] getBool:@"flamethrower"] * 100];
}

- (void) submitLeaderboards {
	[self submitLeaderboard:@"distanceTraveled" withValue:[[SettingsManager sharedSingleton] getInt:@"currentMeters"] * 100];
}
	 
- (void) submitLeaderboard:(NSString*)name withValue:(int64_t)value {
	NSLog(@"Submitting leaderboard: %@ --- value: %lld", name, value);
	GKScore *leaderboard = [[GKScore alloc] initWithCategory:name];
	if(leaderboard) {
		leaderboard.value = value;
		[leaderboard reportScoreWithCompletionHandler:^(NSError *error) {
			if(error) {
				NSLog(@"Error submitting leaderboard: %@ --- error: %@", name, [error localizedDescription]);
			}
			else {
				NSLog(@"Success submitting leaderboard: %@ --- value: %lld", name, value);
			}
		}];
		[leaderboard release];
	}
}

- (void) authenticationChanged {
	if([GKLocalPlayer localPlayer].isAuthenticated) {
		NSLog(@"Player is now authenticated with Game Center");
	}
	else {
		NSLog(@"Player lost connection to Game Center");
	}
}

#pragma mark -
#pragma mark notifications
- (void) gotoLeaderboards {
	// make leaderboard controller and present it
	GKLeaderboardViewController *leaderboardController = [GKLeaderboardViewController new];
	if(leaderboardController) {
		leaderboardController.leaderboardDelegate = self;
		AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDel.viewController presentModalViewController:leaderboardController animated:YES];
	}
	[leaderboardController release];
}

- (void) gotoAchievements {
	// make achievement controller and present it
	GKAchievementViewController *achievementController = [GKAchievementViewController new];
	if(achievementController) {
		achievementController.achievementDelegate = self;
		AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDel.viewController presentModalViewController:achievementController animated:YES];
	}
	[achievementController release];
}

#pragma mark -
#pragma mark GKLeaderboardViewControllerDelegate
- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDel.viewController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark GKAchievementViewControllerDelegate
- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
	AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDel.viewController dismissModalViewControllerAnimated:YES];
}

@end
