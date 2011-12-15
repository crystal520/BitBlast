//
//  ChunkLoader.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/14/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "ChunkLoader.h"


@implementation ChunkLoader

- (id) init {
	
	if((self = [super init])) {
		
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
}

- (void) loadChunksForLevel:(NSString*)levelName {
	
	// grab plist from bundle
	NSDictionary *levelPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"]];
	
	// make sure it exists
	if(levelPlist) {
		// grab first chunk
		NSString *firstChunk = [levelPlist objectForKey:@"firstChunk"];
		
		// grab array of chunks
		//NSArray *chunks = [levelPlist objectForKey:@"chunks"];
		
		// grab override chunk
		//NSString *overrideChunk = [levelPlist objectForKey:@"overrideChunk"];
		
		[[ChunkManager sharedSingleton] addChunk:firstChunk];
	}
	else {
		NSLog(@"ERROR: Failed to load chunks for level \"%@\" because it doesn't exist", levelName);
	}
}

@end
