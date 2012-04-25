//
//  BBDialogQueue.m
//  GunRunner
//
//  Created by Kristian Bauer on 4/21/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBDialogQueue.h"


@implementation BBDialogQueue

+ (BBDialogQueue*) sharedSingleton {
	
	static BBDialogQueue *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBDialogQueue alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		dialogs = [NSMutableArray new];
	}
	return self;
}

- (void) dealloc {
	[dialogs release];
	[super dealloc];
}

#pragma mark -
#pragma mark actions
- (void) addDialog:(BBDialog *)dialog {
	if (self.children.count == 0) {
		// Display now
		[self addChild:dialog];
		[dialog animateDisplay];
	}
	else {
		// save for later
		[dialogs addObject:dialog];
	}
}

- (void) removeDialog:(BBDialog *)dialog {
	if (dialog) {
        if (dialog.parent) {
            [dialog removeFromParentAndCleanup:YES];
		}
        else {
            [dialogs removeObject:dialog];
		}
    }
}

- (void) popDialog {
	if (dialogs.count > 0) {
		BBDialog *newDlg = [dialogs lastObject];
		[self addChild:newDlg];
		[newDlg animateDisplay];
		[dialogs removeLastObject];
	}
}

@end
