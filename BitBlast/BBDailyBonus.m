//
//  BBDailyBonus.m
//  GunRunner
//
//  Created by Kristian Bauer on 5/5/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBDailyBonus.h"

@implementation BBDailyBonus

+ (BBDailyBonus*) sharedSingleton {
	
	static BBDailyBonus *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBDailyBonus alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		//[self checkDailyStreak];
	}
	return self;
}

- (void) checkDailyStreak {
	// get previous day the game was played
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
	[formatter setDateStyle:NSDateFormatterFullStyle];
	NSDate *lastPlayed = [formatter dateFromString:[[SettingsManager sharedSingleton] getString:@"lastPlayed"]];
	NSDate *today = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
	NSLog(@"BBDailyBonus last played: %@ --- today: %@", [lastPlayed description], [today description]);
	NSLog(@"BBDailyBonus difference: %i", (NSInteger)([today timeIntervalSinceDate:lastPlayed]));
	
	// compare last played date to now
	// if it's the next day, increment daily streak
	if([today timeIntervalSinceDate:lastPlayed] >= 86400 && [today timeIntervalSinceDate:lastPlayed] < 172800) {
		NSLog(@"BBDailyBonus incrementing daily streak from %i to %i", [[SettingsManager sharedSingleton] getInt:@"dailyStreak"], [[SettingsManager sharedSingleton] getInt:@"dailyStreak"]+1);
		[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"dailyStreak"];
	}
	// if it's 2 days past or greater, reset it. or if the player doesn't have a daily streak set, set it
	else if([today timeIntervalSinceDate:lastPlayed] >= 172800 || ![[SettingsManager sharedSingleton] getInt:@"dailyStreak"]) {
		NSLog(@"BBDailyBonus resetting daily streak");
		[[SettingsManager sharedSingleton] setInteger:1 keyString:@"dailyStreak"];
	}
	// if the 2 days are different or there is no daily streak yet
	if([today timeIntervalSinceDate:lastPlayed] != 0 || ![[SettingsManager sharedSingleton] getInt:@"dailyStreak"]) {
		[[SessionMWrapper sharedSingleton] sessionEvent:@"dailyBonus"];
		[self resetDailyStreakStats];
	}
	NSLog(@"BBDailyBonus current streak: %i", [[SettingsManager sharedSingleton] getInt:@"dailyStreak"]);
	
	// set a new previous day played
	[[SettingsManager sharedSingleton] setString:[formatter stringFromDate:[NSDate date]] keyString:@"lastPlayed"];
}

- (void) resetDailyStreakStats {
	[[SettingsManager sharedSingleton] setInteger:0 keyString:@"dailyCoins"];
	[[SettingsManager sharedSingleton] setInteger:0 keyString:@"dailyEnemies"];
	[[SettingsManager sharedSingleton] setInteger:0 keyString:@"dailyDropships"];
	[[SettingsManager sharedSingleton] setInteger:0 keyString:@"dailyDistance"];
}

@end
