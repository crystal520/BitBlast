//
//  BBConfirmBuy.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNodeColorBackground.h"

@interface BBConfirmBuy : CCNodeColorBackground {
    CCLabelBMFont *buyLabel, *cost;
	NSMutableDictionary *itemDictionary;
}

- (void) updateWithInfo:(NSDictionary*)dict;

@end
