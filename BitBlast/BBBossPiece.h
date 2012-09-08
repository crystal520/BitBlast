//
//  BBBossPiece.h
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBGameObject.h"
#import "BBBullet.h"

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
    // reference to last bullet that hit this piece
    BBBullet *lastBulletHit;
}

- (id) initWithDictionary:(NSDictionary *)dictionary;

@end
