//
//  BBBossPiece.m
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBBossPiece.h"
#import "BBBoss.h"

@implementation BBBossPiece

@synthesize enabled, type;

- (id) initWithDictionary:(NSDictionary *)initDict {
    if((self = [super init])) {
        type = [[initDict objectForKey:@"type"] retain];
        
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
        dummyPosition = ccpAdd(ccpMult(CGPointFromString([initDict objectForKey:@"position"]), [ResolutionManager sharedSingleton].positionScale), ccp([self displayedFrame].rect.size.width * self.anchorPoint.x, [self displayedFrame].rect.size.height * self.anchorPoint.y));
        self.position = dummyPosition;
    }
    
    return self;
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
    lastBulletHit = nil;
}

#pragma mark -
#pragma mark setters
- (void) setEnabled:(BOOL)newEnabled {
    [collisionShape setActive:newEnabled];
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
        
        [(BBBoss*)(self.parent) hitByBullet:bullet];
        
        // only disable if the bullet is a shot (lasers go through everything!)
        if(bullet.type == kBulletTypeShot) {
            [bullet setEnabled:NO];
        }
        // keep track of the last bullet that hit this dropship (for laser penetration)
        lastBulletHit = bullet;
    }
}

- (void) flash {
    if([[self getActionByTag:ACTION_TAG_FLASH] isDone] || ![self getActionByTag:ACTION_TAG_FLASH]) {
        [self flashFrom:ccc3(255, 255, 255) to:ccc3(255, 0, 0) withTime:0.1 numberOfTimes:1 onSprite:self];
    }
}

- (void) die {
    // stop flashing and revert to original color
    [self stopActionByTag:ACTION_TAG_FLASH];
    [self setColor:ccc3(255, 255, 255)];
    // start flashing on repeat because boss is dead
    [self flashFrom:ccc3(255, 255, 255) to:ccc3(255, 0, 0) withTime:0.1 numberOfTimes:0 onSprite:self];
}

@end

@implementation BBBossPieceShape

- (void) postsolveContactWithBBBulletShape:(GB2Contact*)contact {
    contact.box2dContact->SetEnabled(NO);
    [(BBBossPiece*)(self.ccNode) hitByBullet:(BBBullet*)(contact.otherObject.ccNode) withContact:contact];
}

@end
