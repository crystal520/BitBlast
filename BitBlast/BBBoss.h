//
//  BBBoss.h
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMovingObject.h"
#import "BBBossPiece.h"

@interface BBBoss : BBMovingObject {
    // different pieces of the boss
    NSMutableArray *pieces;
    // laser blast flash
    BBGameObject *laserFlash;
    // whether or not this boss is enabled
    BOOL enabled;
    // reference to a BBExplosionManager
    BBExplosionManager *explosionManager;
    // whether the boss is alive or not
    BOOL alive;
}

@property (nonatomic, assign) BBExplosionManager *explosionManager;
@property (nonatomic, assign) BOOL enabled;

@end
