//
//  BBLeaderboards.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBLeaderboards.h"


@implementation BBLeaderboards

- (id) init {
	
	if((self = [super initWithColor:ccc3(0, 0, 0) withAlpha:0.5f])) {
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		scores = [[NSArray alloc] initWithArray:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"leaderboards" ofType:@"plist"]] objectForKey:@"scores"]];
		
		// create back label
		CCLabelBMFont *backText = [CCLabelBMFont labelWithString:@"X" fntFile:@"gamefont.fnt"];
		
		// create back button
		CCMenuItemLabelAndImage *back = [CCMenuItemLabelAndImage itemFromLabel:backText normalImage:@"backButton.png" selectedImage:@"backButtonDown.png" target:self selector:@selector(back)];
		back.label.scale = 0.5;
		back.position = ccp((-winSize.width + back.contentSize.width) * 0.48, (winSize.height - back.contentSize.height) * 0.48);
		
		// create main menu with options
		CCMenu *menu = [CCMenu menuWithItems:back, nil];
		[self addChild:menu];
		
		// create background
		CCSprite *background = [CCSprite spriteWithFile:@"leaderboardBackground.png"];
		background.position = ccp(winSize.width * 0.52, winSize.height * 0.45);
		[self addChild:background];
		
		// create advanced scrolling menu with items
		SWTableView *table = [[SWTableView viewWithDataSource:self size:CGSizeMake(414, 241)] retain];
		table.verticalFillOrder = SWTableViewFillTopDown;
		table.direction = SWScrollViewDirectionVertical;
		table.bounces = NO;
		table.position = ccp(background.position.x - table.viewSize.width * 0.5, background.position.y - table.viewSize.height * 0.5);
		table.anchorPoint = ccp(0.5, 0.5);
		[self addChild:table];
		[table reloadData];
		table.contentOffset = [table minContainerOffset];
	}
	
	return self;
}

- (void) dealloc {
	[scores release];
	[super dealloc];
}

- (void) back {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNavMainNotification object:nil]];
}

#pragma mark -
#pragma mark SWTableViewDataSource
-(CGSize)cellSizeForTable:(SWTableView *)table {
	return CGSizeMake(414, 41);
}

-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx {
	return [[BBLeaderboardEntry alloc] initWithDictionary:[scores objectAtIndex:idx] index:(idx+1)];
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
	return [scores count];
}

@end
