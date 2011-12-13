//
//  BBGameLayer.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBPlayer.h"

@interface BBGameLayer : CCLayer {
    BBPlayer *player;
}

// returns a CCScene that contains the BBGameLayer as the only child
+ (CCScene *) scene;

@end
