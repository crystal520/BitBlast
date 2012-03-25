//
//  BBDropship.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/2/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBDropship.h"


@implementation BBDropship

@synthesize enabled, alive, level;

- (id) init {
	if((self = [super init])) {
		enemyTypes = [NSMutableArray new];
		[self setEnabled:NO];
		alive = YES;
		needsPlatformCollisions = NO;
		level = CHUNK_LEVEL_UNKNOWN;
	}
	return self;
}

- (void) dealloc {
	[enemyTypes release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) loadFromFile:(NSString *)filename {
	[super loadFromFile:filename];
	[self loadAnimations];
	
	// set values from dictionary
	spawnRate = [[dictionary objectForKey:@"spawnRate"] floatValue];
	spawnTimer = 0;
	health = [[dictionary objectForKey:@"health"] intValue];
	[enemyTypes setArray:[dictionary objectForKey:@"enemyTypes"]];
	[self addChild:spriteBatch];
	[self repeatAnimation:@"walk"];
	// TODO: turn this scale off once we get a different image for these
	sprite.scaleX = -1;
	boundingBox.origin.x *= -1;
	
	// reset variables
	rotation_ = 0;
	gravity = ccp(0, 0);
	velocity = ccp(0, 0);
	
	// use nearest so it will scale better
	ccTexParams params = {GL_NEAREST,GL_NEAREST,GL_REPEAT,GL_REPEAT};
	[sprite.texture setTexParameters:&params];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	// only update if enabled
	if(enabled) {
		[super update:delta];
		// get velocity from player
		if(alive) {
			velocity = ccp([Globals sharedSingleton].playerVelocity.x, 0);
			// spawn enemies
			spawnTimer += delta;
			while(spawnTimer >= spawnRate) {
				[self spawnEnemy];
				spawnTimer -= spawnRate;
			}
		}
		
		// if dropship is dead and goes off screen, actually kill it
		if(!alive) {
			if(dummyPosition.y + sprite.contentSize.height * 0.5 < 0) {
				[self setEnabled:NO];
				[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventDropshipDestroyed object:nil]];
			}
		}
	}
}

#pragma mark -
#pragma mark getters
- (NSString*) getRandomEnemy {
	int ran = CCRANDOM_MIN_MAX(0, [enemyTypes count]);
	return [enemyTypes objectAtIndex:ran];
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
	if(enabled && !newEnabled) {
		self.visible = NO;
		alive = NO;
		[self removeChild:spriteBatch cleanup:YES];
		level = CHUNK_LEVEL_UNKNOWN;
	}
	else if(!enabled && newEnabled) {
		self.visible = YES;
		alive = YES;
	}
	enabled = newEnabled;
}

#pragma mark -
#pragma mark actions
- (void) spawnEnemy {
	if(alive && enabled) {
		// get recycled enemy
		BBEnemy *newEnemy = [[EnemyManager sharedSingleton] getRecycledEnemy];
		// reset with position of dropship and random enemy type
		[newEnemy resetWithPosition:dummyPosition withType:[self getRandomEnemy]];
	}
}

- (void) hitByBullet:(BBBullet*)bullet {
	health -= bullet.damage;
	
	// TODO: play hit animation or something cooler. possibly explosion particles
	CCActionInterval *action = [CCSequence actions:[CCTintTo actionWithDuration:0.05 red:255 green:0 blue:0], [CCTintTo actionWithDuration:0.05 red:255 green:255 blue:255], nil];
	[self.sprite runAction:action];
	
	// if the dropship died, turn off all movement and play death animation
	if(health <= 0) {
		[self die];
	}
}

- (void) die {
	[[SimpleAudioEngine sharedEngine] playEffect:@"dropshipexplosion.wav"];
	// increment dropships killed
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"totalDropships"];
	[[SettingsManager sharedSingleton] incrementInteger:1 keyString:@"currentDropships"];
	alive = NO;
	gravity = ccp(2, 5);
	// turn towards the ground and crash!
	[self runAction:[CCRotateTo actionWithDuration:1 angle:-15]];
}

- (void) resetWithPosition:(CGPoint)newPosition type:(NSString*)type level:(ChunkLevel)newLevel {
	[self loadFromFile:type];
	
	// determine offset based on level type
	CGPoint levelOffset = ccp(0, 0);
	level = newLevel;
	if(level == CHUNK_LEVEL_BOTTOM) {
		levelOffset = ccp([[[dictionary objectForKey:@"offsetBottom"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"offsetBottom"] objectForKey:@"y"] floatValue]);
	}
	else if(level == CHUNK_LEVEL_TOP) {
		levelOffset = ccp([[[dictionary objectForKey:@"offsetTop"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"offsetTop"] objectForKey:@"y"] floatValue]);
	}
	else {
		levelOffset = ccp([[[dictionary objectForKey:@"offsetMiddle"] objectForKey:@"x"] floatValue], [[[dictionary objectForKey:@"offsetMiddle"] objectForKey:@"y"] floatValue]);
	}
	
	dummyPosition = ccpAdd(newPosition, levelOffset);
	[self setEnabled:YES];
}

@end
