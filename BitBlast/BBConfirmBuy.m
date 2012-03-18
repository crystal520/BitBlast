//
//  BBConfirmBuy.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBConfirmBuy.h"


@implementation BBConfirmBuy

- (id) init {
	
	if((self = [super initWithColor:ccc3(0, 0, 0) withAlpha:0.5f])) {
		
		itemDictionary = [NSMutableDictionary new];
		
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
		// create background
		CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"shopConfirmBackground.png"];
		background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
		[uiSpriteBatch addChild:background];
		
		// create buy label
		buyLabel = [[CCLabelBMFont alloc] initWithString:@"BUY" fntFile:@"gamefont.fnt"];
		buyLabel.anchorPoint = ccp(0, 0.5);
		buyLabel.position = ccp(winSize.width * 0.2, winSize.height * 0.65);
		buyLabel.scale = 0.85;
		[self addChild:buyLabel];
		
		// create for label
		cost = [[CCLabelBMFont alloc] initWithString:@"FOR" fntFile:@"gamefont.fnt"];
		cost.anchorPoint = ccp(0, 0.5);
		cost.position = ccp(winSize.width * 0.2, winSize.height * 0.5);
		cost.scale = 0.85;
		[self addChild:cost];
		
		// create no thanks label
		CCLabelBMFont *noThanksLabel = [CCLabelBMFont labelWithString:@"CANCEL" fntFile:@"gamefont.fnt"];
		noThanksLabel.scale = 0.8;
		
		// create no thanks button
		CCLabelButton *noThanks = [[CCLabelButton alloc] initWithLabel:noThanksLabel normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] disabledSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(cancel)];
		noThanks.position = ccp(winSize.width * 0.35, winSize.height * 0.317);
		[noThanks setSpriteBatchNode:uiSpriteBatch];
		[self addChild:noThanks];
		
		// create buy it label
		CCLabelBMFont *buyItLabel = [CCLabelBMFont labelWithString:@"BUY IT" fntFile:@"gamefont.fnt"];
		buyItLabel.scale = 0.8;
		
		// create buy it button
		buyIt = [[CCLabelButton alloc] initWithLabel:buyItLabel normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] disabledSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(buy)];
		buyIt.position = ccp(winSize.width * 0.65, winSize.height * 0.317);
		[buyIt setSpriteBatchNode:uiSpriteBatch];
		[self addChild:buyIt];
	}
	
	return self;
}

- (void) dealloc {
	[buyLabel release];
	[cost release];
	[itemDictionary release];
	[super dealloc];
}

- (void) updateWithInfo:(NSDictionary*)dict {
	[itemDictionary setDictionary:dict];
	[buyLabel setString:[NSString stringWithFormat:@"BUY:  %@", [dict objectForKey:@"name"]]];
	[cost setString:[NSString stringWithFormat:@"FOR:  %@", [dict objectForKey:@"cost"]]];
	
	// only show buy button if player is able to buy item
	if([[SettingsManager sharedSingleton] getInt:@"totalCoins"] < [[itemDictionary objectForKey:@"cost"] intValue]) {
		[buyIt setVisible:NO];
	}
	else {
		[buyIt setVisible:YES];
	}
}

- (void) cancel {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavCancelBuyItemNotification object:nil]];
}

- (void) buy {
	// subtract funds from total funds
	[[SettingsManager sharedSingleton] incrementInteger:-[[itemDictionary objectForKey:@"cost"] intValue] keyString:@"totalCoins"];
	// equip based on type
	NSString *type = [itemDictionary objectForKey:@"type"];
	NSString *identifier = [itemDictionary objectForKey:@"identifier"];
	
	if([type isEqualToString:@"weapon"]) {
		// for now, just have one weapon equipped
		[[BBWeaponManager sharedSingleton] unequipAll];
		[[BBWeaponManager sharedSingleton] equip:identifier];
	}
	else if([type isEqualToString:@"equipment"]) {
		[[BBEquipmentManager sharedSingleton] equip:identifier];
	}
	else {
		NSLog(@"ERROR: invalid type specified in item plist");
	}
	
	// check for item specific achievements
	[[GameCenter sharedSingleton] checkItemAchievements];
	// navigate back to shop
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavBuyItemNotification object:nil userInfo:itemDictionary]];
}

@end
