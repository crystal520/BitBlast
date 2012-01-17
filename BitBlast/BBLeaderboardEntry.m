//
//  BBLeaderboardEntry.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBLeaderboardEntry.h"


@implementation BBLeaderboardEntry

- (id) initWithDictionary:(NSDictionary*)dict index:(int)idx {
	
	if((self = [super init])) {
		
		// create background
		CCSprite *background = [CCSprite spriteWithFile:@"leaderboardEntryBackground.png"];
		background.position = ccp(background.contentSize.width * 0.5, background.contentSize.height * 0.5);
		[self addChild:background];
		
		// create number label
		CCLabelBMFont *number = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i.", idx] fntFile:@"gamefont.fnt"];
		number.scale = 0.4;
		number.anchorPoint = ccp(1, 0.5);
		number.position = ccp(background.contentSize.width * 0.1, background.contentSize.height * 0.5);
		[self addChild:number];
		
		// create name label
		CCLabelBMFont *name = [CCLabelBMFont labelWithString:[dict objectForKey:@"name"] fntFile:@"gamefont.fnt"];
		name.scale = 0.4;
		name.anchorPoint = ccp(0, 0.5);
		name.position = ccp(background.contentSize.width * 0.15, background.contentSize.height * 0.5);
		[self addChild:name];
		
		// create score label
		CCLabelBMFont *score = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [[dict objectForKey:@"score"] intValue]] fntFile:@"gamefont.fnt"];
		score.scale = 0.4;
		score.anchorPoint = ccp(1, 0.5);
		score.position = ccp(background.contentSize.width * 0.9, background.contentSize.height * 0.5);
		[self addChild:score];
	}
	
	return self;
}

@end
