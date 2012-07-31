//
//  Globals.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/3/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Globals : NSObject {
    // player's position
	CGPoint playerPosition;
	// player's velocity
	CGPoint playerVelocity;
	// camera offset (used to calculate when something is off screen to the left of the player)
	CGPoint cameraOffset;
	// player's starting health
	int playerStartingHealth;
    // reason that player died
    ReasonForDeath playerReasonForDeath;
    // current game state
    GameState gameState;
    // number of dropships destroyed - for determining whether to spawn a miniboss or not
    int dropshipsDestroyedForMiniboss;
}

@property (nonatomic, assign) CGPoint playerPosition, playerVelocity, cameraOffset;
@property (nonatomic, assign) int playerStartingHealth, dropshipsDestroyedForMiniboss;
@property (nonatomic, assign) ReasonForDeath playerReasonForDeath;
@property (nonatomic, assign) GameState gameState;

+ (Globals*) sharedSingleton;

@end
