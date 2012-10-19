//
//  CCFollowOffset.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/16/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCFollowOffset : CCFollow {
    
}

+ (CCFollowOffset*) actionWithTarget:(CCNode*)followedNode withOffset:(CGPoint)offset;
- (CCFollowOffset*) initWithTarget:(CCNode*)followedNode withOffset:(CGPoint)offset;

@end
