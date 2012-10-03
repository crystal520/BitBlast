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
		// create weapons dictionary
		weapons = [NSMutableDictionary new];
        
        // create weapon inventories
        for(int i=0;i<WEAPON_INVENTORY_COUNT;i++) {
            NSMutableSet *inventory = [NSMutableSet new];
            [weapons setObject:inventory forKey:[NSString stringWithFormat:@"%i", i]];
            [inventory release];
        }
		
		// see if player has an equipped weapon saved
		if([[SettingsManager sharedSingleton] getString:@"equippedWeapon"]) {
			[self equip:[[SettingsManager sharedSingleton] getString:@"equippedWeapon"] forType:WEAPON_INVENTORY_PLAYER];
		}
		else {
            [[SettingsManager sharedSingleton] setBool:YES keyString:@"pistol"];
			[self equip:@"pistol" forType:WEAPON_INVENTORY_PLAYER];
		}
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kNavResumeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
	}
	return self;
}

- (void) dealloc {
	[weapons release];
	[super dealloc];
}

#pragma mark -
#pragma mark getters
- (NSSet*) weaponsForType:(WeaponInventory)type {
    return [weapons objectForKey:[NSString stringWithFormat:@"%i", type]];
}

- (BBWeapon*) weaponWithID:(NSString*)weaponID forType:(WeaponInventory)type {
    for(BBWeapon *w in [self weaponsForType:type]) {
        if([w.identifier isEqualToString:weaponID]) {
            return w;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled forType:(WeaponInventory)type {
    NSSet *inventory = [weapons objectForKey:[NSString stringWithFormat:@"%i", type]];
	for(BBWeapon *w in inventory) {
		[w setEnabled:newEnabled];
	}
}

- (void) setScale:(float)scale forType:(WeaponInventory)type {
    NSSet *inventory = [weapons objectForKey:[NSString stringWithFormat:@"%i", type]];
	for(BBWeapon *w in inventory) {
		[w setScale:scale];
	}
}

- (void) setNode:(CCNode*)node {
    for(int i=0;i<WEAPON_INVENTORY_COUNT;i++) {
        [self setNode:node forType:(WeaponInventory)(i)];
    }
}

- (void) setNode:(CCNode *)node forType:(WeaponInventory)type {
    NSSet *inventory = [weapons objectForKey:[NSString stringWithFormat:@"%i", type]];
	for(BBWeapon *w in inventory) {
		[w setNode:node];
	}
}

- (void) setGunSpeedMultiplier:(float)multiplier forType:(WeaponInventory)type {
    NSSet *inventory = [weapons objectForKey:[NSString stringWithFormat:@"%i", type]];
	for(BBWeapon *w in inventory) {
		[w setGunSpeedMultiplier:multiplier];
	}
}

#pragma mark -
#pragma mark actions
- (void) equip:(NSString*)newWeapon forType:(WeaponInventory)type {
    NSMutableSet *inventory = [weapons objectForKey:[NSString stringWithFormat:@"%i", type]];
	BBWeapon *w = [BBWeapon new];
    
    // set weapon type based on inventory
    switch (type) {
        case WEAPON_INVENTORY_PLAYER:
            w.type = WEAPON_TYPE_PLAYER;
            break;
        default:
            w.type = WEAPON_TYPE_ENEMY;
            break;
    }
    
	[w loadFromFile:newWeapon];
	[inventory addObject:w];
    [w release];
	
	// keep track of most recently equipped OWNED weapon (for allowing shop previews)
    if(type == WEAPON_INVENTORY_PLAYER) {
        if([[SettingsManager sharedSingleton] getBool:newWeapon]) {
            [[SettingsManager sharedSingleton] setString:newWeapon keyString:@"equippedWeapon"];
        }
        
        // post notification that weapon was equipped
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPlayerEquipWeaponNotification object:nil]];
    }
}

- (void) unequip:(NSString*)oldWeapon forType:(WeaponInventory)type {
    NSMutableSet *inventory = [weapons objectForKey:[NSString stringWithFormat:@"%i", type]];
	for(BBWeapon *w in inventory) {
		if([w.identifier isEqualToString:oldWeapon]) {
			[w setEnabled:NO];
			[w clearLasers];
			[inventory removeObject:w];
			break;
		}
	}
}

- (void) unequipAllForType:(WeaponInventory)type {
    NSSet *inventory = [weapons objectForKey:[NSString stringWithFormat:@"%i", type]];    
	while([inventory count] > 0) {
        BBWeapon *w = [inventory anyObject];
		[self unequip:w.identifier forType:type];
	}
}

#pragma mark -
#pragma mark notifications
- (void) pause {
    NSArray *keys = [weapons allKeys];
    for(NSString *k in keys) {
        NSSet *inventory = [weapons objectForKey:k];
        for(BBWeapon *w in inventory) {
            [w pause];
        }
    }
}

- (void) resume {
    NSArray *keys = [weapons allKeys];
    for(NSString *k in keys) {
        NSSet *inventory = [weapons objectForKey:k];
        for(BBWeapon *w in inventory) {
            [w resume];
        }
    }
}

- (void) gameOver {
    NSArray *keys = [weapons allKeys];
    for(NSString *k in keys) {
        NSSet *inventory = [weapons objectForKey:k];
        for(BBWeapon *w in inventory) {
            [w gameOver];
        }
    }
}

@end
