//
//  BBWeaponManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/16/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBWeapon.h"
#import "SettingsManager.h"

@interface BBWeaponManager : NSObject {
    NSMutableSet *weapons;
}

@property (nonatomic, readonly) NSMutableSet *weapons;

+ (BBWeaponManager*) sharedSingleton;
// setters
- (void) setEnabled:(BOOL)newEnabled;
- (void) setScale:(float)scale;
- (void) setNode:(CCNode*)node;
- (void) setGunSpeedMultiplier:(float)multiplier;
// actions
- (void) equip:(NSString*)newWeapon;
- (void) unequip:(NSString*)oldWeapon;
- (void) unequipAll;

@end
