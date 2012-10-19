//
//  BBPowerupManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 5/2/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBPowerupManager : NSObject {
	
}

+ (BBPowerupManager*) sharedSingleton;

// getters
- (int) getHealthPowerup;
- (int) getCoinMultPowerup;
- (int) getGunPowerup;
- (float) getSpeedPowerup;
- (NSArray*) getAllPowerups;

@end
