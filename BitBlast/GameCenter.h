//
//  GameCenter.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/16/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>

//#define RESET_ACHIEVEMENTS

@interface GameCenter : NSObject <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
    
}

+ (GameCenter*) sharedSingleton;
// setters
- (void) setAchievementProgress:(NSString*)identifier percent:(float)percent;
// getters
+ (BOOL) getIsGameCenterAvailable;
// actions
- (void) authenticateGameCenter;
- (void) resetAchievements;
- (void) checkStatAchievements;
- (void) checkItemAchievements;
- (void) submitLeaderboards;
- (void) submitLeaderboard:(NSString*)name withValue:(int64_t)value;
- (void) gotoLeaderboards;

@end
