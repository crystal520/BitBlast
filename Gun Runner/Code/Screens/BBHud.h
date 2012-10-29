//
//  BBHud.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/2/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCButton.h"
#import "SimpleAudioEngine.h"
#import "ChunkManager.h"
#import "BBDropshipManager.h"

@interface BBHud : CCNode {
    CCLabelBMFont *score;
	// array of hearts keeping track of health
	NSMutableArray *hearts;
	// pause button
	CCButton *pause;
	// keeps track of player coins during game
	CCLabelBMFont *coins;
    // array of keys
    NSMutableArray *keys;
    // array of triforce pieces that the player has
    NSMutableArray *triforce;
    // flashing label for tutorial
    CCLabelBMFont *tutorial;
    // tutorial state that the tutorial string was triggered for
    TutorialState tutorialState;
}

// actions
- (void) flash;
- (void) showTutorialString:(NSString*)tutorialString;
// update
- (void) update:(float)delta;

@end
