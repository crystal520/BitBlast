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

@interface BBGameLayer : CCLayer {
	
	ParallaxManager *parallax;
    BBPlayer *player;
	BBHud *hud;
	BBGameOver *gameOver;
	CCNode *scrollingNode;
	CGPoint cameraOffset, cameraBounds;
}

// returns a CCScene that contains the BBGameLayer as the only child
+ (CCScene *) scene;

- (void) loadCameraVariables;

- (void) updateCamera;

@end
