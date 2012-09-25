//
//  BBBoss.m
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBBoss.h"

@implementation BBBoss

@synthesize enabled, explosionManager;

- (id) initWithFile:(NSString *)filename {
    if((self = [super initWithFile:filename])) {
        // make array for holding pieces
        pieces = [NSMutableArray new];
        // create boss pieces and add to boss
        NSArray *bossPieces = [dictionary objectForKey:@"pieces"];
        for(NSDictionary *d in bossPieces) {
            BBBossPiece *piece = [[BBBossPiece alloc] initWithDictionary:d];
            [self addChild:piece];
            [pieces addObject:piece];
            [piece release];
        }
        // disable to start
        [self setEnabled:NO];
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
    [pieces release];
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
    // loop through boss pieces and call setEnabled on them
    for(BBBossPiece *p in pieces) {
        [p setEnabled:newEnabled];
    }
    
    self.visible = newEnabled;
	if(enabled && !newEnabled) {
		alive = NO;
	}
	else if(!enabled && newEnabled) {
		alive = YES;
	}
	enabled = newEnabled;
}

- (void) setExplosionManager:(BBExplosionManager *)newExplosionManager {
    explosionManager = newExplosionManager;
    for(BBBossPiece *p in pieces) {
        p.explosionManager = explosionManager;
    }
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
    // get right side position in world coordinates
    float right = [Globals sharedSingleton].playerPosition.x - [Globals sharedSingleton].cameraOffset.x + [ResolutionManager sharedSingleton].size.width;
    float bottom = MAX([Globals sharedSingleton].playerPosition.y - 311, 0);
    dummyPosition = ccp(right - 503, bottom);
    [super update:delta];
}

@end
