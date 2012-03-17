//
//  BBLeaderboards.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNodeColorBackground.h"
#import "BBLeaderboardEntry.h"
#import "CCLabelButton.h"

@interface BBLeaderboards : CCNodeColorBackground {
    NSArray *scores;
}

@end
