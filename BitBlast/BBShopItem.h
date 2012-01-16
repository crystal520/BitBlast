//
//  BBShopItem.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/16/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BBShopItem : SWTableViewCell {
	CCMenuItemSprite *background;
	CCMenuItemLabelAndImage *buy;
}

- (id) initWithFile:(NSString*)filename;
- (void) touch:(CGPoint)point;
- (void) buy;
- (void) viewItem;

@end