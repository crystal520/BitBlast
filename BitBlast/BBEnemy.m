//
//  BBEnemy.m
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBEnemy.h"


@implementation BBEnemy

@synthesize recycle, enabled, tileOffset;

- (id) init {
	if((self = [super init])) {
		recycle = YES;
		self.visible = NO;
	}
	
	return self;
}

- (void) dealloc {
	[type release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) loadFromFile:(NSString *)filename {
	// perform reset first to release any variables
	[self reset];
	[super loadFromFile:filename];
	// load extra variables
	tileOffset = [[dictionary objectForKey:@"tileCenterOffset"] floatValue] * [ResolutionManager sharedSingleton].inversePositionScale;
	type = [[dictionary objectForKey:@"type"] retain];
	velocity = ccp([[[dictionary objectForKey:@"speed"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"speed"] objectForKey:@"y"] floatValue]);
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(newEnabled && !enabled) {
		//velocity = ccp(-100, 0);
	}
	else if(!newEnabled && enabled) {
		recycle = YES;
		self.visible = NO;
		[self removeChild:spriteBatch cleanup:YES];
		[self.parent removeChild:self cleanup:YES];
	}
	enabled = newEnabled;
}

#pragma mark -
#pragma mark getters
- (BOOL) getCollidesWithObject:(BBGameObject*)object {
	// convert object's position into this game object's space
	CGPoint objectPos = [object convertToWorldSpace:object.position];
	CGPoint thisPos = [self convertToWorldSpace:dummyPosition];
	// check for collision
	return CGRectIntersectsRect(CGRectMake(thisPos.x, thisPos.y, sprite.contentSize.width, sprite.contentSize.height), CGRectMake(objectPos.x, objectPos.y, object.sprite.contentSize.width, object.sprite.contentSize.height));
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// see if enemy is on screen
	CGPoint enemyScreenPosition = [self convertToWorldSpace:CGPointZero];
	if(enemyScreenPosition.x - self.sprite.contentSize.width * 0.5 * [ResolutionManager sharedSingleton].imageScale < [CCDirector sharedDirector].winSize.width && !enabled) {
		[self setEnabled:YES];
	}
	else if(enemyScreenPosition.x + self.sprite.contentSize.width * 0.5 * [ResolutionManager sharedSingleton].imageScale < 0 && enabled) {
		[self setEnabled:NO];
	}
	
	// only update if this enemy is enabled
	if(enabled) {
		// apply velocity to position
		dummyPosition = ccp(dummyPosition.x + (velocity.x * delta), dummyPosition.y + (velocity.y * delta));
	}
	
	self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
}

#pragma mark -
#pragma mark actions
- (void) reset {
	if(type) {
		[type release];
	}
}
   
- (void) resetWithPosition:(CGPoint)newPosition withType:(NSString *)enemyType {
	// reset the enemy with new parameters
	[self loadFromFile:enemyType];
	[self loadAnimations];
	dummyPosition = ccpAdd(newPosition, ccp(0, tileOffset));
	recycle = NO;
	self.visible = YES;
	[self addChild:spriteBatch];
	[self repeatAnimation:@"walk"];
	self.sprite.anchorPoint = ccp(0.5, 0);
}

@end
