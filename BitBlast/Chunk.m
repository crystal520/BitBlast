//
//  Chunk.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "Chunk.h"


@implementation Chunk

@synthesize width, height, playerZ;
@synthesize endPosition, startPosition, lowestPosition;

- (id) initWithFile:(NSString*)chunkName withOffset:(CGPoint)offset {
	
	if((self = [super initWithTMXFile:chunkName])) {
		
		self.position = offset;
		
		// keep track of player's z value
		if([self layerNamed:@"Foreground"]) {
			playerZ = [[self layerNamed:@"Foreground"] zOrder]-1;
		}
		else if([self layerNamed:@"Background"]) {
			playerZ = [[self layerNamed:@"Background"] zOrder]+1;
		}
		else {
			playerZ = 1;
		}
		
		// keep track of width and height
		width = self.mapSize.width * self.tileSize.width;
		height = self.mapSize.height * self.tileSize.height;
		
		// generate end position based on width and offset
		endPosition = offset.x + width;
		// keep track of startPosition for removing chunk
		startPosition = offset.x;
		// keep track of lowestPosition for killing player
		lowestPosition = offset.y;
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
}

@end
