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
	DEPTH_GAME_COINS,
    DEPTH_GAME_DROPSHIPS,
    DEPTH_GAME_MINIBOSSES,
	DEPTH_GAME_ENEMIES,
    DEPTH_GAME_BOSS,
	DEPTH_GAME_BULLETS,
	DEPTH_GAME_MOVING_COINS,
	DEPTH_GAME_DROPSHIPS_INTRO,
    DEPTH_GAME_MINIBOSSES_INTRO,
    DEPTH_GAME_BOSS_INTRO,
    DEPTH_GAME_PLAYER_BOSS_INTRO,
	DEPTH_MENU_POPUP
} DepthOrder;

typedef enum {
	TOUCH_DEPTH_LIST,
	TOUCH_DEPTH_BUTTON,
    TOUCH_DEPTH_MENU,
	TOUCH_DEPTH_GAME,
	TOUCH_DEPTH_POPUP
} TouchOrder;

typedef enum {
    kDeathUnknown,
    kDeathEnemy,
    kDeathMiniboss,
    kDeathFall
} ReasonForDeath;

typedef enum {
	kStateUnknown,
	kStateMainMenu,
	kStateGameOver,
	kStateIntro,
	kStateGame,
	kStateShop,
	kStateConfirmBuy,
	kStateLeaderboards,
	kStatePause,
    kStateGameWin,
    kStateMedals
} GameState;

typedef enum {
    WEAPON_TYPE_UNKNOWN,
    WEAPON_TYPE_PLAYER,
    WEAPON_TYPE_ENEMY
} WeaponType;

typedef enum {
    WEAPON_INVENTORY_PLAYER,
    WEAPON_INVENTORY_MINIBOSS,
    WEAPON_INVENTORY_COUNT
} WeaponInventory;

typedef enum {
    ACTION_TAG_SCREEN_SHAKE = 1,
    ACTION_TAG_ANIMATION,
    ACTION_TAG_FLASH,
    ACTION_TAG_FLASH_ALPHA,
    ACTION_TAG_FADE,
    ACTION_TAG_FADE_ALPHA,
    MINIBOSS_ACTION_TAG_HIT,
    MINIBOSS_ACTION_TAG_HOVER,
    MINIBOSS_ACTION_TAG_CHASE,
    MINIBOSS_ACTION_TAG_CALL_SPAWN_ENEMY,
    MINIBOSS_ACTION_TAG_CALL_CHANGE_WEAPON,
    MINIBOSS_ACTION_TAG_CALL_CHASE,
    MINIBOSS_ACTION_TAG_CALL_CHARGE,
    MINIBOSS_ACTION_TAG_CALL_SHOW_HEALTH,
    ACTION_TAG_TYPE
} ActionTag;

typedef enum {
    SPRITE_TAG_BACKGROUND = 1,
    SPRITE_TAG_MENU,
    SPRITE_TAG_OVERLAY,
	SPRITE_TAG_POPUP,
    SPRITE_TAG_BOSS_OVERLAY
} SpriteTag;

typedef enum {
    TUTORIAL_STATE_START = 0,
    TUTORIAL_STATE_JUMP_UP = TUTORIAL_STATE_START,
    TUTORIAL_STATE_POST_JUMP_UP,
    TUTORIAL_STATE_DOUBLE_JUMP,
    TUTORIAL_STATE_JUMP_DOWN,
    TUTORIAL_STATE_POST_JUMP_DOWN,
    TUTORIAL_STATE_DROPSHIP,
    TUTORIAL_STATE_FINISH
} TutorialState;

#define TESTING 1

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
#define kPlayerKeyNotification @"playerKeyNotification"
#define kPlayerTriforceNotification @"playerTriforceNotification"

#define kChunkAddedNotification @"chunkAddedNotification"
#define kChunkCompletedNotification @"chunkCompletedNotification"
#define kChunkWillRemoveNotification @"chunkWillRemoveNotification"

#define kEventDropshipDestroyed @"eventDropshipDestroyed"
#define kEventNewGame @"eventNewGame"
#define kEventPromoCoinsAwarded @"eventPromoCoinsAwarded"
#define kEventSessionMUserInfoUpdated @"eventSessionMUserInfoUpdated"
#define kEventPreviewWeapon @"eventPreviewWeapon"
#define kEventSpawnFinalBoss @"eventSpawnFinalBoss"
#define kEventFinalBossDead @"eventFinalBossDead"
#define kEventGameWin @"eventGameWin"

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
#define kNavGameWinNotification @"navGameWinNotification"
#define kNavMedalsNotification @"navMedalsNotification"
