//
//  BBGameLayer.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBPhysicsWorld.h"
#import "BBPlayer.h"
#import "ChunkManager.h"
#import "CCFollowOffset.h"

@interface BBGameLayer : CCLayer {
	
    BBPlayer *player;
	CCNode *scrollingNode;
}

// returns a CCScene that contains the BBGameLayer as the only child
+ (CCScene *) scene;

@end
