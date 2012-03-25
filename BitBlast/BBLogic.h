//
//  BBLogic.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/24/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBDropshipManager.h"
#import "BBCoinManager.h"

@interface BBLogic : NSObject {
    BOOL enabled;
}

+ (BBLogic*) sharedSingleton;
// setters
- (void) setEnabled:(BOOL)newEnabled;
// notifications
- (void) rollDice;

@end
