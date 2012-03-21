//
//  BBShopItem.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBShopItem.h"


@implementation BBShopItem

- (id) initWithFile:(NSString *)filename {
	
	if((self = [super init])) {
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
		// create background sprite
		background = [CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"shopshell.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopshell.png"] target:self selector:@selector(viewItem)];
		[background setSpriteBatchNode:uiSpriteBatch];
		background.position = ccp(background.contentSize.width * 0.5, background.contentSize.height * 0.5);
		[self addChild:background];
		
		itemDictionary = [[NSDictionary alloc] initWithDictionary:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]] objectForKey:@"shop"]];
		
		// create icon sprite
		CCSprite *icon = [CCSprite spriteWithFile:[itemDictionary objectForKey:@"icon"]];
		icon.position = ccp(background.contentSize.width * 0.1, background.contentSize.height * 0.65);
		[self addChild:icon];
		
		// create name label
		CCLabelBMFont *name = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"name"] fntFile:@"gamefont.fnt"];
		name.scale = 0.6;
		name.anchorPoint = ccp(0, 0.5);
		name.position = ccp(background.contentSize.width * 0.19, background.contentSize.height * 0.8);
		[self addChild:name];
		
		// create description label
		CCLabelBMFont *desc = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"description"] fntFile:@"gamefont.fnt"];
		desc.scale = 0.35;
		desc.anchorPoint = ccp(0, 0.5);
		desc.position = ccp(background.contentSize.width * 0.19, background.contentSize.height * 0.5);
		[self addChild:desc];
		
		// create cost label
		CCLabelBMFont *cost = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"cost"] fntFile:@"gamefont.fnt"];
		cost.scale = 0.7;
		cost.anchorPoint = ccp(1, 0.5);
		cost.position = ccp(background.contentSize.width * 0.97, background.contentSize.height * 0.8);
		[self addChild:cost];
		
		// create buy label
		CCLabelBMFont *buyLabel = [CCLabelBMFont labelWithString:@"BUY" fntFile:@"gamefont.fnt"];
		buyLabel.scale = 0.45;
		
		// create buy button
		buy = [CCLabelButton buttonWithLabel:buyLabel normalSprite:[CCSprite spriteWithSpriteFrameName:@"buybutton_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"buybutton_pressed.png"] target:self selector:@selector(buy)];
		[buy setSpriteBatchNode:uiSpriteBatch];
		buy.position = ccp(background.contentSize.width * 0.865, background.contentSize.height * 0.435);
		[self addChild:buy];
	}
	
	return self;
}

- (void) dealloc {
	[itemDictionary release];
	[super dealloc];
}

- (void) touch {
	[self buy];
}

- (void) viewItem {
	NSLog(@"VIEW ITEM");
}

- (void) buy {
	[[SimpleAudioEngine sharedEngine] playEffect:@"select.wav"];
	// if player already owns item, just equip it
	if([[SettingsManager sharedSingleton] getBool:[itemDictionary objectForKey:@"identifier"]]) {
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
	}
	// otherwise try to buy it
	else {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavShopConfirmNotification object:nil userInfo:itemDictionary]];
	}
}

- (CGSize) contentSize {
	return CGSizeMake(background.contentSize.width * [ResolutionManager sharedSingleton].imageScale, background.contentSize.height * [ResolutionManager sharedSingleton].imageScale);
}

@end
