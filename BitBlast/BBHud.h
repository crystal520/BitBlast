//
//  BBHud.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/2/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SettingsManager.h"
#import "CCButton.h"
#import "SimpleAudioEngine.h"

@interface BBHud : CCNode {
    CCLabelBMFont *score;
	// array of hearts keeping track of health
	NSMutableArray *hearts;
}

- (void) update:(float)delta;

@end
