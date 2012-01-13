//
//  BBHud.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/2/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ScoreManager.h"

@interface BBHud : CCNode {
    CCLabelBMFont *score;
}

- (void) update:(float)delta;

@end
