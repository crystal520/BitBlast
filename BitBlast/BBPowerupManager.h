//
//  BBPowerupManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 5/2/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsManager.h"

@interface BBPowerupManager : NSObject {
	
}

+ (BBPowerupManager*) sharedSingleton;

// getters
- (int) getHealthPowerup;
- (int) getCoinMultPowerup;

@end
