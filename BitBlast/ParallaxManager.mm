//
//  ParallaxManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/4/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "ParallaxManager.h"


@implementation ParallaxManager

- (id) initWithFile:(NSString *)file {
	
	if((self = [super init])) {
		
		nodes = [NSMutableArray new];
		
		// grab dictionary from file and load in nodes using this info
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:@"plist"]];
		
		NSArray *parallaxNodes = [dict objectForKey:@"parallax"];
		for(NSDictionary *d in parallaxNodes) {
			ParallaxNode *p = [[ParallaxNode alloc] initWithDictionary:d];
			[self addChild:p];
			[nodes addObject:p];
			[p release];
		}
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) reset {
	for(ParallaxNode *p in nodes) {
		[p reset];
	}
}

- (void) update:(float)changeInPos {
	for(ParallaxNode *p in nodes) {
		[p update:changeInPos];
	}
}

@end
