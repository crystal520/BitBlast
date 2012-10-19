//
//  BBDailyBonus.h
//  GunRunner
//
//  Created by Kristian Bauer on 5/5/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionMWrapper.h"

@interface BBDailyBonus : NSObject

+ (BBDailyBonus*) sharedSingleton;

- (void) checkDailyStreak;
- (void) resetDailyStreakStats;

@end
