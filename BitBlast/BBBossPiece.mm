//
//  BBBossPiece.m
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBBossPiece.h"

@implementation BBBossPiece

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
        
        // set piece's position
        dummyPosition = ccpAdd(CGPointFromString([initDict objectForKey:@"position"]), ccp([self displayedFrame].rect.size.width * self.anchorPoint.x, [self displayedFrame].rect.size.height * self.anchorPoint.y));
        self.position = ccpMult(dummyPosition, [ResolutionManager sharedSingleton].positionScale);
    }
    
    return self;
}

@end
