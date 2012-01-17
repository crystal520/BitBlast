//
//  BBLeaderboardEntry.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BBLeaderboardEntry : SWTableViewCell {
    
}

- (id) initWithDictionary:(NSDictionary*)dict index:(int)idx;

@end
