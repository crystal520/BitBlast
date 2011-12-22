//
//  CCFollowOffset.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/16/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "CCFollowOffset.h"


@implementation CCFollowOffset

+ (CCFollowOffset*) actionWithTarget:(CCNode*)followedNode withOffset:(CGPoint)offset {
	
	return [[[self alloc] initWithTarget:followedNode withOffset:offset] autorelease];
}

- (CCFollowOffset*) initWithTarget:(CCNode*)followedNode withOffset:(CGPoint)offset {
	
	if( (self=[super init]) ) {
	
		followedNode_ = [followedNode retain];
		boundarySet = FALSE;
		boundaryFullyCovered = FALSE;
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		fullScreenSize = CGPointMake(s.width, s.height);
		halfScreenSize = CGPointMake(s.width/2 + offset.x, (s.height/2) + offset.y);
	}
	
	return self;
}

@end
