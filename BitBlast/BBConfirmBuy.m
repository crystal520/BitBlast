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
		
		// create background
		CCSprite *background = [CCSprite spriteWithFile:@"shopConfirmBackground.png"];
		background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
		[self addChild:background];
		
		// create buy label
		buyLabel = [[CCLabelBMFont alloc] initWithString:@"BUY" fntFile:@"gamefont.fnt"];
		buyLabel.anchorPoint = ccp(0, 0.5);
		buyLabel.scale = 0.5;
		buyLabel.position = ccp(background.contentSize.width * 0.15, background.contentSize.height * 0.65);
		[background addChild:buyLabel];
		
		// create for label
		cost = [[CCLabelBMFont alloc] initWithString:@"FOR" fntFile:@"gamefont.fnt"];
		cost.anchorPoint = ccp(0, 0.5);
		cost.scale = 0.5;
		cost.position = ccp(background.contentSize.width * 0.15, background.contentSize.height * 0.5);
		[background addChild:cost];
		
		// create no thanks label
		CCLabelBMFont *noThanksLabel = [CCLabelBMFont labelWithString:@"NO\nTHANKS" fntFile:@"gamefont.fnt"];
		noThanksLabel.scale = 0.4;
		
		// create no thanks button
		CCMenuItemLabelAndImage *noThanks = [CCMenuItemLabelAndImage itemFromLabel:noThanksLabel normalImage:@"shopConfirmButton.png" selectedImage:@"shopConfirmButtonDown.png" target:self selector:@selector(cancel)];
		noThanks.position = ccp(background.contentSize.width * 0.25, background.contentSize.height * 0.15);
		
		// create buy it label
		CCLabelBMFont *buyItLabel = [CCLabelBMFont labelWithString:@"BUY IT" fntFile:@"gamefont.fnt"];
		buyItLabel.scale = 0.4;
		
		// create buy it button
		buyIt = [[CCMenuItemLabelAndImage alloc] initFromLabel:buyItLabel normalImage:@"shopConfirmButton.png" selectedImage:@"shopConfirmButtonDown.png" disabledImage:@"shopConfirmButtonDown.png" target:self selector:@selector(buy)];
		buyIt.position = ccp(background.contentSize.width * 0.75, background.contentSize.height * 0.15);
		
		// create menu with buttons
		CCMenu *menu = [CCMenu menuWithItems:noThanks, buyIt, nil];
		menu.position = ccp(0, 0);
		[background addChild:menu];
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
	[buyLabel setString:[NSString stringWithFormat:@"BUY  %@", [dict objectForKey:@"name"]]];
	[cost setString:[NSString stringWithFormat:@"FOR  %@", [dict objectForKey:@"cost"]]];
	
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
	// save the item to device
	[[SettingsManager sharedSingleton] setBool:YES keyString:[itemDictionary objectForKey:@"identifier"]];
	// equip based on type
	NSString *type = [itemDictionary objectForKey:@"type"];
	if([type isEqualToString:@"weapon"]) {
		// for now, just have one weapon equipped
		[[BBWeaponManager sharedSingleton] unequipAll];
		[[BBWeaponManager sharedSingleton] equip:[itemDictionary objectForKey:@"identifier"]];
	}
	else if([type isEqualToString:@"equipment"]) {
		[[BBEquipmentManager sharedSingleton] equip:[itemDictionary objectForKey:@"identifier"]];
	}
	else {
		NSLog(@"ERROR: invalid type specified in item plist");
	}
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavBuyItemNotification object:nil userInfo:itemDictionary]];
}

@end
