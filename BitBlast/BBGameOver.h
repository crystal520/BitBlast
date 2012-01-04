//
//  BBGameOver.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/3/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ScoreManager.h"

@interface BBGameOver : CCNode {
    CCLabelTTF *gameOverLabel, *finalScoreLabel;
}

- (void) updateFinalScore;

@end
