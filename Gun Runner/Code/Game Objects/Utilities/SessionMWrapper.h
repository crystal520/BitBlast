//
//  SessionMWrapper.h
//  GunRunner
//
//  Created by Kristian Bauer on 5/5/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionM.h"

@interface SessionMWrapper : NSObject <SessionMDelegate> {
	// queue for events that may have been submitted while SessionM was not initialized
	NSMutableArray *eventQueue;
	// whether or not SessionM has been initialized
	BOOL initialized;
    // unclaimed achievement count
    int achievementCount;
}

@property (nonatomic, readonly) int achievementCount;

+ (SessionMWrapper*) sharedSingleton;
// actions
- (void) sessionEvent:(NSString*)eventName;
- (void) clearQueue;
- (void) saveQueue;
- (void) loadQueue;
- (void) openSessionM;

@end
