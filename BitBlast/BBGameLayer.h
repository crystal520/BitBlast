//
//  BBGameLayer.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBPlayer.h"
#import "ChunkManager.h"
#import "CCFollowOffset.h"
#import "BBHud.h"
#import "BBGameOver.h"
#import "ParallaxManager.h"
#import "BulletManager.h"
#import "BBMainMenu.h"
#import "BBShop.h"
#import "BBConfirmBuy.h"
#import "BBEnemyManager.h"
#import "BBDropshipManager.h"
#import "iCadeReaderView.h"
#import "BBCoinManager.h"
#import "GameCenter.h"
#import "SimpleAudioEngine.h"
#import "BBPause.h"
#import "BBLogic.h"
#import "BBChopper.h"
#import "BBMovingCoinManager.h"
#import "BBDialogQueue.h"
#import "Chartboost.h"
#import "BBInputController.h"
#import "GB2DebugDrawLayer.h"
#import "BBMinibossManager.h"
#import "BBBossManager.h"
#import "Debug.h"
#import "BBGameWin.h"

@interface BBGameLayer : CCLayer <iCadeEventDelegate, ChartboostDelegate, BBInputControllerDelegate> {
	ParallaxManager *parallax;
    BBPlayer *player;
	CCNode *scrollingNode;
	CGPoint cameraOffset, cameraBounds;
	GameState state, prevState;
	// colored background sprite
	CCSprite *background;
	// iCade support view
	iCadeReaderView *iCadeView;
	// chopper for intro
	BBChopper *chopper;
	// node that the camera follows
	CCNode *followNode;
    BBInputController *inputController;
    // whether or not the game is paused
    BOOL paused;
}

// returns a CCScene that contains the BBGameLayer as the only child
+ (CCScene *) scene;

// setup
- (void) setupICade;
- (void) createBackground;
- (void) loadImages;
- (void) loadAnimations;
- (void) loadCameraVariables;
- (void) reset;
- (void) resetSessionStats;
// actions
- (void) playIntro;
- (void) resetLevel:(NSString*)level;
- (void) killChopper;
- (void) finishGame;
- (void) clearMenuWithTag:(SpriteTag)tag;
- (void) pause;
- (void) resume;
- (void) shakeScreen;
- (void) freeze;
// setters
- (void) setBackgroundColorWithFile:(NSString*)file;
- (void) setState:(GameState)newState;
// update
- (void) updateCamera;

@end
