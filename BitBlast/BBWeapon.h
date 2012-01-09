//
//  BBWeapon.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/7/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"
#import "BulletManager.h"
#import "BBBullet.h"

@interface BBWeapon : BBGameObject {
	// the amount of time between consecutive shoot calls
    float rateOfFire;
	// the number of bullets that appear when the shoot function is called
	float numBulletsToFire;
	// minimum x and y velocity the bullets can have
	CGPoint minVelocity;
	// maximum x and y velocity the bullets can have
	CGPoint maxVelocity;
	// minimum and maximum lifetime each bullet can have
	CGPoint lifetime;
	// angle that weapon is at. this affects velocity of bullets
	float angle;
}

@property (nonatomic) float angle;

- (void) loadFromFile:(NSString*)filename;
- (void) shoot;

@end
