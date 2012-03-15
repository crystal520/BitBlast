//
//  Globals.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/3/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Globals : NSObject {
    // player's position
	CGPoint playerPosition;
	// player's velocity
	CGPoint playerVelocity;
	// camera offset (used to calculate when something is off screen to the left of the player)
	CGPoint cameraOffset;
}

@property (nonatomic, assign) CGPoint playerPosition, playerVelocity, cameraOffset;

+ (Globals*) sharedSingleton;

@end
