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
		
#ifdef DEBUG_NO_SOUND
		[[SimpleAudioEngine sharedEngine] setMute:YES];
#endif
		
		// setup iCade controls
		[self setupICade];
		
		[self setScale:[ResolutionManager sharedSingleton].imageScale];
		[self setPosition:[ResolutionManager sharedSingleton].position];
		[self loadImages];
		[self loadCameraVariables];
		
		// create parallax scrolling background
		parallax = [[ParallaxManager alloc] initWithFile:@"jungleLevel"];
		[self addChild:parallax z:DEPTH_PARALLAX];
		
		// for objects that need to scroll
		scrollingNode = [[CCNode alloc] init];
		[self addChild:scrollingNode z:DEPTH_LEVEL];
		
		// load level
		[scrollingNode addChild:[ChunkManager sharedSingleton]];
		[[ChunkManager sharedSingleton] loadChunksForLevel:@"jungleLevel"];
		
		// add dropships to scrollingNode
		[scrollingNode addChild:[BBDropshipManager sharedSingleton]];
		// add enemies to scrollingNode
		[scrollingNode addChild:[EnemyManager sharedSingleton]];
		// add coins to scrollingNode
		[scrollingNode addChild:[BBCoinManager sharedSingleton]];
		
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
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoLeaderboards) name:kNavLeaderboardsNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoPause) name:kNavPauseNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeGame) name:kNavResumeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(introDone) name:kPlayerOutOfChopperNotification object:nil];
		
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
		// pause screen
		pause = [[BBPause alloc] init];
		// main menu screen
		mainMenu = [[BBMainMenu alloc] init];
		// leaderboards
		leaderboards = [[BBLeaderboards alloc] init];
		[self addChild:mainMenu z:DEPTH_MENU];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu.mp3" loop:YES];
		
#ifdef DEBUG_TEXTURES
		debugButton = [CCSprite spriteWithFile:@"white.png"];
		debugButton.color = ccc3(0, 0, 0);
		[debugButton setTextureRect:CGRectMake(0, 0, 50, 50)];
		debugButton.position = ccp(25, [ResolutionManager sharedSingleton].size.height - 25);
		[self addChild:debugButton z:DEPTH_DEBUG];
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
	[pause release];
	[super dealloc];
}

#pragma mark -
#pragma mark setup
- (void) setupICade {
	iCadeView = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
	[[[CCDirector sharedDirector] openGLView] addSubview:iCadeView];
	iCadeView.active = YES;
	iCadeView.delegate = self;
}

- (void) loadImages {
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"uiatlas.plist"];
}

- (void) loadCameraVariables {
	
	// get dictionary from plist
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cameraProperties" ofType:@"plist"]];
	
	cameraOffset = ccp([[plist objectForKey:@"offsetX"] floatValue], [[plist objectForKey:@"offsetY"] floatValue]);
	cameraBounds = ccp([[plist objectForKey:@"minimumY"] floatValue], [[plist objectForKey:@"maximumY"] floatValue]);
	[Globals sharedSingleton].cameraOffset = cameraOffset;
	cameraOffset = ccpMult(cameraOffset, [ResolutionManager sharedSingleton].positionScale);
}

- (void) reset {
	// reset session stats
	[self resetSessionStats];
	
	// listen for touches
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:YES];
	self.isTouchEnabled = YES;
	
	// add hud to screen
	[self addChild:hud z:DEPTH_MENU];
	[followNode stopAllActions];
	[scrollingNode removeChild:followNode cleanup:YES];
	followNode = player;
	[self updateCamera];
	
	// start up game logic
	[[BBLogic sharedSingleton] setEnabled:YES];
}

- (void) resetSessionStats {
	[[SettingsManager sharedSingleton] setInteger:0 keyString:@"currentEnemies"];
	[[SettingsManager sharedSingleton] setInteger:0 keyString:@"currentCoins"];
	[[SettingsManager sharedSingleton] setInteger:0 keyString:@"currentMeters"];
	[[SettingsManager sharedSingleton] setInteger:0 keyString:@"currentDropships"];
}

- (void) createBackground {
	// create colorable background
	background = [CCSprite spriteWithFile:@"white.png" rect:CGRectMake(0, 0, [ResolutionManager sharedSingleton].size.width, [ResolutionManager sharedSingleton].size.height)];
	background.anchorPoint = ccp(0, 0);
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[background.texture setTexParameters:&params];
	[self addChild:background z:DEPTH_BACKGROUND];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	
	// update game
	if(state == kStateGame) {
		[chopper update:delta];
		[[ChunkManager sharedSingleton] update:delta];
		[player update:delta];
		[[BulletManager sharedSingleton] update:delta];
		[[EnemyManager sharedSingleton] update:delta];
		[[BBDropshipManager sharedSingleton] update:delta];
		[[BBCoinManager sharedSingleton] update:delta];
		[self updateCamera];
		[hud update:delta];
	}
	else if(state == kStateIntro) {
		[chopper update:delta];
		[[ChunkManager sharedSingleton] update:delta];
		[player update:delta];
		[[BulletManager sharedSingleton] update:delta];
		[self updateCamera];
	}
}

- (void) updateCamera {
	
	// keep track of node's previous position
	float prevPos = scrollingNode.position.x;
	// convert player's y position to screen space
	CGPoint currentPlayerScreenPosition = [followNode convertToWorldSpace:CGPointZero];
	
	float yOffset = 0;
	// check to see if player is too close to the top of the screen
	if(currentPlayerScreenPosition.y < cameraBounds.x) {
		//yOffset = cameraBounds.x - currentPlayerScreenPosition.y;
		yOffset = currentPlayerScreenPosition.y - cameraBounds.x;
	}
	// check to see if player is too close to the bottom of the screen
	else if(currentPlayerScreenPosition.y > cameraBounds.y) {
		yOffset = currentPlayerScreenPosition.y - cameraBounds.y;
	}
	
	CGPoint newPos = ccp(-1 * followNode.position.x + cameraOffset.x, scrollingNode.position.y + cameraOffset.y - yOffset);
    
    // make sure newPos's y coordinate is not less than the current chunk's lowest point
    if(newPos.y > [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
		newPos.y = [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition;
	}
	[scrollingNode setPosition:newPos];
	
	[parallax update:scrollingNode.position.x - prevPos];
}

#pragma mark -
#pragma mark actions
- (void) playIntro {
	// create chopper for intro animation
	[self killChopper];
	chopper = [BBChopper new];
	[scrollingNode addChild:chopper z:-1];
	
	// reset level
	scrollingNode.position = ccp(0, 0);
	[parallax reset];
	[[ChunkManager sharedSingleton] resetWithLevel:@"jungleLevel"];
	[player reset];
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game.mp3" loop:YES];
	[self scheduleUpdate];
	
	// make node for camera to follow during intro
	followNode = [CCNode node];
	[scrollingNode addChild:followNode];
	followNode.position = ccpMult(ccp(258, 340), [ResolutionManager sharedSingleton].positionScale);;
	CCAction *move = [CCRepeatForever actionWithAction:[CCMoveBy actionWithDuration:2 position:ccp((int)player.minVelocity.x, 0)]];
	[followNode runAction:move];
	
	// kill chopper after a certain amount of time
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(killChopper) forTarget:self interval:5 paused:NO];
}

- (void) killChopper {
	if(state != kStatePause) {
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(killChopper) forTarget:self];
		if(chopper) {
			[scrollingNode removeChild:chopper cleanup:YES];
			[chopper release];
			chopper = nil;
		}
	}
}

- (void) finishGame {
	// update achievements
	[[GameCenter sharedSingleton] checkStatAchievements];
	// submit leaderboards
	[[GameCenter sharedSingleton] submitLeaderboards];
	// stop listening for touches
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	// remove hud
	[self removeChild:hud cleanup:YES];
	[self unscheduleUpdate];
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
	
#ifdef DEBUG_TEXTURES
	if(CGRectContainsPoint([debugButton boundingBox], ccpMult(touchPoint, 1/[ResolutionManager sharedSingleton].imageScale))) {
		// print out all textures currently in memory
		[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	}
#endif
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
	
}

#pragma mark -
#pragma mark delegate
- (void) buttonDown:(iCadeState)button {
	// check for icade achievement
	[[GameCenter sharedSingleton] setAchievementProgress:@"14" percent:100];
	
	if(button == iCadeJoystickDown || button == iCadeJoystickDownLeft || button == iCadeJoystickDownRight) {
		[player setWeaponAngle:-1];
	}
	else if(button == iCadeJoystickUp || button == iCadeJoystickUpLeft || button == iCadeJoystickUpRight) {
		[player setWeaponAngle:1];
	}
	else if(button == iCadeButtonA || button == iCadeButtonB || button == iCadeButtonC || button == iCadeButtonD || button == iCadeButtonE || button == iCadeButtonF || button == iCadeButtonG || button == iCadeButtonH) {
		[player jump];
	}
}

- (void) buttonUp:(iCadeState)button {
	if(button == iCadeJoystickDown || button == iCadeJoystickDownLeft || button == iCadeJoystickDownRight || button == iCadeJoystickUp || button == iCadeJoystickUpLeft || button == iCadeJoystickUpRight) {
		[player setWeaponAngle:0];
	}
	else if(button == iCadeButtonA || button == iCadeButtonB || button == iCadeButtonC || button == iCadeButtonD || button == iCadeButtonE || button == iCadeButtonF || button == iCadeButtonG || button == iCadeButtonH) {
		[player endJump];
	}
}

#pragma mark -
#pragma mark notifications
- (void) gameOver {
	// stop game logic
	[[BBLogic sharedSingleton] setEnabled:NO];
	
	[self finishGame];
	state = kStateGameOver;
	[gameOver updateFinalScore];
	[self addChild:gameOver z:DEPTH_MENU];
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"gameOver.mp3" loop:YES];
}

- (void) startGame {
	[self removeChild:mainMenu cleanup:YES];
	state = kStateIntro;
	[self playIntro];
}

- (void) restartGame {
	if(state == kStatePause) {
		[self finishGame];
		[self removeChild:pause cleanup:YES];
	}
	else if(state == kStateGameOver) {
		[self removeChild:gameOver cleanup:YES];
	}
	state = kStateIntro;
	[self playIntro];
}

- (void) resumeGame {
	state = kStateGame;
	[self removeChild:pause cleanup:YES];
}

- (void) gotoShop {
	if(state == kStateMainMenu) {
		[self removeChild:mainMenu cleanup:YES];
	}
	else if(state == kStateGameOver) {
		[self removeChild:gameOver cleanup:YES];
	}
	
	state = kStateShop;
	[self addChild:shop z:DEPTH_MENU];
}

- (void) gotoMain {
	if(state == kStateShop) {
		[self removeChild:shop cleanup:YES];
	}
	else if(state == kStateLeaderboards) {
		[self removeChild:leaderboards cleanup:YES];
	}
	else if(state == kStatePause) {
		[self finishGame];
		[self removeChild:pause cleanup:YES];
	}
	
	state = kStateMainMenu;
	[self addChild:mainMenu z:DEPTH_MENU];
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu.mp3" loop:YES];
}

- (void) gotoLeaderboards {
	if(state == kStateMainMenu) {
		state = kStateLeaderboards;
		[self removeChild:mainMenu cleanup:YES];
		[self addChild:leaderboards z:DEPTH_MENU];
	}
}

- (void) gotoPause {
	if(state == kStateGame) {
		state = kStatePause;
		[self addChild:pause z:DEPTH_MENU];
	}
}

- (void) gotoConfirmBuy:(NSNotification*)n {
	if(state == kStateShop) {
		state = kStateConfirmBuy;
		[confirmBuy updateWithInfo:[n userInfo]];
		[self addChild:confirmBuy z:DEPTH_MENU];
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

- (void) introDone {
	state = kStateGame;
	[self reset];
}

@end
