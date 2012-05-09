//
//  BBPowerupManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 5/2/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBPowerupManager.h"

@implementation BBPowerupManager

+ (BBPowerupManager*) sharedSingleton {
	
	static BBPowerupManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBPowerupManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

#pragma mark -
#pragma mark getters
- (int) getHealthPowerup {
	if([[SettingsManager sharedSingleton] getInt:@"3hearts"]) {
		[[SettingsManager sharedSingleton] incrementInteger:-1 keyString:@"3hearts"];
		return 3;
	}
	else if([[SettingsManager sharedSingleton] getInt:@"2hearts"]) {
		[[SettingsManager sharedSingleton] incrementInteger:-1 keyString:@"2hearts"];
		return 2;
	}
	else if([[SettingsManager sharedSingleton] getInt:@"1heart"]) {
		[[SettingsManager sharedSingleton] incrementInteger:-1 keyString:@"1heart"];
		return 1;
	}
	return 0;
}

- (int) getCoinMultPowerup {
	if([[SettingsManager sharedSingleton] getInt:@"6xcoins"]) {
		[[SettingsManager sharedSingleton] incrementInteger:-1 keyString:@"6xcoins"];
		return 6;
	}
	else if([[SettingsManager sharedSingleton] getInt:@"4xcoins"]) {
		[[SettingsManager sharedSingleton] incrementInteger:-1 keyString:@"4xcoins"];
		return 4;
	}
	else if([[SettingsManager sharedSingleton] getInt:@"2xcoins"]) {
		[[SettingsManager sharedSingleton] incrementInteger:-1 keyString:@"2xcoins"];
		return 2;
	}
	return 1;
}

- (int) getGunPowerup {
	if([[SettingsManager sharedSingleton] getInt:@"gunspeed"]) {
		[[SettingsManager sharedSingleton] incrementInteger:-1 keyString:@"gunspeed"];
		return 2;
	}
	return 1;
}

- (float) getSpeedPowerup {
	if([[SettingsManager sharedSingleton] getInt:@"speedboost"]) {
		[[SettingsManager sharedSingleton] incrementInteger:-1 keyString:@"speedboost"];
		return 1.5;
	}
	return 1;
}

@end
