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
		name.scale = 0.8;
		name.anchorPoint = ccp(0, 0.5);
		name.position = ccp(background.contentSize.width * 0.2, background.contentSize.height * 0.8);
		[self addChild:name];
		
		// create description label
		CCLabelBMFont *desc = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"description"] fntFile:@"gamefont.fnt"];
		desc.scale = 0.4;
		desc.anchorPoint = ccp(0, 0.5);
		desc.position = ccp(background.contentSize.width * 0.22, background.contentSize.height * 0.5);
		[self addChild:desc];
		
		// create cost label
		CCLabelBMFont *cost = [CCLabelBMFont labelWithString:[itemDictionary objectForKey:@"coins"] fntFile:@"gamefont.fnt"];
		cost.scale = 0.8;
		cost.anchorPoint = ccp(1, 0.5);
		cost.position = ccp(background.contentSize.width * 0.97, background.contentSize.height * 0.8);
		[self addChild:cost];
		
		// create buy label
		CCLabelBMFont *buyLabel = [CCLabelBMFont labelWithString:@"BUY" fntFile:@"gamefont.fnt"];
		buyLabel.scale = 0.3;
		
		// create buy button
		buy = [CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"buybutton_unpressed.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"buybutton_pressed.png"] target:self selector:@selector(buy)];
		[buy setSpriteBatchNode:uiSpriteBatch];
		buy.position = ccp(background.contentSize.width * 0.9, background.contentSize.height * 0.45);
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
		[self buy];
	}
	else {
		[self viewItem];
	}
}

- (void) viewItem {
	NSLog(@"VIEW ITEM");
}

- (void) buy {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavShopConfirmNotification object:nil userInfo:itemDictionary]];
}

- (CGSize) contentSize {
	return CGSizeMake(background.contentSize.width * [ResolutionManager sharedSingleton].imageScale, background.contentSize.height * [ResolutionManager sharedSingleton].imageScale);
}

@end
