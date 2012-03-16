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
#pragma mark actions
- (void) equip:(NSString*)newWeapon {
	BBWeapon *w = [BBWeapon new];
	[w loadFromFile:newWeapon];
	[w setEnabled:YES];
	[weapons addObject:w];
	[w release];
	
	// keep track of most recently equipped weapon
	[[SettingsManager sharedSingleton] setString:newWeapon keyString:@"equippedWeapon"];
}

- (void) unequip:(NSString*)oldWeapon {
	for(BBWeapon *w in weapons) {
		if([w.identifier isEqualToString:oldWeapon]) {
			[weapons removeObject:w];
			break;
		}
	}
}

- (void) unequipAll {
	[weapons removeAllObjects];
}

@end
