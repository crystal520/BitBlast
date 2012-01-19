//
//  Constants.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/26/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	TAG_PLAYER
} SpriteTags;

#define kGameRestartNotification @"gameRestartNotification"

#define kPlayerUpdateNotification @"playerUpdateNotification"
#define kPlayerCollectCoinNotification @"playerCollectCoinNotification"
#define kPlayerEndJumpNotification @"playerEndJumpNotification"
#define kPlayerDamagedNotification @"playerDamagedNotification"
#define kPlayerCollidePlatformNotification @"playerCollidePlatformNotification"
#define kPlayerDeadNotification @"playerDeadNotification"

#define kChunkCompletedNotification @"chunkCompletedNotification"
#define kChunkWillRemoveNotification @"chunkWillRemoveNotification"

#define kNavMainNotification @"navMainNotification"
#define kNavGameNotification @"navGameNotification"
#define kNavShopNotification @"navShopNotification"
#define kNavShopConfirmNotification @"navShopConfirmNotification"
#define kNavLeaderboardsNotification @"navLeaderboardsNotification"
#define kNavGamecenterNotification @"navGamecenterNotification"
#define kNavBuyItemNotification @"navBuyItemNotification"
#define kNavCancelBuyItemNotification @"navCancelBuyItemNotification"