//
//  BBBoss.h
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMovingObject.h"
#import "BBBossPiece.h"
#import "BBExplosionManager.h"
#import "BBWeaponManager.h"

typedef enum {
    BOSS_STATE_INTRO = 0,
    BOSS_STATE_BATTLE,
    BOSS_STATE_DEAD
} BossState;

@interface BBBoss : BBMovingObject {
    // current state of the boss
    BossState state;
    // different pieces of the boss
    NSMutableArray *pieces;
    // whether or not this boss is enabled
    BOOL enabled;
    // reference to a BBExplosionManager
    BBExplosionManager *explosionManager;
    // whether the boss is alive or not
    BOOL alive;
    // current health this boss has
    float curHealth;
    // maximum health this boss can have
    float maxHealth;
    // sound when boss piece is hit by bullet
    CDSoundSource *hitSound;
    // dictionary of sounds
    NSMutableDictionary *sounds;
    // current ai stage, based on health
    int currentAIStage;
    // keep track of current top weapon (for opening and closing mouth)
    NSMutableString *currentTopWeapon;
    // keep track of current bottom weapon (for flashing laser blast image on gun)
    NSMutableString *currentBottomWeapon;
}

@property (nonatomic, assign) BBExplosionManager *explosionManager;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) int currentAIStage;

// setters
- (void) setState:(BossState)newState;
// getters
- (BBBossPiece*) getPieceWithType:(NSString*)pieceType;
- (NSDictionary*) getAIStage;
// update
- (void) updateWeapons:(float)delta;
- (void) updatePieces:(float)delta;
// actions
- (void) reset;
- (void) equipTopWeapon;
- (void) equipBottomWeapon;
- (void) clearWeapons;
- (void) hitByBullet:(BBBullet*)bullet;
- (void) flash;
- (void) die;
- (void) fadeInAlpha;
- (void) fadeInColor;

@end
