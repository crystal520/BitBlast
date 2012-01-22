//
//  BBGlider.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/21/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBGlider.h"


@implementation BBGlider

- (NSString*) identifier {
	return @"glider";
}

- (void) jump:(NSNotification*)n {
	// if the player isn't jumping, then the player is trying to glide
	if(![self playerFromNotification:n].jumping && glideCount == 0) {
		[self setEnabled:YES withNotification:n];
	}
	else {
		glideCount = 0;
	}
}

- (void) endJumpWithTouch:(NSNotification*)n {
	[self setEnabled:NO withNotification:n];
}

- (void) endJumpWithoutTouch:(NSNotification*)n {
	if(glideCount == 0) {
		[self setEnabled:YES withNotification:n];
	}
}

- (void) collidePlatform:(NSNotification*)n {
	[self setEnabled:NO withNotification:n];
}

- (void) setEnabled:(BOOL)newEnabled withNotification:(NSNotification*)n {
	if(enabled && !newEnabled) {
		[self playerFromNotification:n].maxVelocity = ccp([self playerFromNotification:n].maxVelocity.x, oldMaxVelocity);
	}
	else if(!enabled && newEnabled) {
		glideCount++;
		oldMaxVelocity = [self playerFromNotification:n].maxVelocity.y;
		[self playerFromNotification:n].maxVelocity = ccp([self playerFromNotification:n].maxVelocity.x, 150);
	}
	enabled = newEnabled;
}

@end
