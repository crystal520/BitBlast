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
// player has attempted to jump, maybe not successfully. called whenever the player taps the right half of the screen
- (void) jump:(NSNotification*)n;
// player has reached the peak of their jump by lifting their finger from the screen
- (void) endJumpWithTouch:(NSNotification*)n;
// player has reached the peak of their jump by reaching the maximum time their finger can be on the screen to get a long jump
- (void) endJumpWithoutTouch:(NSNotification*)n;
// player has taken damage due to the given reason
- (void) damage:(NSNotification*)n;
// player has collided with a platform
- (void) collidePlatform:(NSNotification*)n;

// convenience method to grab player from notification
- (BBPlayer*) playerFromNotification:(NSNotification*)n;

@end
