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

typedef enum {
    LEADERBOARD_PLAYER_SCOPE_GLOBAL,
    LEADERBOARD_PLAYER_SCOPE_FRIENDS
} LeaderboardPlayerScope;

typedef enum {
    LEADERBOARD_TIME_SCOPE_TODAY,
    LEADERBOARD_TIME_SCOPE_WEEK,
    LEADERBOARD_TIME_SCOPE_ALLTIME
} LeaderboardTimeScope;

//#define RESET_ACHIEVEMENTS

@interface GameCenter : NSObject <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
    NSMutableArray *friends;
}

@property (nonatomic, readonly) NSMutableArray *friends;

+ (GameCenter*) sharedSingleton;
// setters
- (void) setAchievementProgress:(NSString*)identifier percent:(float)percent;
// getters
+ (BOOL) getIsGameCenterAvailable;
// actions
- (void) authenticateGameCenter;
- (void) resetAchievements;
- (void) loadFriends;
- (void) checkStatAchievements;
- (void) checkItemAchievements;
- (void) submitLeaderboards;
- (void) submitLeaderboard:(NSString*)name withValue:(int64_t)value;
- (void) gotoLeaderboards;

@end
