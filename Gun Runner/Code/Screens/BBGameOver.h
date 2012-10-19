//
//  BBGameOver.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/3/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelButton.h"
#import "SimpleAudioEngine.h"
#import "BBPlayer.h"
#import "BBColorRectSprite.h"

@interface BBGameOver : CCNode {
	CCLabelBMFont *distanceLabel, *killLabel, *multiplierLabel, *scoreLabel;
}

- (void) updateFinalScore;
- (NSString*) getRandomDeathMessage;

@end
