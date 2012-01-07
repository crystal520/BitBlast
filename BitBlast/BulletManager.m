//
//  BulletManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/5/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BulletManager.h"


@implementation BulletManager

+ (BulletManager*) sharedSingleton {
	
	static BulletManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BulletManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	
	if((self = [super init])) {
		
		bullets = [NSMutableArray new];
		for(int i=0;i<MAX_BULLETS;i++) {
			BBBullet *bullet = [BBBullet new];
			[bullets addObject:bullet];
			[bullet release];
		}
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// loop through bullets and update ones that aren't flagged for recycle
	for(BBBullet *b in bullets) {
		if(b.recycle == NO) {
			[b update:delta];
		}
	}
}

#pragma mark -
#pragma mark accessors
- (BBBullet*) getRecycledBullet {
	for(BBBullet *b in bullets) {
		if(b.recycle == YES) {
			return b;
		}
	}
	
	return NULL;
}

#pragma mark -
#pragma mark mutators
- (void) setNode:(CCNode*)newNode {
	if(node != newNode) {
		node = newNode;
		
		for(BBBullet *b in bullets) {
			[node addChild:b];
		}
	}
}

@end
