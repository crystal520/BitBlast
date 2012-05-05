//
//  BBDailyBonus.h
//  GunRunner
//
//  Created by Kristian Bauer on 5/5/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsManager.h"
#import "SessionMWrapper.h"

@interface BBDailyBonus : NSObject

+ (BBDailyBonus*) sharedSingleton;

- (void) checkDailyStreak;
- (void) resetDailyStreakStats;

@end
