//
//  Globals.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/3/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
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
    // number of keys needed to summon a miniboss
    int numKeysForMiniboss;
    // number of triforce pieces needed to summon the final boss
    int numPiecesForFinalBoss;
    // whether we're in the end boss sequence or not
    BOOL endBossSequence;
    // whether we're in the intro boss sequence or not
    BOOL introBossSequence;
    // whether or not the tutorial is active
    BOOL tutorial;
    // current state of the tutorial
    TutorialState tutorialState;
    // whether the tutorial state can change
    BOOL tutorialStateCanChange;
    // the number of dropships a player can kill before forcing a miniboss key to appear
    int numDropshipsForceKey;
    // current level the player has reached
    int level;
}

@property (nonatomic, assign) CGPoint playerPosition, playerVelocity, cameraOffset;
@property (nonatomic, assign) int playerStartingHealth, numKeysForMiniboss, numPiecesForFinalBoss, numDropshipsForceKey, level;
@property (nonatomic, assign) ReasonForDeath playerReasonForDeath;
@property (nonatomic, assign) GameState gameState;
@property (nonatomic, assign) TutorialState tutorialState;
@property (nonatomic, assign) BOOL endBossSequence, introBossSequence, tutorial, tutorialStateCanChange;

+ (Globals*) sharedSingleton;
+ (UIViewController*) getAppViewController;

@end
