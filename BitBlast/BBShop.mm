//
//  BBShop.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/14/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBShop.h"


@implementation BBShop

- (id) init {
	
	if((self = [super init])) {
        
        [self addChild:[BBColorRectSprite spriteWithColor:ccc3(0,0,0) alpha:0.5f]];
		
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// generate size of table from cell background image
		CCSprite *cell = [CCSprite spriteWithSpriteFrameName:@"shopshell.png"];
		cellSize = CGSizeMake(cell.contentSize.width, cell.contentSize.height);
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
		// create back button holder
		CCSprite *backHolder = [CCSprite spriteWithSpriteFrameName:@"backbuttonshell.png"];
		backHolder.position = ccp(winSize.width * 0.075, winSize.height - backHolder.contentSize.height * 0.5);
		[uiSpriteBatch addChild:backHolder z:0];
		
		// create back button
		back = [[CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton_pressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton_unpressed.png"] target:self selector:@selector(back)] retain];
		[back setSpriteBatchNode:uiSpriteBatch];
		back.position = ccp(winSize.width * 0.075, winSize.height - back.contentSize.height * 0.5 - backHolder.contentSize.height * 0.175);
		[self addChild:back z:1];
		
		// make player at 2x for shop
		player = [BBPlayer new];
		player.position = ccp(winSize.width * 0.1, winSize.height * 0.1);
		player.dummyPosition = ccpMult(player.position, [ResolutionManager sharedSingleton].inversePositionScale);
		[player setState:kPlayerShop];
		[self addChild:player];
		
		// enable weapons so the player can see the currently equipped weapon being shot
		[[BBWeaponManager sharedSingleton] setEnabled:YES forType:WEAPON_INVENTORY_PLAYER];
		[[BBWeaponManager sharedSingleton] setNode:self forType:WEAPON_INVENTORY_PLAYER];
		// add BulletManager to the shop node
		[[BulletManager sharedSingleton] setNode:self];
		
		// scale up player, bullets, and weapons scale
		[[BulletManager sharedSingleton] setScale:2];
		player.scale = 2;
		[[BBWeaponManager sharedSingleton] setScale:2 forType:WEAPON_INVENTORY_PLAYER];
		
		// create layer for all shop items
		shopScroller = [[BBList alloc] init];
		[shopScroller setItemSize:cellSize];
		shopScroller.dummyPosition = ccpMult(ccp(winSize.width - cellSize.width, winSize.height - cellSize.height), [ResolutionManager sharedSingleton].inversePositionScale);
		[self addChild:shopScroller z:100];
		
		// load shop items
		NSArray *shopList = [NSArray arrayWithArray:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shop" ofType:@"plist"]] objectForKey:@"items"]];
		for(int i=0,j=[shopList count];i<j;i++) {
			// get string from list
			NSString *shopItem = [shopList objectAtIndex:i];
			// create shop item with string
			BBShopItem *t = [[BBShopItem alloc] initWithFile:shopItem];
			[shopScroller addItem:t];
			[t release];
		}
		
		// create current funds label
		coins = [CCLabelBMFont labelWithString:@"$0" fntFile:@"gamefont.fnt"];
		coins.color = ccc3(255, 215, 0);
		coins.anchorPoint = ccp(1, 0);
		coins.scale = 0.75;
		coins.position = ccp(winSize.width - cellSize.width, 0);
		[self addChild:coins];
		
		// schedule update so the player's torso gets updated
		[self scheduleUpdate];
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmBuy) name:kNavShopConfirmNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyItem) name:kNavBuyItemNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelBuyItem) name:kNavCancelBuyItemNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weaponEquipped) name:kPlayerEquipWeaponNotification object:nil];
	}
	
	return self;
}

- (void) dealloc {
	// reset bullets and weapons to normal size
	[[BBWeaponManager sharedSingleton] setScale:1 forType:WEAPON_INVENTORY_PLAYER];
	[[BulletManager sharedSingleton] setScale:1];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[shopScroller release];
	[player release];
	[back release];
	[items release];
	[super dealloc];
}

- (void) setupIAP {
	// make sure items haven't been added already
	if(!iapItemsAdded) {
		// also add IAP items to the list
		NSArray *iapItems = [[IAPManager sharedSingleton] getProducts];
		if(iapItems) {
			for(int i=0,j=[iapItems count];i<j;i++) {
				// create iap item with dictionary
				BBIAPItem *item = [[BBIAPItem alloc] initWithProduct:[iapItems objectAtIndex:i]];
				[shopScroller addItem:item];
				[item release];
			}
			iapItemsAdded = YES;
		}
		else {
			[[IAPManager sharedSingleton] requestIAP];
		}
	}
}

- (void) back {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavMainNotification object:nil]];
}

- (void) setEnabled:(BOOL)isEnabled {
	[back setEnabled:isEnabled];
	[[BBWeaponManager sharedSingleton] setEnabled:isEnabled forType:WEAPON_INVENTORY_PLAYER];
	enabled = isEnabled;
	if(isEnabled && !shopScroller.isTouchEnabled) {
		[shopScroller onEnter];
	}
	else if(!isEnabled && shopScroller.isTouchEnabled) {
		[shopScroller onExit];
	}
	// update current funds
	[[BBWeaponManager sharedSingleton] setNode:self forType:WEAPON_INVENTORY_PLAYER];
	[coins setString:[NSString stringWithFormat:@"$%i", [[SettingsManager sharedSingleton] getInt:@"totalCoins"]]];
}

- (void) onEnter {
	[super onEnter];
	[self setupIAP];
	[self setEnabled:YES];
}

- (void) onExit {
    [super onExit];
    // unequip all weapons and equip the last equipped weapon the player owns
    [[BBWeaponManager sharedSingleton] unequipAllForType:WEAPON_INVENTORY_PLAYER];
    [[BBWeaponManager sharedSingleton] equip:[[SettingsManager sharedSingleton] getString:@"equippedWeapon"] forType:WEAPON_INVENTORY_PLAYER];
}

#pragma mark -
#pragma mark update
- (void) update:(float)delta {
	[player update:delta];
	[[BulletManager sharedSingleton] update:delta];
}

#pragma mark -
#pragma mark notifications
- (void) confirmBuy {
	[self setEnabled:NO];
}

- (void) buyItem {
	[self setEnabled:YES];
}

- (void) cancelBuyItem {
	[self setEnabled:YES];
}

- (void) weaponEquipped {
	// set weapon scale here in case a new weapon was equipped
	[[BBWeaponManager sharedSingleton] setScale:2 forType:WEAPON_INVENTORY_PLAYER];
	[[BulletManager sharedSingleton] setScale:2];
	// enable weapons as they're disabled upon equipping
	[[BBWeaponManager sharedSingleton] setEnabled:YES forType:WEAPON_INVENTORY_PLAYER];
	// make sure particles for new weapon show up on this screen
	[[BBWeaponManager sharedSingleton] setNode:self forType:WEAPON_INVENTORY_PLAYER];
}

@end
