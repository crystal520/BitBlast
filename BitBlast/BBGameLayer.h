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

typedef enum {
	kStateMainMenu,
	kStateGameOver,
	kStateGame,
	kStateShop
} GameState;

@interface BBGameLayer : CCLayer {
	
	ParallaxManager *parallax;
    BBPlayer *player;
	CCNode *scrollingNode;
	CGPoint cameraOffset, cameraBounds;
	GameState state;
	
	// screens
	BBHud *hud;
	BBGameOver *gameOver;
	BBMainMenu *mainMenu;
	BBShop *shop;
}

// returns a CCScene that contains the BBGameLayer as the only child
+ (CCScene *) scene;

- (void) loadCameraVariables;
- (void) reset;

- (void) updateCamera;

@end
