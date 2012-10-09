//
//  BBBoss.m
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBBoss.h"

@implementation BBBoss

@synthesize enabled, explosionManager, currentAIStage;

- (id) initWithFile:(NSString *)filename {
    if((self = [super initWithFile:filename])) {
        // keep track of currently equipped weapons for animating boss
        currentTopWeapon = [NSMutableString new];
        currentBottomWeapon = [NSMutableString new];
        // get maximum health of the boss
        maxHealth = [[dictionary objectForKey:@"health"] floatValue];
        curHealth = maxHealth;
        // grab sounds from dictionary
        sounds = [[dictionary objectForKey:@"sounds"] retain];
        // get hit sound separately so we have more control with it
        hitSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:[sounds objectForKey:@"hit"]] retain];
        // make array for holding pieces
        pieces = [NSMutableArray new];
        // create boss pieces and add to boss
        NSArray *bossPieces = [dictionary objectForKey:@"pieces"];
        for(NSDictionary *d in bossPieces) {
            BBBossPiece *piece = [[BBBossPiece alloc] initWithDictionary:d];
            [self addChild:piece];
            [pieces addObject:piece];
            [piece release];
        }
        // disable to start
        [self setEnabled:NO];
        // set content size from dictionary
        self.contentSize = CGSizeFromString([dictionary objectForKey:@"size"]);
        self.anchorPoint = ccp(0, 0);
        
        // set defaults in case they don't exist
        if(![[SettingsManager sharedSingleton] doesExist:@"bossHealth"]) {
            [[SettingsManager sharedSingleton] setFloat:maxHealth keyString:@"bossHealth"];
        }
        if(![[SettingsManager sharedSingleton] doesExist:@"bossStage"]) {
            [[SettingsManager sharedSingleton] setInteger:0 keyString:@"bossStage"];
        }
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
    [pieces release];
    [currentTopWeapon release];
    [currentBottomWeapon release];
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
    if(newEnabled) {
        [self setState:BOSS_STATE_INTRO_WAIT];
    }
    else {
        [self reset];
    }
	enabled = newEnabled;
    self.visible = newEnabled;
}

- (void) setColor:(ccColor3B)color {
    for(BBBossPiece *p in pieces) {
        [p setColor:color];
    }
}

- (void) setState:(BossState)newState {
    switch(newState) {
        case BOSS_STATE_INTRO_WAIT:
            [self setColor:ccc3(0, 0, 0)];
            // hide the laser blast initially
            [[self getPieceWithType:@"laserblast"] setVisible:NO];
            break;
        case BOSS_STATE_INTRO_APPEAR:
            alive = YES;
            [self fadeInColor];
            break;
        case BOSS_STATE_BATTLE:
            // see if we need to use weapons from save
            if([[SettingsManager sharedSingleton] getInt:@"bossStage"] > 0 || [[SettingsManager sharedSingleton] getFloat:@"bossHealth"] < maxHealth) {
                currentAIStage = [[SettingsManager sharedSingleton] getInt:@"bossStage"];
                [self equipFromSave];
            }
            else {
                // load weapons and start the boss battle!
                self.currentAIStage = [[SettingsManager sharedSingleton] getInt:@"bossStage"];
            }
            // make sure collision shapes for boss pieces are active
            for(BBBossPiece *p in pieces) {
                [p setEnabled:YES];
            }
            break;
        case BOSS_STATE_DEAD:
            [self die];
            break;
        default:
            break;
    }
    state = newState;
}



- (void) setCurrentAIStage:(int)newCurrentAIStage {
    currentAIStage = newCurrentAIStage;
    
    // clear the weapons out so boss stops shooting
    [self clearWeapons];
    
    // see if only one weapon should be equipped
    if([[[self getAIStage] objectForKey:@"chooseOnlyOne"] boolValue]) {
        float ran = CCRANDOM_0_1();
        if(ran < 0.5) {
            [self equipBottomWeapon];
        }
        else {
            [self equipTopWeapon];
        }
    }
    else {
        [self equipBottomWeapon];
        [self equipTopWeapon];
    }
    
    [[BBWeaponManager sharedSingleton] setEnabled:YES forType:WEAPON_INVENTORY_MINIBOSS];
    [[BBWeaponManager sharedSingleton] setNode:self.parent forType:WEAPON_INVENTORY_MINIBOSS];
}

#pragma mark -
#pragma mark getters
- (BBBossPiece*) getPieceWithType:(NSString *)pieceType {
    for(BBBossPiece *p in pieces) {
        if([p.type isEqualToString:pieceType]) {
            return p;
        }
    }
    return nil;
}

- (NSDictionary*) getAIStage {
    return [[dictionary objectForKey:@"aiStages"] objectAtIndex:currentAIStage];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
    if(enabled) {
        // get right side position in world coordinates
        float right = [Globals sharedSingleton].playerPosition.x - [Globals sharedSingleton].cameraOffset.x + [ResolutionManager sharedSingleton].size.width * [ResolutionManager sharedSingleton].inversePositionScale;
        //float bottom = MAX([Globals sharedSingleton].playerPosition.y - 311, 0);
        dummyPosition = ccp(right - self.contentSize.width, 0);
        
        // update each piece of the boss
        [self updatePieces:delta];
        [super update:delta];
        [explosionManager update:delta];
        
        // check the current state of the boss
        if(state == BOSS_STATE_BATTLE) {
            
            if(alive) {
                [self updateWeapons:delta];
            }
            
            // make sure the boss has weapons equipped
            if([[[BBWeaponManager sharedSingleton] weaponsForType:WEAPON_INVENTORY_MINIBOSS] count] > 0) {
                // get the head piece
                BBBossPiece *headPiece = [self getPieceWithType:@"head"];
                
                // make sure the head isn't animating
                if(![headPiece getActionByTag:ACTION_TAG_ANIMATION]) {
                    // see if a top weapon exists
                    if(![currentTopWeapon isEqualToString:@""]) {
                        // check to see if the top weapon is not firing and the mouth is still open
                        if(![[[BBWeaponManager sharedSingleton] weaponWithID:currentTopWeapon forType:WEAPON_INVENTORY_MINIBOSS] getIsFiring] && [headPiece isFrameDisplayed:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"boss3.png"]]) {
                            [headPiece playAnimation:@"bossCloseMouth"];
                        }
                        // check to see if the mouth is about to fire and the mouth is closed
                        if([[[BBWeaponManager sharedSingleton] weaponWithID:currentTopWeapon forType:WEAPON_INVENTORY_MINIBOSS] getMinTimeToFire] < 0.2 && [headPiece isFrameDisplayed:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"boss1.png"]]) {
                            [headPiece playAnimation:@"bossOpenMouth"];
                        }
                    }
                    // just close the mouth if it isn't already
                    else {
                        if([headPiece isFrameDisplayed:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"boss3.png"]]) {
                            [headPiece playAnimation:@"bossCloseMouth"];
                        }
                    }
                }
                
                // get laser blast piece
                BBBossPiece *laserPiece = [self getPieceWithType:@"laserblast"];
                
                // check to see if the bottom weapon has fired
                if([[[BBWeaponManager sharedSingleton] weaponWithID:currentBottomWeapon forType:WEAPON_INVENTORY_MINIBOSS] getDidFireBullet] && (![laserPiece getActionByTag:ACTION_TAG_FLASH_ALPHA] || [[laserPiece getActionByTag:ACTION_TAG_FLASH_ALPHA] isDone])) {
                    [laserPiece setVisible:YES];
                    [laserPiece flashAlphaFrom:0 to:255 withTime:0.05 numberOfTimes:1 onSprite:laserPiece];
                }
            }
        }
    }
}

- (void) updateWeapons:(float)delta {
	// loop through weapons and update them
	for(BBWeapon *w in [[BBWeaponManager sharedSingleton] weaponsForType:WEAPON_INVENTORY_MINIBOSS]) {
		[w setPlayerSpeed:[Globals sharedSingleton].playerVelocity.x];
		[w setPosition:dummyPosition];
		[w update:delta];
	}
}

- (void) updatePieces:(float)delta {
    for(BBBossPiece *p in pieces) {
        [p update:delta];
    }
}

#pragma mark -
#pragma mark actions
- (void) reset {
    // stop all the explosions
    [explosionManager stopExploding:self];
    // stop flashing
    [self stopActionByTag:ACTION_TAG_FLASH];
    // reset health
    curHealth = [[SettingsManager sharedSingleton] getFloat:@"bossHealth"];
    
#if DEBUG_OVERRIDE_BOSS_HEALTH
    curHealth = DEBUG_OVERRIDE_BOSS_HEALTH;
#endif
    
    // start out with the boss's mouth closed
    [[self getPieceWithType:@"head"] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"boss1.png"]];
}

- (void) equipTopWeapon {
    NSArray *topWeapons = [[self getAIStage] objectForKey:@"topWeapons"];
    int ran = floor(CCRANDOM_MIN_MAX(0, [topWeapons count]));
    if(ran < [topWeapons count]) {
        [currentTopWeapon setString:[topWeapons objectAtIndex:ran]];
        [[BBWeaponManager sharedSingleton] equip:[topWeapons objectAtIndex:ran] forType:WEAPON_INVENTORY_MINIBOSS];
        [[SettingsManager sharedSingleton] setString:currentTopWeapon keyString:@"bossTopWeapon"];
    }
}

- (void) equipBottomWeapon {
    NSArray *bottomWeapons = [[self getAIStage] objectForKey:@"bottomWeapons"];
    int ran = floor(CCRANDOM_MIN_MAX(0, [bottomWeapons count]));
    if(ran < [bottomWeapons count]) {
        [currentBottomWeapon setString:[bottomWeapons objectAtIndex:ran]];
        [[BBWeaponManager sharedSingleton] equip:[bottomWeapons objectAtIndex:ran] forType:WEAPON_INVENTORY_MINIBOSS];
        [[SettingsManager sharedSingleton] setString:currentBottomWeapon keyString:@"bossBottomWeapon"];
    }
}

- (void) equipFromSave {
    // make sure the weapons exist before equipping them
    if([[SettingsManager sharedSingleton] doesExist:@"bossTopWeapon"]) {
        [currentTopWeapon setString:[[SettingsManager sharedSingleton] getString:@"bossTopWeapon"]];
        [[BBWeaponManager sharedSingleton] equip:currentTopWeapon forType:WEAPON_INVENTORY_MINIBOSS];
    }
    if([[SettingsManager sharedSingleton] doesExist:@"bossBottomWeapon"]) {
        [currentBottomWeapon setString:[[SettingsManager sharedSingleton] getString:@"bossBottomWeapon"]];
        [[BBWeaponManager sharedSingleton] equip:currentBottomWeapon forType:WEAPON_INVENTORY_MINIBOSS];
    }
}

- (void) clearWeapons {
    [[BBWeaponManager sharedSingleton] unequipAllForType:WEAPON_INVENTORY_MINIBOSS];
    [currentBottomWeapon setString:@""];
    [currentTopWeapon setString:@""];
    
    // clear saved weapons
    [[SettingsManager sharedSingleton] clear:@"bossTopWeapon"];
    [[SettingsManager sharedSingleton] clear:@"bossBottomWeapon"];
}

- (void) hitByBullet:(BBBullet*)bullet {
    
    // play hit sound only if it isn't already playing
    if(![hitSound isPlaying]) {
        [hitSound play];
    }
    
    // make sure the boss has health before dealing damage to it
    if(curHealth > 0) {
        curHealth -= bullet.damage;
        
        // update saved boss health
        [[SettingsManager sharedSingleton] setFloat:curHealth keyString:@"bossHealth"];
        
        // if the boss died, turn off all movement and play death animation
        if(curHealth <= 0) {
            // log testflight event
            [TestFlight passCheckpoint:@"killBoss"];
            // clear boss triforce
            [[SettingsManager sharedSingleton] setInteger:0 keyString:@"totalTriforce"];
            [self setState:BOSS_STATE_DEAD];
        }
        else {
            // check to see if miniboss should advance to next ai stage
            NSDictionary *aiStage = [self getAIStage];
            if(curHealth < maxHealth - [[aiStage objectForKey:@"health"] floatValue] * maxHealth) {
                self.currentAIStage++;
            }
            [self flash];
        }
    }
}

- (void) flash {
    for(BBBossPiece *p in pieces) {
        [p flash];
    }
}

- (void) die {
    // set off a ton of explosions
    [explosionManager explodeInObject:self number:20];
    // kill all the boss pieces
    for(BBBossPiece *p in pieces) {
        [p die];
    }
    // clear the weapons out so boss stops shooting
    [self clearWeapons];
    // reset saved info for boss
    [[SettingsManager sharedSingleton] setFloat:maxHealth keyString:@"bossHealth"];
    [[SettingsManager sharedSingleton] setInteger:0 keyString:@"bossStage"];
    // post a notification that the boss has been killed
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventFinalBossDead object:nil]];
    // completely destroy boss after 3 seconds
    CCSequence *completeDestructionAction = [CCSequence actions:[CCDelayTime actionWithDuration:3], [CCCallFunc actionWithTarget:self selector:@selector(finalDie)], nil];
    [self runAction:completeDestructionAction];
}

- (void) finalDie {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavGameWinNotification object:nil]];
}

- (void) fadeInAlpha {
    for(BBBossPiece *p in pieces) {
        [p fadeAlphaFrom:0 to:255 withTime:2 onSprite:p target:nil selector:nil];
    }
    [self fadeAlphaFrom:0 to:255 withTime:2 onSprite:self target:self selector:@selector(fadeInColor)];
}

- (void) fadeInColor {
    for(BBBossPiece *p in pieces) {
        [p fadeFrom:ccc3(0, 0, 0) to:ccc3(255, 255, 255) withTime:2 onSprite:p target:nil selector:nil];
    }
    [self fadeFrom:ccc3(0, 0, 0) to:ccc3(255, 255, 255) withTime:2 onSprite:[self getPieceWithType:@"head"] target:self selector:@selector(gotoBattle)];
}

- (void) gotoBattle {
    [self setState:BOSS_STATE_BATTLE];
}

- (void) pause {
    for(BBBossPiece *p in pieces) {
        [p pause];
    }
    [super pause];
}

- (void) resume {
    for(BBBossPiece *p in pieces) {
        [p resume];
    }
    [super resume];
}

- (void) stopActionByTag:(NSInteger)tag {
    for(BBBossPiece *p in pieces) {
        [p stopActionByTag:tag];
    }
    [super stopActionByTag:tag];
}

@end
