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
		
		// create background sprite
		background = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"shopItemBackground.png"] selectedSprite:[CCSprite spriteWithFile:@"shopItemBackgroundDown.png"] target:self selector:@selector(viewItem)];
		background.position = ccp(background.contentSize.width * 0.5, background.contentSize.height * 0.5);
		[self addChild:background];
		
		itemDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
		
		// create icon sprite
		CCSprite *icon = [CCSprite spriteWithFile:[itemDictionary objectForKey:@"icon"]];
		icon.position = ccp(icon.contentSize.width * 0.5, icon.contentSize.height * 0.5);
		[self addChild:icon];
		
		// create name label
		CCLabelBMFont *name = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"name"] fntFile:@"gamefont.fnt"];
		name.scale = 0.4;
		name.anchorPoint = ccp(0, 0.5);
		name.position = ccp(background.contentSize.width * 0.2, background.contentSize.height * 0.65);
		[self addChild:name];
		
		// create description label
		CCLabelBMFont *desc = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"description"] fntFile:@"gamefont.fnt"];
		desc.scale = 0.2;
		desc.anchorPoint = ccp(0, 0.5);
		desc.position = ccp(background.contentSize.width * 0.22, background.contentSize.height * 0.3);
		[self addChild:desc];
		
		// create cost label
		CCLabelBMFont *cost = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"coins"] fntFile:@"gamefont.fnt"];
		cost.scale = 0.4;
		cost.anchorPoint = ccp(1, 0.5);
		cost.position = ccp(background.contentSize.width * 0.97, background.contentSize.height * 0.65);
		[self addChild:cost];
		
		// create buy label
		CCLabelBMFont *buyLabel = [CCLabelBMFont labelWithString:@"BUY" fntFile:@"gamefont.fnt"];
		buyLabel.scale = 0.3;
		
		// create buy button
		buy = [CCMenuItemLabelAndImage itemFromLabel:buyLabel normalImage:@"shopBuyButton.png" selectedImage:@"shopBuyButtonDown.png" target:self selector:@selector(buy)];
		buy.anchorPoint = ccp(1, 0.5);
		buy.position = ccp(background.contentSize.width * 0.97, background.contentSize.height * 0.3);
		[self addChild:buy];
	}
	
	return self;
}

- (void) dealloc {
	[itemDictionary release];
	[super dealloc];
}

- (void) touch:(CGPoint)point {
	if(CGRectContainsPoint(buy.boundingBox, point)) {
		[buy selected];
		[buy performSelector:@selector(unselected) withObject:buy afterDelay:0.1];
		[self buy];
	}
	else {
		[background selected];
		[background performSelector:@selector(unselected) withObject:background afterDelay:0.1];
		[self viewItem];
	}
}

- (void) viewItem {
	NSLog(@"VIEW ITEM");
}

- (void) buy {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavShopConfirmNotification object:nil userInfo:itemDictionary]];
	//[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavShopConfirmNotification object:nil userInfo:itemDictionary]];
}

@end
