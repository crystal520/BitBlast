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
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// create current funds label
		CCLabelBMFont *coins = [CCLabelBMFont labelWithString:@"$1234567890" fntFile:@"gamefont.fnt"];
		coins.anchorPoint = ccp(1, 1);
		coins.scale = 0.5;
		coins.position = ccp(winSize.width, winSize.height);
		[self addChild:coins];
		
		// create back label
		CCLabelBMFont *backText = [CCLabelBMFont labelWithString:@"X" fntFile:@"gamefont.fnt"];
		
		// create back button
		CCMenuItemLabelAndImage *back = [CCMenuItemLabelAndImage itemFromLabel:backText normalImage:@"backButton.png" selectedImage:@"backButtonDown.png" target:self selector:@selector(back)];
		back.label.scale = 0.5;
		back.position = ccp((-winSize.width + back.contentSize.width) * 0.48, (winSize.height - back.contentSize.height) * 0.48);
		
		// create main menu with options
		CCMenu *menu = [CCMenu menuWithItems:back, nil];
		[self addChild:menu];
		
		// load shop items
		items = [[NSMutableArray alloc] init];
		NSArray *shopList = [NSArray arrayWithArray:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shop" ofType:@"plist"]] objectForKey:@"items"]];
		for(NSString *shopItem in shopList) {
			BBShopItem *t = [[BBShopItem alloc] initWithFile:shopItem];
			[items addObject:t];
			[t release];
		}
		
		// create shop background
		CCSprite *shopBackground = [CCSprite spriteWithFile:@"shopBackground.png"];
		shopBackground.position = ccp(winSize.width * 0.65, winSize.height * 0.42);
		[self addChild:shopBackground];
		
		// create advanced scrolling menu with items
		SWTableView *table = [SWTableView viewWithDataSource:self size:CGSizeMake(320, 250)];
		table.delegate = self;
		table.verticalFillOrder = SWTableViewFillTopDown;
		table.direction = SWScrollViewDirectionVertical;
		table.bounces = NO;
		table.position = ccp(shopBackground.position.x - table.viewSize.width * 0.5, shopBackground.position.y - table.viewSize.height * 0.5);
		table.anchorPoint = ccp(0.5, 0.5);
		[self addChild:table];
		[table reloadData];
		table.contentOffset = [table minContainerOffset];
	}
	
	return self;
}

- (void) back {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavMainNotification object:nil]];
}

#pragma mark -
#pragma mark SWTableViewDataSource
-(CGSize)cellSizeForTable:(SWTableView *)table {
	return CGSizeMake(320, 75);
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
	// get cell as BBShopItem
	BBShopItem *item = (BBShopItem*)(cell);
	[item touch:point];
}

@end
