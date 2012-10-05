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
		
#if DEBUG_NO_SOUND
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
		parallax = [[ParallaxManager alloc] init];
		[self addChild:parallax z:DEPTH_PARALLAX];
		
		// for objects that need to scroll
		scrollingNode = [[CCNode alloc] init];
		[self addChild:scrollingNode z:DEPTH_LEVEL];
		
		// load level
		[scrollingNode addChild:[ChunkManager sharedSingleton] z:DEPTH_GAME_LEVEL];
		[self resetLevel:@"jungleLevel"];
		
		// add dropships to scrollingNode
		[scrollingNode addChild:[BBDropshipManager sharedSingleton].backNode z:DEPTH_GAME_DROPSHIPS];
		[scrollingNode addChild:[BBDropshipManager sharedSingleton].frontNode z:DEPTH_GAME_DROPSHIPS_INTRO];
		// add enemies to scrollingNode
		[scrollingNode addChild:[BBEnemyManager sharedSingleton] z:DEPTH_GAME_ENEMIES];
		// add coins to scrollingNode
		[scrollingNode addChild:[BBCoinManager sharedSingleton] z:DEPTH_GAME_COINS];
		[scrollingNode addChild:[BBMovingCoinManager sharedSingleton] z:DEPTH_GAME_MOVING_COINS];
        // add minibosses to scrollingNode
        [scrollingNode addChild:[BBMinibossManager sharedSingleton].backNode z:DEPTH_GAME_MINIBOSSES];
        [scrollingNode addChild:[BBMinibossManager sharedSingleton].frontNode z:DEPTH_GAME_MINIBOSSES_INTRO];
        [scrollingNode addChild:[BBBossManager sharedSingleton] z:DEPTH_GAME_BOSS];
		
		// create background sprite
		[self createBackground];
		
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoGameWin) name:kNavGameWinNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyItem:) name:kNavBuyItemNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelBuyItem) name:kNavCancelBuyItemNotification object:nil]; 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoPause) name:kNavPauseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeGame) name:kNavResumeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(introDone) name:kPlayerOutOfChopperNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spawnFinalBoss) name:kEventSpawnFinalBoss object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finalBossDead) name:kEventFinalBossDead object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameWin) name:kEventGameWin object:nil];
		
		// set initial state
		state = kStateUnknown;
		[self setState:kStateMainMenu];
		
		// set ourselves as the Chartboost delegate
		[Chartboost sharedChartboost].delegate = self;
        
        inputController = [[BBInputController alloc] init];
        inputController.delegate = self;
        
#if DEBUG_PHYSICS
        [self addChild:[[GB2DebugDrawLayer alloc] init] z:30];
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
	background = [CCSprite spriteWithFile:@"white.png" rect:CGRectMake(-[ResolutionManager sharedSingleton].size.width, -[ResolutionManager sharedSingleton].size.height, [ResolutionManager sharedSingleton].size.width * 2, [ResolutionManager sharedSingleton].size.height * 2)];
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
		[[BBEnemyManager sharedSingleton] update:delta];
		[[BBDropshipManager sharedSingleton] update:delta];
        [[BBMinibossManager sharedSingleton] update:delta];
		[[BBBossManager sharedSingleton] update:delta];
		[[BBCoinManager sharedSingleton] update:delta];
		[[BBMovingCoinManager sharedSingleton] update:delta];
		[self updateCamera];
        [[GB2Engine sharedInstance] update:delta];
		[(BBHud*)([self getChildByTag:SPRITE_TAG_MENU]) update:delta];
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
	
    // only update if the game isn't paused
    if(!paused && ![Globals sharedSingleton].endBossSequence && ![Globals sharedSingleton].introBossSequence) {
        // keep track of node's previous position
        CGPoint prevPos = scrollingNode.position;
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
        
        CGPoint newPos = ccp(-1 * followNode.position.x + cameraOffset.x, scrollingNode.position.y - yOffset / [ResolutionManager sharedSingleton].imageScale);
        
        // make sure newPos's y coordinate is not less than the current chunk's lowest point
        if(newPos.y > [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition) {
            newPos.y = [[ChunkManager sharedSingleton] getCurrentChunk].lowestPosition;
        }
        [scrollingNode setPosition:newPos];
        
        [parallax update:ccpSub(scrollingNode.position, prevPos)];
    }
}

#pragma mark -
#pragma mark actions
- (void) playIntro {
    // make sure end boss sequence is disabled
    [Globals sharedSingleton].endBossSequence = NO;
    // make sure intro boss sequence is disabled
    [Globals sharedSingleton].introBossSequence = NO;
    // make sure the game is resumed, or else weirdness occurs (camera not following player, etc.)
    [self resume];
	// create chopper for intro animation
	[self killChopper];
	chopper = [BBChopper new];
	[scrollingNode addChild:chopper z:DEPTH_GAME_INTRO_CHOPPER];
	
	// reset level
	[self resetLevel:@"jungleLevel"];
	[player reset];
#if !DEBUG_NO_MUSIC
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

- (void) resetLevel:(NSString*)levelName {
    scrollingNode.position = ccp(0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0 : -45);
    [self setBackgroundColorWithFile:levelName];
	[parallax resetWithFile:levelName];
	[[ChunkManager sharedSingleton] resetWithLevel:levelName];
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
	[self unscheduleUpdate];
}

- (void) clearMenuWithTag:(SpriteTag)tag {
	// clean up old menu node
	CCNode *oldMenu = [self getChildByTag:tag];
    if(oldMenu) {
        [self removeChild:oldMenu cleanup:YES];
        [oldMenu release];
        oldMenu = nil;
    }
}

- (void) pause {
    paused = YES;
    [self pauseSchedulerAndActions];
    // stop screen shaking for now
    [self stopActionByTag:ACTION_TAG_SCREEN_SHAKE];
}

- (void) resume {
    paused = NO;
    [self resumeSchedulerAndActions];
    // if we're still in the end boss sequence, start shaking the screen again
    if([Globals sharedSingleton].endBossSequence) {
        [self shakeScreen];
    }
    // if we're still in the intro boss sequence, don't do anything
    else if([Globals sharedSingleton].introBossSequence) {
    }
    else {
        // resume normal player activity
        [player resume];
        // resume normal coin activity
        [[BBCoinManager sharedSingleton] resume];
    }
}

- (void) shakeScreen {
    CCAction *shakeAction = [CCRepeatForever actionWithAction:[CCShake actionWithDuration:0.1 amplitude:ccp(5,5) dampening:YES]];
    shakeAction.tag = ACTION_TAG_SCREEN_SHAKE;
    [self runAction:shakeAction];
}

- (void) freeze {
    // pause the player, which effectively pauses the game (scrolling, bullets, etc.)
    [player pause];
    // also pause the coins so they stop spinning
    [[BBCoinManager sharedSingleton] pause];
    // pause dropships
    [[BBDropshipManager sharedSingleton] pause];
    // pause minibosses
    [[BBMinibossManager sharedSingleton] pause];
    // pause moving coins
    [[BBMovingCoinManager sharedSingleton] pause];
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
				if(state == kStatePause || state == kStateGameWin) {
					[self finishGame];
					[self clearMenuWithTag:SPRITE_TAG_POPUP];
					[self clearMenuWithTag:SPRITE_TAG_OVERLAY];
				}
#if !DEBUG_NO_MUSIC
				[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu.mp3" loop:YES];
#endif
				[self clearMenuWithTag:SPRITE_TAG_MENU];
				newMenu = [[BBMainMenu alloc] init];
				newMenu.tag = SPRITE_TAG_MENU;
				break;
			case kStateGame:
				if(state == kStatePause) {
					[self clearMenuWithTag:SPRITE_TAG_POPUP];
				}
				else {
					[self reset];
					[self clearMenuWithTag:SPRITE_TAG_MENU];
					newMenu = [[BBHud alloc] init];
					newMenu.tag = SPRITE_TAG_MENU;
				}
				break;
			case kStateShop:
				if(state == kStateConfirmBuy) {
					[self clearMenuWithTag:SPRITE_TAG_POPUP];
				}
				else {
					[self clearMenuWithTag:SPRITE_TAG_POPUP];
					[self clearMenuWithTag:SPRITE_TAG_MENU];
					newMenu = [[BBShop alloc] init];
					newMenu.tag = SPRITE_TAG_MENU;
				}
				break;
			case kStateConfirmBuy:
				newMenu = [[BBConfirmBuy alloc] init];
				newMenu.tag = SPRITE_TAG_POPUP;
				break;
			case kStatePause:
				if(state == kStateGame || state == kStateGameWin) {
					newMenu = [[BBPause alloc] init];
					newMenu.tag = SPRITE_TAG_POPUP;
				}
				break;
			case kStateIntro:
				if(state == kStatePause) {
					[self finishGame];
				}
				[self clearMenuWithTag:SPRITE_TAG_POPUP];
				[self clearMenuWithTag:SPRITE_TAG_MENU];
				[self playIntro];
				break;
			case kStateGameOver:
				[self finishGame];
#if !DEBUG_NO_MUSIC
				[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"gameOver.mp3" loop:YES];
#endif
				newMenu = [[BBGameOver alloc] init];
				newMenu.tag = SPRITE_TAG_POPUP;
				[(BBGameOver*)(newMenu) updateFinalScore];
				break;
            case kStateGameWin:
                if(state == kStateGame) {
                    newMenu = [[BBGameWin alloc] init];
                    newMenu.tag = SPRITE_TAG_OVERLAY;
                }
                else if(state == kStatePause) {
                    [self clearMenuWithTag:SPRITE_TAG_POPUP];
                }
                break;
			default:
				break;
		}
        prevState = state;
		state = newState;
        [Globals sharedSingleton].gameState = newState;
		if(newMenu) {
            // set offset if camera is shaking
            [self setPosition:[ResolutionManager sharedSingleton].position];
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
    [self resume];
	[self setState:prevState];
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
    [self pause];
}

- (void) gotoConfirmBuy:(NSNotification*)n {
	[self setState:kStateConfirmBuy];
	BBConfirmBuy *confirmBuy = (BBConfirmBuy*)([self getChildByTag:SPRITE_TAG_POPUP]);
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

- (void) spawnFinalBoss {
    // set global variable so other classes can use it
    [Globals sharedSingleton].introBossSequence = YES;
    // freeze the game
    [self freeze];
    // create black color rectangle to fade in on top of everything but the player and the HUD
    [scrollingNode addChild:[BBColorRectSprite spriteWithColor:ccc3(0, 0, 0) alpha:0] z:DEPTH_GAME_BOSS_INTRO];
    // make sure rectangle is on screen
    [[scrollingNode getChildByTag:SPRITE_TAG_BACKGROUND] setPosition:[Globals sharedSingleton].playerPosition];
    // swap player depth to be above everything
    [scrollingNode reorderChild:player z:DEPTH_GAME_PLAYER_BOSS_INTRO];
    // start fading in color rect
    CCAction *fadeAction = [CCSequence actions:[CCFadeTo actionWithDuration:3 opacity:255], [CCCallFunc actionWithTarget:self selector:@selector(finishSpawnFinalBoss)], nil];
    [[scrollingNode getChildByTag:SPRITE_TAG_BACKGROUND] runAction:fadeAction];
}

- (void) finishSpawnFinalBoss {
    NSLog(@"FINISH SPAWN BOSS");
}

- (void) finalBossDead {
    // set global variable so other classes can use it
    [Globals sharedSingleton].endBossSequence = YES;
    // freeze the game
    [self freeze];
    // shake the screen
    [self shakeScreen];
}

- (void) gotoGameWin {
    [self setState:kStateGameWin];
}

- (void) gameWin {
    // stop screen shaking
    [self stopActionByTag:ACTION_TAG_SCREEN_SHAKE];
    // stop boss flashing and exploding
    [[BBBossManager sharedSingleton] gameOver];
}

#pragma mark -
#pragma mark ChartboostDelegate
- (BOOL) shouldDisplayInterstitial:(NSString *)interstitialView {
	if(state == kStateMainMenu) {
		return YES;
	}
	return NO;
}

@end
