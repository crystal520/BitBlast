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
	DEPTH_DEBUG,
	DEPTH_GAME_LEVEL,
	DEPTH_GAME_INTRO_CHOPPER,
	DEPTH_GAME_PLAYER,
	DEPTH_GAME_BULLETS,
	DEPTH_GAME_COINS,
	DEPTH_GAME_DROPSHIPS,
	DEPTH_GAME_ENEMIES,
	DEPTH_MENU_POPUP
} DepthOrder;

typedef enum {
	TOUCH_DEPTH_LIST,
	TOUCH_DEPTH_BUTTON,
	TOUCH_DEPTH_GAME,
	TOUCH_DEPTH_POPUP
} TouchOrder;

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
#define kPlayerEquipWeaponNotification @"playerEquipWeaponNotification"

#define kChunkAddedNotification @"chunkAddedNotification"
#define kChunkCompletedNotification @"chunkCompletedNotification"
#define kChunkWillRemoveNotification @"chunkWillRemoveNotification"

#define kEventDropshipDestroyed @"eventDropshipDestroyed"
#define kEventCoinGroupDone @"eventCoinGroupDone"
#define kEventNewGame @"eventNewGame"
#define kEventDropshipsDestroyed @"eventDropshipsDestroyed"
#define kEventPromoCoinsAwarded @"eventPromoCoinsAwarded"

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