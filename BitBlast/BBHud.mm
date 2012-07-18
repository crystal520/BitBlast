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
		score.position = ccp(winSize.width * 0.98, winSize.height);
		score.color = ccc3(178, 34, 34);
		[self addChild:score];
		
		// create coins label
		coins = [[CCLabelBMFont alloc] initWithString:@"$0" fntFile:@"gamefont.fnt"];
		coins.anchorPoint = ccp(1, 1);
		coins.scale = 0.7;
		coins.position = ccp(winSize.width * 0.98, winSize.height * 0.9);
		coins.color = ccc3(255, 215, 0);
		[self addChild:coins];
		
		// create hearts based on player's starting health
		hearts = [NSMutableArray new];
		for(int i=0;i<[Globals sharedSingleton].playerStartingHealth;i++) {
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"heart.png"];
			sprite.position = ccp(winSize.width * 0.05 + i * (sprite.contentSize.width + 10), winSize.height * 0.95);
			[sprite setVisible:(i < [Globals sharedSingleton].playerStartingHealth)];
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
	[coins release];
	[score release];
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
	[coins setString:[NSString stringWithFormat:@"$%i", [[SettingsManager sharedSingleton] getInt:@"currentCoins"]]];
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
