//
//  BBHud.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/2/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBHud.h"


@implementation BBHud

- (id) init {
	if((self = [super init])) {
		
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
		// create pause button
		pause = [CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pause.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pause.png"] target:self selector:@selector(pause)];
		[pause setSpriteBatchNode:uiSpriteBatch];
		pause.position = ccp(winSize.width - pause.contentSize.width * 0.5, pause.contentSize.height * 0.5);
		[self addChild:pause];
		
		// create score label
		score = [[CCLabelBMFont alloc] initWithString:@"0" fntFile:@"gamefont.fnt"];
		score.anchorPoint = ccp(1, 1);
		score.scale = 0.7;
		score.position = ccp(winSize.width, winSize.height);
		[self addChild:score];
		
		// create hearts based on player's starting health
		hearts = [NSMutableArray new];
		for(int i=0;i<3;i++) {
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"heart.png"];
			sprite.position = ccp(winSize.width * 0.05 + i * (sprite.contentSize.width + 10), winSize.height * 0.95);
			[hearts addObject:sprite];
			[uiSpriteBatch addChild:sprite];
		}
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healthUpdate:) name:kPlayerHealthNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameStart) name:kNavGameNotification object:nil];
	}
	
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[hearts release];
	[super dealloc];
}

- (void) pause {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavPauseNotification object:nil]];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	[score setString:[NSString stringWithFormat:@"%im", [[SettingsManager sharedSingleton] getInt:@"currentMeters"]]];
}

#pragma mark -
#pragma mark notifications
- (void) healthUpdate:(NSNotification*)n {
	int newHealth = [[[n userInfo] objectForKey:@"health"] intValue];
	// display number of hearts equal to new health
	for(int i=0,j=[hearts count];i<j;i++) {
		CCSprite *heart = [hearts objectAtIndex:i];
		[heart setVisible:(i < newHealth)];
	}
}

- (void) gameOver {
	[pause setEnabled:NO];
}

- (void) gameStart {
	[pause setEnabled:YES];
}

@end
