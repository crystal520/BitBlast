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
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// create background
		
		// create buy label
		
		// create for label
		
		// create no thanks label
		CCLabelBMFont *noThanksLabel = [CCLabelBMFont labelWithString:@"NO\nTHANKS" fntFile:@"gamefont.fnt"];
		noThanksLabel.anchorPoint = ccp(0, 0.5);
		
		// create no thanks button
		
		// create buy it label
		CCLabelBMFont *buyItLabel = [CCLabelBMFont labelWithString:@"BUY IT" fntFile:@"gamefont.fnt"];
		buyItLabel.scale = 0.4;
		
		// create buy it button
	}
	
	return self;
}

@end
