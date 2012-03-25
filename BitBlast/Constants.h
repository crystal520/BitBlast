//
//  Constants.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/26/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DEPTH_BACKGROUND,
	DEPTH_PARALLAX,
	DEPTH_LEVEL,
	DEPTH_MENU,
	DEPTH_DEBUG
} DepthOrder;

#define kGameRestartNotification @"gameRestartNotification"
#define kLoadLevelNotification @"loadLevelNotification"

#define kPlayerUpdateNotification @"playerUpdateNotification"
#define kPlayerCollectCoinNotification @"playerCollectCoinNotification"
#define kPlayerJumpNotification @"playerJumpNotification"
#define kPlayerEndJumpWithTouchNotification @"playerEndJumpWithTouchNotification"
#define kPlayerEndJumpWithoutTouchNotification @"playerEndJumpWithoutTouchNotification"
#define kPlayerDamagedNotification @"playerDamagedNotification"
#define kPlayerCollidePlatformNotification @"playerCollidePlatformNotification"
#define kPlayerDeadNotification @"playerDeadNotification"
#define kPlayerHealthNotification @"playerHealthNotification"
#define kPlayerLevelIncreaseNotification @"playerLevelIncreaseNotification"
#define kPlayerOutOfChopperNotification @"playerOutOfChopperNotification"

#define kChunkAddedNotification @"chunkAddedNotification"
#define kChunkCompletedNotification @"chunkCompletedNotification"
#define kChunkWillRemoveNotification @"chunkWillRemoveNotification"

#define kEventDropshipDestroyed @"eventDropshipDestroyed"
#define kEventCoinGroupDone @"eventCoinGroupDone"

#define kNavMainNotification @"navMainNotification"
#define kNavGameNotification @"navGameNotification"
#define kNavShopNotification @"navShopNotification"
#define kNavShopConfirmNotification @"navShopConfirmNotification"
#define kNavLeaderboardsNotification @"navLeaderboardsNotification"
#define kNavAchievementsNotification @"navAchievementsNotification"
#define kNavGamecenterNotification @"navGamecenterNotification"
#define kNavBuyItemNotification @"navBuyItemNotification"
#define kNavCancelBuyItemNotification @"navCancelBuyItemNotification"
#define kNavPauseNotification @"navPauseNotification"
#define kNavResumeNotification @"navResumeNotification"