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
		
		// load shop items
		items = [[NSMutableArray alloc] init];
		NSArray *shopList = [NSArray arrayWithArray:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shop" ofType:@"plist"]] objectForKey:@"items"]];
		for(NSString *shopItem in shopList) {
			BBShopItem *t = [[BBShopItem alloc] initWithFile:shopItem];
			[items addObject:t];
			[t release];
		}
		
		// create advanced scrolling menu with items
		table = [[SWTableView viewWithDataSource:self size:CGSizeMake(632 * [ResolutionManager sharedSingleton].imageScale, winSize.height)] retain];
		table.delegate = self;
		table.verticalFillOrder = SWTableViewFillTopDown;
		table.direction = SWScrollViewDirectionVertical;
		table.bounces = NO;
		table.position = ccp(winSize.width - table.viewSize.width, 0);
		[self addChild:table];
		[table reloadData];
		table.contentOffset = [table minContainerOffset];
		
		// register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyItem:) name:kNavBuyItemNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelBuyItem) name:kNavCancelBuyItemNotification object:nil];
	}
	
	return self;
}

- (void) dealloc {
	[back release];
	[table release];
	[items release];
	[super dealloc];
}

- (void) back {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavMainNotification object:nil]];
}

- (void) setEnabled:(BOOL)isEnabled {
	[back setEnabled:isEnabled];
	enabled = isEnabled;
	table.isTouchEnabled = isEnabled;
}

- (void) onEnter {
	[super onEnter];
	[self setEnabled:YES];
}

#pragma mark -
#pragma mark notifications
- (void) buyItem:(NSNotification*)n {
	[self setEnabled:YES];
}

- (void) cancelBuyItem {
	[self setEnabled:YES];
}

#pragma mark -
#pragma mark SWTableViewDataSource
-(CGSize)cellSizeForTable:(SWTableView *)table {
	return CGSizeMake(632 * [ResolutionManager sharedSingleton].imageScale, 203 * [ResolutionManager sharedSingleton].imageScale);
}

-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx {
	return [items objectAtIndex:idx];
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
	return [items count];
}

#pragma mark -
#pragma mark SWTableViewDelegate
-(void)table:(SWTableView *)table cellTouched:(SWTableViewCell *)cell withPoint:(CGPoint)point {
	if(enabled) {
		// get cell as BBShopItem
		BBShopItem *item = (BBShopItem*)(cell);
		[item touch:point];
		//[self setEnabled:NO];
	}
}

@end
