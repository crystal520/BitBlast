//
//  BBDialogQueue.h
//  GunRunner
//
//  Created by Kristian Bauer on 4/21/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBDialog.h"

@interface BBDialogQueue : CCNode {
    NSMutableArray *dialogs;
	BOOL enabled;
}

+ (BBDialogQueue*) sharedSingleton;
// actions
- (void) addDialog:(BBDialog*)dialog;
- (void) removeDialog:(BBDialog*)dialog;
- (void) popDialog;
- (void) setEnabled:(BOOL)newEnabled;

@end
