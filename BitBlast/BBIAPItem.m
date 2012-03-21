//
//  BBIAPItem.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/18/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBIAPItem.h"


@implementation BBIAPItem

- (id) initWithProduct:(SKProduct*)product {
	
	if((self = [super init])) {
		
		// create spritebatch with UI image
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[self addChild:uiSpriteBatch];
		
		// create background sprite
		background = [CCButton buttonFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"shopshell.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopshell.png"] target:self selector:@selector(viewItem)];
		[background setSpriteBatchNode:uiSpriteBatch];
		background.position = ccp(background.contentSize.width * 0.5, background.contentSize.height * 0.5);
		[self addChild:background];
		
		// create icon sprite
		/*CCSprite *icon = [CCSprite spriteWithFile:[dictionary objectForKey:@"icon"]];
		icon.position = ccp(background.contentSize.width * 0.1, background.contentSize.height * 0.65);
		[self addChild:icon];*/
		
		// create name label
		CCLabelBMFont *name = [CCLabelBMFont labelWithString:product.localizedTitle fntFile:@"gamefont.fnt"];
		name.scale = 0.8;
		name.anchorPoint = ccp(0, 0.5);
		name.position = ccp(background.contentSize.width * 0.19, background.contentSize.height * 0.8);
		[self addChild:name];
		
		// create description label
		CCLabelBMFont *desc = [CCLabelBMFont labelWithString:product.localizedDescription fntFile:@"gamefont.fnt"];
		desc.scale = 0.4;
		desc.anchorPoint = ccp(0, 0.5);
		desc.position = ccp(background.contentSize.width * 0.19, background.contentSize.height * 0.5);
		[self addChild:desc];
		
		// create cost label
		CCLabelBMFont *cost = [CCLabelBMFont labelWithString:[product.price descriptionWithLocale:product.priceLocale] fntFile:@"gamefont.fnt"];
		cost.scale = 0.8;
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
		
		// keep track of the product ID
		productID = [product.productIdentifier retain];
	}
	
	return self;
}

- (void) dealloc {
	[productID release];
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
	[[IAPManager sharedSingleton] startTransaction:productID];
}

- (CGSize) contentSize {
	return CGSizeMake(background.contentSize.width * [ResolutionManager sharedSingleton].imageScale, background.contentSize.height * [ResolutionManager sharedSingleton].imageScale);
}

@end
