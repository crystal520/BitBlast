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
		name.scale = 0.5;
		name.anchorPoint = ccp(0, 0.5);
		name.position = ccp(background.contentSize.width * 0.19, background.contentSize.height * 0.8);
		[self addChild:name];
		
		// create description label
		CCLabelBMFont *desc = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"description"] fntFile:@"gamefont.fnt"];
		desc.scale = 0.3;
		desc.anchorPoint = ccp(0, 0.35);
		desc.position = ccp(background.contentSize.width * 0.19, background.contentSize.height * 0.5);
		[self addChild:desc];
		
		// create cost label
		cost = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"cost"] fntFile:@"gamefont.fnt"];
		cost.scale = 0.6;
		cost.anchorPoint = ccp(1, 0.5);
		cost.position = ccp(background.contentSize.width * 0.97, background.contentSize.height * 0.8);
		[self addChild:cost];
		
		// create buy label
		CCLabelBMFont *buyLabel;
		// set text to equip if player owns the weapon
		if([[SettingsManager sharedSingleton] getBool:filename]) {
			buyLabel = [CCLabelBMFont labelWithString:@"EQUIP" fntFile:@"gamefont.fnt"];
			buyLabel.scale = 0.4;
            cost.visible = NO;
		}
		else if([[itemDictionary objectForKey:@"previewAvailable"] boolValue]) {
			buyLabel = [CCLabelBMFont labelWithString:@"PREVIEW" fntFile:@"gamefont.fnt"];
			buyLabel.scale = 0.3;
		}
        else {
            buyLabel = [CCLabelBMFont labelWithString:@"BUY" fntFile:@"gamefont.fnt"];
			buyLabel.scale = 0.4;
        }
		
		// create buy button
		buy = [CCLabelButton buttonWithLabel:buyLabel normalSprite:[CCSprite spriteWithSpriteFrameName:@"buybutton_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"buybutton_pressed.png"] target:self selector:@selector(buy)];
		[buy setSpriteBatchNode:uiSpriteBatch];
		buy.position = ccp(background.contentSize.width * 0.865, background.contentSize.height * 0.435);
		[self addChild:buy];
        
        // listen for notifications so we know if the item was purchased
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemPurchased:) name:kNavBuyItemNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemPreviewed) name:kEventPreviewWeapon object:nil];
	}
	
	return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventPreviewWeapon object:nil]];
		[self equipItem];
	}
    // see if player is previewing it
    else if([[buy.label string] isEqualToString:@"PREVIEW"]) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventPreviewWeapon object:nil]];
        [buy setString:@"BUY"];
        [self equipItem];
    }
	// otherwise try to buy it
	else {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavShopConfirmNotification object:nil userInfo:itemDictionary]];
	}
}

- (CGSize) contentSize {
	return CGSizeMake(background.contentSize.width * [ResolutionManager sharedSingleton].imageScale, background.contentSize.height * [ResolutionManager sharedSingleton].imageScale);
}

- (void) itemPurchased:(NSNotification*)n {
    NSDictionary *itemDict = [n userInfo];
    if([[itemDict objectForKey:@"identifier"] isEqualToString:[itemDictionary objectForKey:@"identifier"]]) {
        cost.visible = NO;
        CCLabelBMFont *buyLabel = [CCLabelBMFont labelWithString:@"EQUIP" fntFile:@"gamefont.fnt"];
        buyLabel.scale = 0.4;
        [buy setLabel:buyLabel];
    }
}

- (void) itemPreviewed {
    // if player doesn't own this item, set label from BUY to PREVIEW
    if(![[SettingsManager sharedSingleton] getBool:[itemDictionary objectForKey:@"identifier"]] && [[itemDictionary objectForKey:@"previewAvailable"] boolValue]) {
        [buy setString:@"PREVIEW"];
    }
}

- (void) equipItem {
    // equip based on type
    NSString *type = [itemDictionary objectForKey:@"type"];
    if([type isEqualToString:@"weapon"]) {
        // for now, just have one weapon equipped
        [[BBWeaponManager sharedSingleton] unequipAllForType:WEAPON_INVENTORY_PLAYER];
        [[BBWeaponManager sharedSingleton] equip:[itemDictionary objectForKey:@"identifier"] forType:WEAPON_INVENTORY_PLAYER];
    }
    else if([type isEqualToString:@"equipment"]) {
        [[BBEquipmentManager sharedSingleton] equip:[itemDictionary objectForKey:@"identifier"]];
    }
}

@end
