//
//  BBWeaponManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/16/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBWeapon.h"

@interface BBWeaponManager : NSObject {
    NSMutableDictionary *weapons;
    // last equipped item that player actually owns
    NSMutableString *lastEquipped;
}

@property (nonatomic, readonly) NSMutableDictionary *weapons;

+ (BBWeaponManager*) sharedSingleton;
// getters
- (NSSet*) weaponsForType:(WeaponInventory)type;
- (BBWeapon*) weaponWithID:(NSString*)weaponID forType:(WeaponInventory)type;
// setters
- (void) setEnabled:(BOOL)newEnabled forType:(WeaponInventory)type;
- (void) setScale:(float)scale forType:(WeaponInventory)type;
- (void) setNode:(CCNode*)node;
- (void) setNode:(CCNode*)node forType:(WeaponInventory)type;
- (void) setGunSpeedMultiplier:(float)multiplier forType:(WeaponInventory)type;
// actions
- (void) equip:(NSString*)newWeapon forType:(WeaponInventory)type;
- (void) unequip:(NSString*)oldWeapon forType:(WeaponInventory)type;
- (void) unequipAllForType:(WeaponInventory)type;
- (void) pause;
- (void) resume;

@end
