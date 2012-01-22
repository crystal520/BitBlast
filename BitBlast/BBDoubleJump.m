//
//  BBDoubleJump.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/18/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBDoubleJump.h"

@implementation BBDoubleJump

- (NSString*) identifier {
	return @"doublejump";
}

- (void) update:(NSNotification*)n {
	if(jumpCount == 1) {
		// pretend player is colliding with platform so they can jump again
		[self playerFromNotification:n].touchingPlatform = YES;
	}
}

- (void) endJumpWithTouch:(NSNotification*)n {
	if([self playerFromNotification:n].jumping) {
		jumpCount++;
	}
}

- (void) endJumpWithoutTouch:(NSNotification*)n {
	jumpCount++;
}

- (void) collidePlatform:(NSNotification*)n {
	jumpCount = 0;
}

@end
