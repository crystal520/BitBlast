//
//  BBGameLayer.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBGameLayer.h"

#define kJumpUpTimeForSwipe 0.4
#define kJumpUpTimeForTap 0.25
#define kJumpUpDistanceForSwipe 30

#define kJumpDownTimeForSwipe 0.4
#define kJumpDownDistanceForSwipe 30

#define kAimTimeForSwipe 0.4
#define kAimDistanceForSwipe 30

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
        
        // startup GameCenter
        [GameCenter sharedSingleton];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMedals) name:kNavMedalsNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyItem:) name:kNavBuyItemNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelBuyItem) name:kNavCancelBuyItemNotification object:nil]; 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoPause) name:kNavPauseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeGame) name:kNavResumeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(introDone) name:kPlayerOutOfChopperNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spawnFinalBoss) name:kEventSpawnFinalBoss object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finalBossDead) name:kEventFinalBossDead object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameWin) name:kEventGameWin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tutorialOver) name:kEventTutorialOver object:nil];
		
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
		[[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
		[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:TOUCH_DEPTH_GAME swallowsTouches:YES];
	}
}

#pragma mark -
#pragma mark setup
- (void) setupICade {
	iCadeView = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
	[[CCDirector sharedDirector].view addSubview:iCadeView];
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
		CCAnimation *anim = [CCAnimation animationWithSpriteFrames:frames delay:[[d objectForKey:@"speed"] floatValue]];
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
	// reset session stats
	[self resetSessionStats];
	// listen for touches
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:TOUCH_DEPTH_GAME swallowsTouches:YES];
	self.isTouchEnabled = YES;
    // stop following the chopper for the intro
	[followNode stopAllActions];
	[scrollingNode removeChild:followNode cleanup:YES];
	followNode = player;
	[self updateCamera];
    // spawn boss to start the game if player was in the middle of a boss fight
    [[BBLogic sharedSingleton] checkQuickSpawnBoss];
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
        followNode.position = ccpAdd(player.position, [chopper getOffset]);
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
        newPos = ccp((int)newPos.x, (int)newPos.y);
        
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
    // see if we should enable the tutorial
#if DEBUG_ENABLE_TUTORIAL
    [[SettingsManager sharedSingleton] setBool:YES keyString:@"needsTutorial"];
    [[SettingsManager sharedSingleton] setInteger:TUTORIAL_STATE_JUMP_UP keyString:@"tutorialState"];
#endif
    // let everyone know that a new game is being started
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventNewGame object:nil]];
    // clear unused textures
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    // make sure end boss sequence is disabled
    [Globals sharedSingleton].endBossSequence = NO;
    // make sure intro boss sequence is disabled
    [Globals sharedSingleton].introBossSequence = NO;
    // set global tutorial values
    [Globals sharedSingleton].tutorial = [[SettingsManager sharedSingleton] getBool:@"needsTutorial"];
    [Globals sharedSingleton].tutorialState = (TutorialState)([[SettingsManager sharedSingleton] getInt:@"tutorialState"]);
    // make sure the game is resumed, or else weirdness occurs (camera not following player, etc.)
    [self resume];
	// create chopper for intro animation
	[self killChopper];
	chopper = [BBChopper new];
	[scrollingNode addChild:chopper z:DEPTH_GAME_INTRO_CHOPPER];
	// reset scrolling node position
    scrollingNode.position = ccp(0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0 : -45);
	// reset level
	[self resetLevel:[self getCurrentLevel]];
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
	[[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(killChopper) forTarget:self interval:5 paused:NO];
}

- (void) resetLevel:(NSString*)levelName {
    [self setBackgroundColorWithFile:levelName];
	[parallax resetWithFile:levelName];
	[[ChunkManager sharedSingleton] resetWithLevel:levelName];
}

- (void) killChopper {
	if(state != kStatePause) {
		[[[CCDirector sharedDirector] scheduler] unscheduleSelector:@selector(killChopper) forTarget:self];
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
	[[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
	[self unscheduleUpdate];
    // save player info
    [[SettingsManager sharedSingleton] saveToFile:@"player.plist"];
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

- (void) unfreeze {
    // resume the player, which effectively resumes the game (scrolling, bullets, etc.)
    [player resume];
    // also resume the coins so they stop spinning
    [[BBCoinManager sharedSingleton] resume];
    // resume dropships
    [[BBDropshipManager sharedSingleton] resume];
    // resume minibosses
    [[BBMinibossManager sharedSingleton] resume];
    // resume moving coins
    [[BBMovingCoinManager sharedSingleton] resume];
}

#pragma mark -
#pragma mark setters
- (void) setBackgroundColorWithFile:(NSString*)file {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:@"plist"]];
	// get color from dictionary
	NSArray *colorArray = [[dict objectForKey:@"backgroundColor"] componentsSeparatedByString:@", "];
	// make color
	ccColor3B bgColor = ccc3([[colorArray objectAtIndex:0] floatValue], [[colorArray objectAtIndex:1] floatValue], [[colorArray objectAtIndex:2] floatValue]);
    // remove background from screen
    [self removeChildByTag:SPRITE_TAG_BACKGROUND cleanup:YES];
	// create background with new color
	BBColorRectSprite *background = [BBColorRectSprite spriteWithColor:bgColor alpha:1];
    background.tag = SPRITE_TAG_BACKGROUND;
	[self addChild:background z:DEPTH_BACKGROUND];
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
                if(![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying:@"menu.mp3"]) {
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu.mp3" loop:YES];
                }
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
                    // only show HUD if not in the tutorial
                    if(![Globals sharedSingleton].tutorial) {
                        [self getChildByTag:SPRITE_TAG_MENU].visible = YES;
                    }
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
                newMenu = [[BBHud alloc] init];
                newMenu.tag = SPRITE_TAG_MENU;
                newMenu.visible = NO;
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
                    [self finishGame];
                }
                else if(state == kStatePause) {
                    [self clearMenuWithTag:SPRITE_TAG_POPUP];
                }
                break;
            case kStateMedals:
                if(state == kStateGameWin) {
                    [self finishGame];
                    [self clearMenuWithTag:SPRITE_TAG_OVERLAY];
                }
                [self clearMenuWithTag:SPRITE_TAG_MENU];
                newMenu = [[BBMedals alloc] init];
                newMenu.tag = SPRITE_TAG_MENU;
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
#pragma mark getters
- (NSString*) getCurrentLevel {
    // check for tutorial
    if([Globals sharedSingleton].tutorial) {
        return @"tutorial";
    }
    // see if the player should be in the boss level
    else if([[BBLogic sharedSingleton] getCanSpawnBoss]) {
        return @"bossLevel";
    }
    return @"jungleLevel";
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
    // check to see if player swiped down to jump down
    if([inputController timeForLastTouch] < kJumpDownTimeForSwipe && [inputController distanceForLastTouch].y < -kJumpDownDistanceForSwipe) {
        [player jumpDown];
    }
    else if([inputController timeForLastTouch] < kJumpUpTimeForTap) {
        [player jump];
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
    BBColorRectSprite *bg = [BBColorRectSprite spriteWithColor:ccc3(0, 0, 0) alpha:0];
    bg.tag = SPRITE_TAG_BOSS_OVERLAY;
    [scrollingNode addChild:bg z:DEPTH_GAME_BOSS_INTRO];
    // make sure rectangle is on screen
    [[scrollingNode getChildByTag:SPRITE_TAG_BOSS_OVERLAY] setPosition:ccpMult([Globals sharedSingleton].playerPosition, [ResolutionManager sharedSingleton].positionScale)];
    // swap player depth to be above everything
    [scrollingNode reorderChild:player z:DEPTH_GAME_PLAYER_BOSS_INTRO];
    // start fading in color rect
    CCAction *fadeAction = [CCSequence actions:[CCFadeTo actionWithDuration:3 opacity:255], [CCCallFunc actionWithTarget:self selector:@selector(finishSpawnFinalBoss)], nil];
    [[scrollingNode getChildByTag:SPRITE_TAG_BOSS_OVERLAY] runAction:fadeAction];
}

- (void) finishSpawnFinalBoss {
    // switch to boss level
    [self resetLevel:@"bossLevel"];
    // unload everything (minibosses, dropships, minions, coins, moving coins)
    [[BBMinibossManager sharedSingleton] setEnabled:NO];
    [[BBDropshipManager sharedSingleton] setEnabled:NO];
    [[BBEnemyManager sharedSingleton] setEnabled:NO];
    [[BBCoinManager sharedSingleton] setEnabled:NO];
    [[BBMovingCoinManager sharedSingleton] setEnabled:NO];
    [[BulletManager sharedSingleton] setEnabled:NO];
    // spawn boss
    [[BBBossManager sharedSingleton] tryToSpawnBoss];
    // fade color rect out
    CCAction *fadeAction = [CCSequence actions:[CCFadeTo actionWithDuration:3 opacity:0], [CCCallFunc actionWithTarget:self selector:@selector(bossStart)], nil];
    [[scrollingNode getChildByTag:SPRITE_TAG_BOSS_OVERLAY] runAction:fadeAction];
}

- (void) bossStart {
    // remove the faded background
    [scrollingNode removeChildByTag:SPRITE_TAG_BOSS_OVERLAY cleanup:YES];
    // no longer in the boss intro sequence
    [Globals sharedSingleton].introBossSequence = NO;
    // unfreeze everything
    [self unfreeze];
    // trigger the boss intro
    [[BBBossManager sharedSingleton] triggerBoss];
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

- (void) gotoMedals {
    [self setState:kStateMedals];
}

- (void) gameWin {
    // stop screen shaking
    [self stopActionByTag:ACTION_TAG_SCREEN_SHAKE];
    // stop boss flashing and exploding
    [[BBBossManager sharedSingleton] gameOver];
}

- (void) tutorialOver {
    // show HUD
    [self getChildByTag:SPRITE_TAG_MENU].visible = YES;
    // let player know that the tutorial is over
    [player tutorialOver];
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
