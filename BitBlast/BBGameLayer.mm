//
//  BBGameLayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBGameLayer.h"

#define kJumpUpTimeForSwipe 0.25
#define kJumpUpDistanceForSwipe 50

#define kJumpDownTimeForSwipe 0.25
#define kJumpDownDistanceForSwipe 50

#define kAimTimeForSwipe 0.25
#define kAimDistanceForSwipe 20

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
        
        // load physics shapes
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"collisionShapes.plist"];
		
		// setup iCade controls
		[self setupICade];
		
		[self setScale:[ResolutionManager sharedSingleton].imageScale];
		[self setPosition:[ResolutionManager sharedSingleton].position];
		[self loadImages];
        [self loadAnimations];
		[self loadCameraVariables];
		
		// add dialog queue to layer
		[self addChild:[BBDialogQueue sharedSingleton] z:DEPTH_MENU_POPUP];
		
		// create parallax scrolling background
		parallax = [[ParallaxManager alloc] initWithFile:@"jungleLevel"];
		[self addChild:parallax z:DEPTH_PARALLAX];
		
		// for objects that need to scroll
		scrollingNode = [[CCNode alloc] init];
		[self addChild:scrollingNode z:DEPTH_LEVEL];
		
		// load level
		[scrollingNode addChild:[ChunkManager sharedSingleton] z:DEPTH_GAME_LEVEL];
		[[ChunkManager sharedSingleton] loadChunksForLevel:@"jungleLevel"];
		
		// add dropships to scrollingNode
		[scrollingNode addChild:[BBDropshipManager sharedSingleton].backNode z:DEPTH_GAME_DROPSHIPS];
		[scrollingNode addChild:[BBDropshipManager sharedSingleton].frontNode z:DEPTH_GAME_DROPSHIPS_INTRO];
		// add enemies to scrollingNode
		[scrollingNode addChild:[EnemyManager sharedSingleton] z:DEPTH_GAME_ENEMIES];
		// add coins to scrollingNode
		[scrollingNode addChild:[BBCoinManager sharedSingleton] z:DEPTH_GAME_COINS];
		[scrollingNode addChild:[BBMovingCoinManager sharedSingleton] z:DEPTH_GAME_COINS];
		
		// create background sprite
		[self createBackground];
		[self setBackgroundColorWithFile:@"jungleLevel"];
		
		// create player
		player = [[BBPlayer alloc] init];
		[scrollingNode addChild:player z:DEPTH_GAME_PLAYER];
		
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
		
		//[[BBEquipmentManager sharedSingleton] equip:@"glider"];
		[[BBEquipmentManager sharedSingleton] equip:@"doublejump"];
		
		// set initial state
		state = kStateUnknown;
		[self setState:kStateMainMenu];
		
		// set ourselves as the ChartBoost delegate
		[ChartBoost sharedChartBoost].delegate = self;
        
        inputController = [[BBInputController alloc] init];
        inputController.delegate = self;
        
#ifdef DEBUG_PHYSICS
        [self addChild:[[GB2DebugDrawLayer alloc] init] z:30];
#endif
		
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
	[player release];
	[parallax release];
    [inputController release];
	[super dealloc];
}

- (void) onEnter {
	[super onEnter];
	
	// make sure player can still tap on the screen after returning from backgrounding the game
	if(state == kStateGame) {
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:TOUCH_DEPTH_GAME swallowsTouches:YES];
	}
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

- (void) loadAnimations {
    // get animation file
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"animations" ofType:@"plist"]];
	// get animations from dictionary
	NSArray *dictAnimations = [NSArray arrayWithArray:[dictionary objectForKey:@"animations"]];
	// loop through and create animations
	for(NSDictionary *d in dictAnimations) {
		// get the frames
		NSMutableArray *frames = [NSMutableArray array];
		for(int i=0,j=[[d objectForKey:@"frames"] count];i<j;i++) {
			[frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[d objectForKey:@"frames"] objectAtIndex:i]]];
		}
		// create the animation object
		CCAnimation *anim = [CCAnimation animationWithFrames:frames delay:[[d objectForKey:@"speed"] floatValue]];
		// save animation in cache
		[[CCAnimationCache sharedAnimationCache] addAnimation:anim name:[d objectForKey:@"name"]];
	}
}

- (void) loadCameraVariables {
	
	// get dictionary from plist
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cameraProperties" ofType:@"plist"]];
	
	cameraOffset = ccp([[plist objectForKey:@"offsetX"] floatValue], [[plist objectForKey:@"offsetY"] floatValue]);
	cameraBounds = ccp([[plist objectForKey:@"minimumY"] floatValue], [CCDirector sharedDirector].winSize.height - [[plist objectForKey:@"maximumY"] floatValue]);
	[Globals sharedSingleton].cameraOffset = cameraOffset;
	cameraOffset = ccpMult(cameraOffset, [ResolutionManager sharedSingleton].positionScale);
}

- (void) reset {
    // clear unused textures
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
	// let everyone know that a new game is being started
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventNewGame object:nil]];
	// reset session stats
	[self resetSessionStats];
	
	// listen for touches
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:TOUCH_DEPTH_GAME swallowsTouches:YES];
	self.isTouchEnabled = YES;
	
	// add hud to screen
	//[self addChild:hud z:DEPTH_MENU];
	[followNode stopAllActions];
	[scrollingNode removeChild:followNode cleanup:YES];
	followNode = player;
	[self updateCamera];
	
	// start up game logic
	[[BBLogic sharedSingleton] setEnabled:YES];
	// add BulletManager to the scrolling node
	[[BulletManager sharedSingleton] setNode:scrollingNode];
	[[BBWeaponManager sharedSingleton] setNode:scrollingNode];
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
		[[BBMovingCoinManager sharedSingleton] update:delta];
		[self updateCamera];
        [[GB2Engine sharedInstance] update:delta];
		[(BBHud*)([self getChildByTag:TAG_MENU]) update:delta];
	}
	else if(state == kStateIntro) {
        followNode.position = ccpAdd(followNode.position, ccpMult(player.minVelocity, delta * [ResolutionManager sharedSingleton].positionScale));
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
    float yOffset = 0;
    
    if(state != kStateIntro) {
        // convert player's y position to screen space
        CGPoint currentPlayerScreenPosition = [followNode convertToWorldSpace:CGPointZero];
        
        // check to see if player is too close to the top of the screen
        if(currentPlayerScreenPosition.y < cameraBounds.x) {
            yOffset = currentPlayerScreenPosition.y - cameraBounds.x;
        }
        // check to see if player is too close to the bottom of the screen
        else if(currentPlayerScreenPosition.y > cameraBounds.y) {
            yOffset = currentPlayerScreenPosition.y - cameraBounds.y;
        }
    }
	
	//CGPoint newPos = ccp(-1 * followNode.position.x + cameraOffset.x, scrollingNode.position.y + cameraOffset.y - yOffset);
    CGPoint newPos = ccp(-1 * followNode.position.x + cameraOffset.x, scrollingNode.position.y - yOffset);
    
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
	[scrollingNode addChild:chopper z:DEPTH_GAME_INTRO_CHOPPER];
	
	// reset level
	scrollingNode.position = ccp(0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0 : -45);
	[parallax reset];
	[[ChunkManager sharedSingleton] resetWithLevel:@"jungleLevel"];
	[player reset];
#ifndef DEBUG_NO_MUSIC
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game.mp3" loop:YES];
#endif
	[self scheduleUpdate];
	
	// make node for camera to follow during intro
	followNode = [CCNode node];
	[scrollingNode addChild:followNode];
	followNode.position = ccpMult(ccp(258, 340), [ResolutionManager sharedSingleton].positionScale);
	//CCAction *move = [CCRepeatForever actionWithAction:[CCMoveBy actionWithDuration:1 position:ccpMult(ccp((int)player.minVelocity.x, 0), [ResolutionManager sharedSingleton].positionScale)]];
	//[followNode runAction:move];
	
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
	// stop game logic
	[[BBLogic sharedSingleton] setEnabled:NO];
	// update achievements
	[[GameCenter sharedSingleton] checkStatAchievements];
	// submit leaderboards
	[[GameCenter sharedSingleton] submitLeaderboards];
	// stop listening for touches
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	// remove hud
	//[self removeChild:hud cleanup:YES];
	[self unscheduleUpdate];
}

- (void) clearMenuWithTag:(SpriteTag)tag {
	// clean up old menu node
	CCNode *oldMenu = [self getChildByTag:tag];
	[self removeChild:oldMenu cleanup:YES];
	[oldMenu release];
	oldMenu = nil;
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

- (void) setState:(GameState)newState {
	if(newState != state) {
		CCNode *newMenu = nil;
		switch (newState) {
			case kStateMainMenu:
				if(state == kStatePause) {
					[self finishGame];
					[self clearMenuWithTag:TAG_POPUP];
				}
#ifndef DEBUG_NO_MUSIC
				[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu.mp3" loop:YES];
#endif
				[self clearMenuWithTag:TAG_MENU];
				newMenu = [[BBMainMenu alloc] init];
				newMenu.tag = TAG_MENU;
				break;
			case kStateGame:
				if(state == kStatePause) {
					[self clearMenuWithTag:TAG_POPUP];
				}
				else {
					[self reset];
					[self clearMenuWithTag:TAG_MENU];
					newMenu = [[BBHud alloc] init];
					newMenu.tag = TAG_MENU;
				}
				break;
			case kStateShop:
				if(state == kStateConfirmBuy) {
					[self clearMenuWithTag:TAG_POPUP];
				}
				else {
					[self clearMenuWithTag:TAG_POPUP];
					[self clearMenuWithTag:TAG_MENU];
					newMenu = [[BBShop alloc] init];
					newMenu.tag = TAG_MENU;
				}
				break;
			case kStateConfirmBuy:
				newMenu = [[BBConfirmBuy alloc] init];
				newMenu.tag = TAG_POPUP;
				break;
			case kStatePause:
				if(state == kStateGame) {
					newMenu = [[BBPause alloc] init];
					newMenu.tag = TAG_POPUP;
				}
				break;
			case kStateIntro:
				if(state == kStatePause) {
					[self finishGame];
				}
				[self clearMenuWithTag:TAG_POPUP];
				[self clearMenuWithTag:TAG_MENU];
				[self playIntro];
				break;
			case kStateGameOver:
				[self finishGame];
#ifndef DEBUG_NO_MUSIC
				[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"gameOver.mp3" loop:YES];
#endif
				newMenu = [[BBGameOver alloc] init];
				newMenu.tag = TAG_POPUP;
				[(BBGameOver*)(newMenu) updateFinalScore];
				break;
			default:
				break;
		}
		state = newState;
        [Globals sharedSingleton].gameState = newState;
		if(newMenu) {
			[self addChild:newMenu z:DEPTH_MENU];
		}
	}
}

#pragma mark -
#pragma mark touch input
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	[inputController ccTouchBegan:touch withEvent:event];
	return true;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [inputController ccTouchMoved:touch withEvent:event];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	[inputController ccTouchEnded:touch withEvent:event];
	
#ifdef DEBUG_TEXTURES
	if(CGRectContainsPoint([debugButton boundingBox], ccpMult(touchPoint, 1/[ResolutionManager sharedSingleton].imageScale))) {
		// print out all textures currently in memory
		[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	}
#endif
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
	[inputController ccTouchCancelled:touch withEvent:event];
}

#pragma mark -
#pragma mark BBInputControllerDelegate
- (void) inputControllerTouchEnded {
    // check to see if player swiped up to jump
    if([inputController timeForLastTouch] < kJumpUpTimeForSwipe && [inputController distanceForLastTouch].y > kJumpUpDistanceForSwipe) {
        [player jump];
    }
    else if([inputController timeForLastTouch] < kJumpDownTimeForSwipe && [inputController distanceForLastTouch].y < -kJumpDownDistanceForSwipe) {
        [player jumpDown];
    }
    else {
        [player setWeaponAngle:0];
    }
}

- (void) inputControllerTouchMoved {
    // check to see if player is swiping up or down from original location
    if([inputController timeForLastTouch] > kAimTimeForSwipe) {
        if([inputController distanceForLastTouch].y > kAimDistanceForSwipe) {
            [player setWeaponAngle:1];
        }
        else if([inputController distanceForLastTouch].y < -kAimDistanceForSwipe) {
            [player setWeaponAngle:-1];
        }
        else {
            [player setWeaponAngle:0];
        }
    }
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
	else if(button == iCadeButtonA || button == iCadeButtonC || button == iCadeButtonE || button == iCadeButtonG) {
		[player jump];
	}
    else if(button == iCadeButtonB || button == iCadeButtonD || button == iCadeButtonF || button == iCadeButtonH) {
        [player jumpDown];
    }
}

- (void) buttonUp:(iCadeState)button {
	if(button == iCadeJoystickDown || button == iCadeJoystickDownLeft || button == iCadeJoystickDownRight || button == iCadeJoystickUp || button == iCadeJoystickUpLeft || button == iCadeJoystickUpRight) {
		[player setWeaponAngle:0];
	}
	else if(button == iCadeButtonA || button == iCadeButtonC || button == iCadeButtonE || button == iCadeButtonG) {
		[player endJump];
	}
}

#pragma mark -
#pragma mark notifications
- (void) gameOver {
	[self setState:kStateGameOver];
}

- (void) startGame {
	[self setState:kStateIntro];
}

- (void) restartGame {
	[self setState:kStateIntro];
}

- (void) resumeGame {
	[self setState:kStateGame];
}

- (void) gotoShop {
	[self setState:kStateShop];
}

- (void) gotoMain {
	[self setState:kStateMainMenu];
}

- (void) gotoLeaderboards {
	/*if(state == kStateMainMenu) {
		state = kStateLeaderboards;
		[self removeChild:mainMenu cleanup:YES];
		[self addChild:leaderboards z:DEPTH_MENU];
	}*/
}

- (void) gotoPause {
	[self setState:kStatePause];
}

- (void) gotoConfirmBuy:(NSNotification*)n {
	[self setState:kStateConfirmBuy];
	BBConfirmBuy *confirmBuy = (BBConfirmBuy*)([self getChildByTag:TAG_POPUP]);
	[confirmBuy updateWithInfo:[n userInfo]];
}

- (void) buyItem:(NSNotification*)n {
	[self setState:kStateShop];
}

- (void) cancelBuyItem {
	[self setState:kStateShop];
}

- (void) introDone {
	[self setState:kStateGame];
}

#pragma mark -
#pragma mark ChartBoostDelegate
- (BOOL) shouldDisplayInterstitial:(UIView *)interstitialView {
	if(state == kStateMainMenu) {
		return YES;
	}
	return NO;
}

@end
