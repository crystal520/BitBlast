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
	
	if((self = [super initWithColor:ccc3(0, 0, 0) withAlpha:0.5f])) {
		
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// generate size of table from cell background image
		CCSprite *cell = [CCSprite spriteWithSpriteFrameName:@"shopshell.png"];
		cellSize = CGSizeMake(cell.contentSize.width, cell.contentSize.height);
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
		// create current funds label
		CCLabelBMFont *coins = [CCLabelBMFont labelWithString:@"$1234567890" fntFile:@"gamefont.fnt"];
		coins.anchorPoint = ccp(1, 1);
		coins.scale = 0.5;
		coins.position = ccp(winSize.width, winSize.height);
		[self addChild:coins];
		
		// create back button holder
		CCSprite *backHolder = [CCSprite spriteWithSpriteFrameName:@"backbuttonshell.png"];
		backHolder.position = ccp(winSize.width * 0.075, winSize.height - backHolder.contentSize.height * 0.5);
		[uiSpriteBatch addChild:backHolder z:0];
		
		// create back button
		back = [[CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton_pressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"backbutton_unpressed.png"] target:self selector:@selector(back)] retain];
		[back setSpriteBatchNode:uiSpriteBatch];
		back.position = ccp(winSize.width * 0.075, winSize.height - back.contentSize.height * 0.5 - backHolder.contentSize.height * 0.175);
		[self addChild:back z:1];
		
		// create layer for all shop items
		shopScroller = [[BBList alloc] init];
		[shopScroller setItemSize:cellSize];
		shopScroller.position = ccp(winSize.width - cellSize.width, winSize.height - cellSize.height);
		[self addChild:shopScroller];
		
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
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmBuy) name:kNavShopConfirmNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyItem) name:kNavBuyItemNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelBuyItem) name:kNavCancelBuyItemNotification object:nil];
	}
	
	return self;
}

- (void) dealloc {
	[shopScroller release];
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
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavMainNotification object:nil]];
}

- (void) setEnabled:(BOOL)isEnabled {
	[back setEnabled:isEnabled];
	enabled = isEnabled;
	if(isEnabled && !shopScroller.isTouchEnabled) {
		[shopScroller onEnter];
	}
	else if(!isEnabled && shopScroller.isTouchEnabled) {
		[shopScroller onExit];
	}
}

- (void) onEnter {
	[super onEnter];
	[self setupIAP];
	[self setEnabled:YES];
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

@end
