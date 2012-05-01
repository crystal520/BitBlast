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
#import "BBLeaderboards.h"
#import "BBEquipmentManager.h"
#import "EnemyManager.h"
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
#import "ChartBoost.h"

typedef enum {
	kStateUnknown,
	kStateMainMenu,
	kStateGameOver,
	kStateIntro,
	kStateGame,
	kStateShop,
	kStateConfirmBuy,
	kStateLeaderboards,
	kStatePause
} GameState;

typedef enum {
	TAG_MENU,
	TAG_HUD,
	TAG_POPUP
} SpriteTag;

//#define DEBUG_TEXTURES
//#define DEBUG_NO_SOUND
//#define DEBUG_NO_MUSIC

@interface BBGameLayer : CCLayer <iCadeEventDelegate, ChartBoostDelegate> {
	
#ifdef DEBUG_TEXTURES
	CCSprite *debugButton;
#endif
	
	ParallaxManager *parallax;
    BBPlayer *player;
	CCNode *scrollingNode;
	CGPoint cameraOffset, cameraBounds;
	GameState state;
	// colored background sprite
	CCSprite *background;
	// iCade support view
	iCadeReaderView *iCadeView;
	// chopper for intro
	BBChopper *chopper;
	// node that the camera follows
	CCNode *followNode;
}

// returns a CCScene that contains the BBGameLayer as the only child
+ (CCScene *) scene;

// setup
- (void) setupICade;
- (void) createBackground;
- (void) loadImages;
- (void) loadCameraVariables;
- (void) reset;
- (void) resetSessionStats;
// actions
- (void) playIntro;
- (void) killChopper;
- (void) finishGame;
- (void) clearMenuWithTag:(SpriteTag)tag;
// setters
- (void) setBackgroundColorWithFile:(NSString*)file;
- (void) setState:(GameState)newState;
// update
- (void) updateCamera;

@end
