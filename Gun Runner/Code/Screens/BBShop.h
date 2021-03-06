//
//  BBShop.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/14/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBColorRectSprite.h"
#import "BBShopItem.h"
#import "CCLabelButton.h"
#import "BBList.h"
#import "IAPManager.h"
#import "BBIAPItem.h"
#import "SimpleAudioEngine.h"
#import "BBPlayer.h"

@interface BBShop : CCNode {
	// size of each cell in the table of items
	CGSize cellSize;
	// array of items in the store
    NSMutableArray *items;
	// back button stored here so it can be disabled when going to confirm buy screen
	CCLabelButton *back;
	// table to contain list of scrolling items
	BBList *shopScroller;
	// whether the screen is enabled or disabled
	BOOL enabled;
	// whether the IAP items have been added to the shop list
	BOOL iapItemsAdded;
	// current funds the player has
	CCLabelBMFont *coins;
	// large player running next to shop
	BBPlayer *player;
}

- (void) setupIAP;
- (void) setEnabled:(BOOL)isEnabled;

@end
