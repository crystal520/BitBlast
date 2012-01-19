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
		// grab info from notification
		BBPlayer *player = [n object];
		float delta = [[[n userInfo] objectForKey:@"delta"] floatValue];
		// pretend player is colliding with platform so they can jump again
		player.touchingPlatform = YES;
	}
}

- (void) jumpApex:(NSNotification*)n {
	jumpCount++;
}

- (void) collidePlatform:(NSNotification*)n {
	jumpCount = 0;
}

@end
