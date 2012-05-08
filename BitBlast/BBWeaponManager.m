//
//  BBWeaponManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/16/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBWeaponManager.h"


@implementation BBWeaponManager

@synthesize weapons;

+ (BBWeaponManager*) sharedSingleton {
	
	static BBWeaponManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBWeaponManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		// create weapons set
		weapons = [NSMutableSet new];
		
		// see if player has an equipped weapon saved
		if([[SettingsManager sharedSingleton] getString:@"equippedWeapon"]) {
			[self equip:[[SettingsManager sharedSingleton] getString:@"equippedWeapon"]];
		}
		else {
			[self equip:@"pistol"];
		}
	}
	return self;
}

- (void) dealloc {
	[weapons release];
	[super dealloc];
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	for(BBWeapon *w in weapons) {
		[w setEnabled:newEnabled];
	}
}

- (void) setScale:(float)scale {
	for(BBWeapon *w in weapons) {
		[w setScale:scale];
	}
}

- (void) setNode:(CCNode *)node {
	for(BBWeapon *w in weapons) {
		[w setNode:node];
	}
}

#pragma mark -
#pragma mark actions
- (void) equip:(NSString*)newWeapon {
	BBWeapon *w = [BBWeapon new];
	[w loadFromFile:newWeapon];
	//[w setEnabled:YES];
	[weapons addObject:w];
	[w release];
	
	// if this weapon is newly purchased, increment number of weapons owned
	if(![[SettingsManager sharedSingleton] getBool:newWeapon]) {
		[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"totalWeapons"];
	}
	// save the item to device
	[[SettingsManager sharedSingleton] setBool:YES keyString:newWeapon];
	// keep track of most recently equipped weapon
	[[SettingsManager sharedSingleton] setString:newWeapon keyString:@"equippedWeapon"];
	
	// post notification that weapon was equipped
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerEquipWeaponNotification object:nil]];
}

- (void) unequip:(NSString*)oldWeapon {
	for(BBWeapon *w in weapons) {
		if([w.identifier isEqualToString:oldWeapon]) {
			[w setEnabled:NO];
			[w clearLasers];
			[weapons removeObject:w];
			break;
		}
	}
}

- (void) unequipAll {
	for(BBWeapon *w in weapons) {
		[self unequip:w.identifier];
	}
}

@end
