//
//  ParallaxManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/4/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "ParallaxManager.h"


@implementation ParallaxManager

- (id) init {
	
	if((self = [super init])) {
		
		nodes = [NSMutableArray new];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) loadWithFile:(NSString*)file {
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

- (void) resetWithFile:(NSString*)file {
    for(ParallaxNode *p in nodes) {
        [self removeChild:p cleanup:YES];
    }
	[nodes removeAllObjects];
    [self loadWithFile:file];
}

- (void) update:(CGPoint)changeInPos {
	for(ParallaxNode *p in nodes) {
		[p update:changeInPos];
	}
}

@end
