//
//  BBGameLayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBGameLayer.h"

@implementation BBGameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BBGameLayer *layer = [BBGameLayer node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

- (id) init {
	if((self = [super init])) {
		
		[self setScale:[ResolutionManager sharedSingleton].imageScale];
		[self setPosition:[ResolutionManager sharedSingleton].position];
		[self loadImages];
		[self loadCameraVariables];
		
		// create parallax scrolling background
		parallax = [[ParallaxManager alloc] initWithFile:@"jungleLevel"];
		[self addChild:parallax z:1];
		
		// for objects that need to scroll
		scrollingNode = [[CCNode alloc] init];
		[self addChild:scrollingNode z:2];
		
		// listen for touches
		self.isTouchEnabled = YES;
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
		
		// load level
		[scrollingNode addChild:[ChunkManager sharedSingleton]];
		[[ChunkManager sharedSingleton] loadChunksForLevel:@"jungleLevel"];
		
		// create background sprite
		[self createBackground];
		[self setBackgroundColorWithFile:@"jungleLevel"];
		
		// create player
		player = [[BBPlayer alloc] init];
		
		// add BulletManager to the scrolling node
		[[BulletManager sharedSingleton] setNode:scrollingNode];
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartGame) name:kGameRestartNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGame) name:kNavGameNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoShop) name:kNavShopNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMain) name:kNavMainNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoConfirmBuy:) name:kNavShopConfirmNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyItem:) name:kNavBuyItemNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelBuyItem) name:kNavCancelBuyItemNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoLeaderboards) name:kNavLeaderboardsNotification object:nil];
		
		[[BBEquipmentManager sharedSingleton] equip:@"glider"];
		[[BBEquipmentManager sharedSingleton] equip:@"doublejump"];
		
		// set initial state
		state = kStateMainMenu;
		
		// HUD overlay
		hud = [[BBHud alloc] init];
		// game over screen
		gameOver = [[BBGameOver alloc] init];
		// shop
		shop = [[BBShop alloc] init];
		// confirm buy screen
		confirmBuy = [[BBConfirmBuy alloc] init];
		// main menu screen
		mainMenu = [[BBMainMenu alloc] init];
		// leaderboards
		leaderboards = [[BBLeaderboards alloc] init];
		[self addChild:mainMenu z:4];
		
#ifdef DEBUG
		debugButton = [CCSprite spriteWithFile:@"white.png"];
		debugButton.color = ccc3(0, 0, 0);
		[debugButton setTextureRect:CGRectMake(0, 0, 50, 50)];
		debugButton.position = ccp(25, [ResolutionManager sharedSingleton].size.height - 25);
		[self addChild:debugButton z:10];
#endif
	}
	
	return self;
}

- (void) dealloc {
	
	[self removeAllChildrenWithCleanup:YES];
	[scrollingNode release];
	[hud release];
	[player release];
	[parallax release];
	[gameOver release];
	[shop release];
	[confirmBuy release];
	[mainMenu release];
	[leaderboards release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) loadImages {
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"uiatlas.plist"];
}

- (void) loadCameraVariables {
	
	// get dictionary from plist
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cameraProperties" ofType:@"plist"]];
	
	cameraOffset = ccp([[plist objectForKey:@"offsetX"] floatValue], [[plist objectForKey:@"offsetY"] floatValue]);
	cameraBounds = ccp([[plist objectForKey:@"minimumY"] floatValue], [[plist objectForKey:@"maximumY"] floatValue]);
}

- (void) reset {
	[self addChild:hud];
	state = kStateGame;
	scrollingNode.position = ccp(0, [ResolutionManager sharedSingleton].size.height * 0.5);
	[parallax reset];
	[[ScoreManager sharedSingleton] reset];
	[[ChunkManager sharedSingleton] resetWithLevel:@"jungleLevel"];
	[player reset];
	[self updateCamera];
	[self scheduleUpdate];
}

- (void) createBackground {
	// create colorable background
	background = [CCSprite spriteWithFile:@"white.png" rect:CGRectMake(0, 0, [ResolutionManager sharedSingleton].size.width, [ResolutionManager sharedSingleton].size.height)];
	background.anchorPoint = ccp(0, 0);
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[background.texture setTexParameters:&params];
	[self addChild:background z:0];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	
	// update game
	if(state == kStateGame) {
		[[ChunkManager sharedSingleton] update:delta];
		[player update:delta];
		[[BulletManager sharedSingleton] update:delta];
		[[EnemyManager sharedSingleton] update:delta];
		[self updateCamera];
		[hud update:delta];
	}
}

- (void) updateCamera {
	
	// keep track of node's previous position
	float prevPos = scrollingNode.position.x;
	// convert player's y position to screen space
	CGPoint currentPlayerScreenPosition = [player convertToWorldSpace:CGPointZero];
	currentPlayerScreenPosition.y = [CCDirector sharedDirector].winSize.height - (currentPlayerScreenPosition.y + player.sprite.contentSize.height);
	
	float yOffset = 0;
	// check to see if player is too close to the top of the screen
	if(currentPlayerScreenPosition.y < cameraBounds.x) {
		yOffset = cameraBounds.x - currentPlayerScreenPosition.y;
	}
	// check to see if player is too close to the bottom of the screen
	else if(currentPlayerScreenPosition.y > cameraBounds.y) {
		yOffset = cameraBounds.y - currentPlayerScreenPosition.y;
	}
	
	CGPoint newPos = ccp(-1 * player.position.x + cameraOffset.x, scrollingNode.position.y + cameraOffset.y - yOffset);
    
    // make sure newPos's y coordinate is not less than the current chunk's lowest point
    if(newPos.y > [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
		newPos.y = [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition;
	}
	[scrollingNode setPosition:newPos];
	
	[parallax update:scrollingNode.position.x - prevPos];
}

#pragma mark -
#pragma mark setters
- (void) setBackgroundColorWithFile:(NSString*)file {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:@"plist"]];
	// get color from dictionary
	NSArray *colorArray = [[dict objectForKey:@"backgroundColor"] componentsSeparatedByString:@", "];
	// make color
	ccColor3B bgColor = ccc3([[colorArray objectAtIndex:0] floatValue], [[colorArray objectAtIndex:1] floatValue], [[colorArray objectAtIndex:2] floatValue]);
	// set color
	background.color = bgColor;
}

#pragma mark -
#pragma mark getters

#pragma mark -
#pragma mark touch input
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	// get coordinates of touch
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = ccp(touchPoint.x, winSize.height - touchPoint.y);
	
	// right side of screen is jump
	if(touchPoint.x > winSize.width * 0.5f) {
		[player jump];
	}
	// left side controls shooting
	else {
		[player shoot:touchPoint];
	}
	
	return true;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	// get coordinates of touch
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = ccp(touchPoint.x, winSize.height - touchPoint.y);
	
	// left side of screen controls shooting
	if(touchPoint.x <= winSize.width * 0.5f) {
		[player shoot:touchPoint];
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	// get coordinates of touch
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = ccp(touchPoint.x, winSize.height - touchPoint.y);
	
	// right side of screen is jump
	if(touchPoint.x > winSize.width * 0.5f) {
		[player endJump];
	}
	else {
		[player endShoot];
	}
	
#ifdef DEBUG
	if(CGRectContainsPoint([debugButton boundingBox], ccpMult(touchPoint, 1/[ResolutionManager sharedSingleton].imageScale))) {
		// print out all textures currently in memory
		[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	}
#endif
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
	
}

#pragma mark -
#pragma mark notifications
- (void) gameOver {
	[self removeChild:hud cleanup:YES];
	state = kStateGameOver;
	[self unscheduleUpdate];
	[gameOver updateFinalScore];
	[self addChild:gameOver];
}

- (void) startGame {
	[self removeChild:mainMenu cleanup:YES];
	[self reset];
}

- (void) restartGame {
	[self removeChild:gameOver cleanup:YES];
	[self reset];
}

- (void) gotoShop {
	if(state == kStateMainMenu) {
		[self removeChild:mainMenu cleanup:YES];
	}
	else if(state == kStateGameOver) {
		[self removeChild:gameOver cleanup:YES];
	}
	
	state = kStateShop;
	[self addChild:shop];
}

- (void) gotoMain {
	if(state == kStateShop) {
		[self removeChild:shop cleanup:YES];
	}
	else if(state == kStateLeaderboards) {
		[self removeChild:leaderboards cleanup:YES];
	}
	
	state = kStateMainMenu;
	[self addChild:mainMenu];
}

- (void) gotoLeaderboards {
	if(state == kStateMainMenu) {
		state = kStateLeaderboards;
		[self removeChild:mainMenu cleanup:YES];
		[self addChild:leaderboards];
	}
}

- (void) gotoConfirmBuy:(NSNotification*)n {
	if(state == kStateShop) {
		state = kStateConfirmBuy;
		[confirmBuy updateWithInfo:[n userInfo]];
		[self addChild:confirmBuy];
	}
}

- (void) buyItem:(NSNotification*)n {
	if(state == kStateConfirmBuy) {
		state = kStateShop;
		[self removeChild:confirmBuy cleanup:YES];
	}
}

- (void) cancelBuyItem {
	if(state == kStateConfirmBuy) {
		state = kStateShop;
		[self removeChild:confirmBuy cleanup:YES];
	}
}

@end
