//
//  BBEquipment.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/18/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBPlayer.h"

@interface BBEquipment : NSObject {
    
}

// unique string to identify the equipment
- (NSString*) identifier;
// called at the end of the player's update function
- (void) update:(NSNotification*)n;
// player has started a new session. great place to modify starting variables, such as max health, initial speed, etc
- (void) restart:(NSNotification*)n;
// player has died due to the given reason
- (void) die:(NSNotification*)n;
// player has collected a coin
- (void) collectCoin:(NSNotification*)n;
// player has reached the peak of their jump
- (void) jumpApex:(NSNotification*)n;
// player has taken damage due to the given reason
- (void) damage:(NSNotification*)n;
// player has collided with a platform
- (void) collidePlatform:(NSNotification*)n;

@end
