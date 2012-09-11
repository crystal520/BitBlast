//
//  BBBossPiece.h
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBGameObject.h"
#import "BBBullet.h"
#import "BBExplosionManager.h"
#import "SimpleAudioEngine.h"

@interface BBBossPieceShape : BBGameObjectShape {}
@end

@interface BBBossPiece : BBGameObject {
    // what type of boss piece this is
    NSString *type;
    // current health this boss piece has
    float curHealth; 
    // maximum health this boss piece can have
    float maxHealth;
    // number of coins this piece drops upon losing all its health
    int coins;
    // whether or not the boss piece has died
	BOOL alive;
    // whether or not this boss piece is enabled
    BOOL enabled;
    // reference to last bullet that hit this piece
    BBBullet *lastBulletHit;
    // reference to a BBExplosionManager
    BBExplosionManager *explosionManager;
    // sound when boss piece is hit by bullet
    CDSoundSource *hitSound;
    // particles for when boss piece is hit by bullet
	NSString *particles;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BBExplosionManager *explosionManager;

- (id) initWithDictionary:(NSDictionary *)dictionary;
// setters
- (void) setCollisionShape:(NSString*)newShape;
// actions
- (void) hitByBullet:(BBBullet*)bullet withContact:(GB2Contact*)contact;

@end
