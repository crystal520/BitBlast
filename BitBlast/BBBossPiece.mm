//
//  BBBossPiece.m
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBBossPiece.h"

@implementation BBBossPiece

@synthesize explosionManager, enabled;

- (id) initWithDictionary:(NSDictionary *)initDict {
    if((self = [super init])) {
        coins = [[initDict objectForKey:@"coins"] intValue];
        type = [[initDict objectForKey:@"type"] retain];
        
        // check for health (laser flash can't take damage)
        if([initDict objectForKey:@"health"]) {
            curHealth = [[initDict objectForKey:@"health"] floatValue];
        }
        else {
            curHealth = -1;
        }
        maxHealth = curHealth;
        
        // either set the display frame or play an animation
        if([initDict objectForKey:@"image"]) {
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[initDict objectForKey:@"image"]]];
        }
        else {
            [self repeatAnimation:[initDict objectForKey:@"animation"]];
        }
        
        // check for anchor point
        if([initDict objectForKey:@"anchor"]) {
            self.anchorPoint = CGPointFromString([initDict objectForKey:@"anchor"]);
        }
        
        // check for collision shape (if there is one)
        if([initDict objectForKey:@"collisionShape"]) {
            [self setCollisionShape:[initDict objectForKey:@"collisionShape"]];
        }
        
        // check for particle system
        if(particles) {
            [particles release];
            particles = nil;
        }
        if([dictionary objectForKey:@"particles"]) {
            particles = [[dictionary objectForKey:@"particles"] retain];
        }
        
        // set piece's position
        dummyPosition = ccpAdd(CGPointFromString([initDict objectForKey:@"position"]), ccp([self displayedFrame].rect.size.width * self.anchorPoint.x, [self displayedFrame].rect.size.height * self.anchorPoint.y));
        self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
    }
    
    return self;
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
    self.visible = YES;
    [collisionShape setActive:newEnabled];
    if(newEnabled && !enabled) {
        alive = YES;
    }
    else if(enabled && !newEnabled) {
        alive = NO;
    }
    enabled = newEnabled;
}

- (void) setCollisionShape:(NSString *)shapeName {
    if(collisionShape) {
        if(![collisionShape.shapeString isEqualToString:shapeName]) {
            [collisionShape destroyBody];
            [collisionShape release];
            collisionShape = [[BBBossPieceShape alloc] initWithDynamicBody:shapeName node:self];
            [collisionShape setActive:NO];
        }
    }
    else {
        collisionShape = [[BBBossPieceShape alloc] initWithDynamicBody:shapeName node:self];
        [collisionShape setActive:NO];
    }
}

#pragma mark -
#pragma mark actions
- (void) hitByBullet:(BBBullet*)bullet withContact:(GB2Contact*)contact {
    if(bullet.enabled && bullet != lastBulletHit) {
        
        // play particles where piece was hit
        if(particles) {
            CCParticleSystemQuad *hitParticles = [CCParticleSystemQuad particleWithFile:particles];
            hitParticles.autoRemoveOnFinish = YES;
            
            if(bullet.type == kBulletTypeLaser) {
                [self addChild:hitParticles];
                hitParticles.position = ccp(CCRANDOM_MIN_MAX(0, self.contentSize.width), CCRANDOM_MIN_MAX(0, self.contentSize.height));
            }
            else {
                [self.parent addChild:hitParticles];
                hitParticles.position = bullet.position;
            }
        }
        
        if(![hitSound isPlaying]) {
            [hitSound play];
        }
        
        if(curHealth > 0) {
            curHealth -= bullet.damage;
            // if the dropship died, turn off all movement and play death animation
            if(curHealth <= 0) {
                //[self stopActionByTag:DROPSHIP_ACTION_TAG_HOVER];
                [self stopActionByTag:ACTION_TAG_FLASH];
                [self setColor:ccc3(255, 255, 255)];
                //[self die];
                //[explosionManager explodeInObject:self number:5];
            }
            else if([[self getActionByTag:ACTION_TAG_FLASH] isDone] || ![self getActionByTag:ACTION_TAG_FLASH]) {
                [self flashFrom:ccc3(255, 255, 255) to:ccc3(255, 0, 0) withTime:0.1 numberOfTimes:1 onSprite:self];
            }
        }
        // only disable if the bullet is a shot (lasers go through everything!)
        if(bullet.type == kBulletTypeShot) {
            [bullet setEnabled:NO];
        }
        // keep track of the last bullet that hit this dropship (for laser penetration)
        lastBulletHit = bullet;
    }
}

@end

@implementation BBBossPieceShape

- (void) postsolveContactWithBBBulletShape:(GB2Contact*)contact {
    contact.box2dContact->SetEnabled(NO);
    [(BBBossPiece*)(self.ccNode) hitByBullet:(BBBullet*)(contact.otherObject.ccNode) withContact:contact];
}

@end
