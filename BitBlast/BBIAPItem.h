//
//  BBIAPItem.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/18/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelButton.h"
#import "CCButton.h"
#import "IAPManager.h"
#import "SimpleAudioEngine.h"

@interface BBIAPItem : CCNode {
    CCButton *background;
	CCLabelButton *buy;
	NSString *productID;
}

- (id) initWithProduct:(SKProduct*)product;
- (void) touch;
- (void) buy;
- (void) viewItem;

@end
