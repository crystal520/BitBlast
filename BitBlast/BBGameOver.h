//
//  BBGameOver.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/3/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNodeColorBackground.h"
#import "CCLabelButton.h"
#import "SettingsManager.h"

@interface BBGameOver : CCNodeColorBackground {
	CCLabelBMFont *distanceLabel, *killLabel, *multiplierLabel, *scoreLabel;
}

- (void) updateFinalScore;

@end
