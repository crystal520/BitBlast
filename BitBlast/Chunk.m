//
//  Chunk.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "Chunk.h"


@implementation Chunk

- (id) initWithFile:(NSString*)chunkName {
	
	if((self = [super init])) {
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:chunkName];
		
		[self addChild:map z:0];
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
}

@end
