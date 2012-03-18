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

typedef enum {
	kStateMainMenu,
	kStateGameOver,
	kStateGame,
	kStateShop,
	kStateConfirmBuy,
	kStateLeaderboards
} GameState;

//#define DEBUG_TEXTURES

@interface BBGameLayer : CCLayer <iCadeEventDelegate> {
	
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
	// screens
	BBHud *hud;
	BBGameOver *gameOver;
	BBMainMenu *mainMenu;
	BBShop *shop;
	BBConfirmBuy *confirmBuy;
	BBLeaderboards *leaderboards;
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
// setters
- (void) setBackgroundColorWithFile:(NSString*)file;
// update
- (void) updateCamera;

@end
