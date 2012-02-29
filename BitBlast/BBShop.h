//
//  BBShop.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/14/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNodeColorBackground.h"
#import "BBShopItem.h"
#import "CCLabelButton.h"

@interface BBShop : CCNodeColorBackground <SWTableViewDataSource, SWTableViewDelegate> {
    NSMutableArray *items;
	CCLabelButton *back;
	SWTableView *table;
	BOOL enabled;
}

- (void) setEnabled:(BOOL)isEnabled;

@end
