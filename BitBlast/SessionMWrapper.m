//
//  SessionMWrapper.m
//  GunRunner
//
//  Created by Kristian Bauer on 5/5/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "SessionMWrapper.h"

@implementation SessionMWrapper

+ (SessionMWrapper*) sharedSingleton {
	
	static SessionMWrapper *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[SessionMWrapper alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		initialized = NO;
		eventQueue = [NSMutableArray new];
		[SessionM config].orientation = SessionM_UIDisplayLandscape;
		[SessionM setDelegate:self];
		[SessionM initWithApplicationId:@"aacd562506d9942e340a244642bd929091de99f4"];
		
		// listen for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemPurchased) name:kNavBuyItemNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:kPlayerDeadNotification object:nil];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
	[eventQueue release];
}

#pragma mark -
#pragma mark actions
- (void) sessionEvent:(NSString*)eventName {
	if(initialized && [[SettingsManager sharedSingleton] getBool:@"sessionMEnabled"]) {
		NSLog(@"SessionMWrapper logging event: %@", eventName);
		[SessionM sessionEvent:eventName];
	}
	else {
		NSLog(@"SessionMWrapper queueing event: %@", eventName);
		[eventQueue addObject:eventName];
	}
}

- (void) clearQueue {
	NSLog(@"SessionMWrapper clearing queue");
	for(NSString *event in eventQueue) {
		if(initialized && [[SettingsManager sharedSingleton] getBool:@"sessionMEnabled"]) {
            NSLog(@"SessionMWrapper logging event: %@", event);
            [SessionM sessionEvent:event];
        }
	}
}

- (void) saveQueue {
	// make comma separated string from queue
	NSMutableString *queueString = [NSMutableString string];
	for(NSString *event in eventQueue) {
		[queueString appendFormat:@"%@,", event];
	}
	// get rid of trailing comma if there are any events
    if([eventQueue count] > 0) {
        [queueString setString:[queueString substringToIndex:[queueString length]-1]];
    }
	// save it to device
	[[SettingsManager sharedSingleton] setString:queueString keyString:@"SessionMQueue"];
	// clear out queue so there aren't duplicate events when queue is loaded
	[eventQueue removeAllObjects];
}

- (void) loadQueue {
	// add events from comma separated string to queue
	[eventQueue addObjectsFromArray:[[[SettingsManager sharedSingleton] getString:@"SessionMQueue"] componentsSeparatedByString:@","]];
}

- (void) openSessionM {
	[SessionM summonPortal];
}

#pragma mark -
#pragma mark notifications
- (void) itemPurchased {
	// SessionM achievement - Upgrade
	[self sessionEvent:@"upgrade"];
}

- (void) gameOver {
	// SessionM achievement - Moneybags
	if([[SettingsManager sharedSingleton] getInt:@"dailyCoins"] >= 10000) {
		[self sessionEvent:@"10000Coins"];
	}
	// SessionM achievement - Enemy Eradication
	if([[SettingsManager sharedSingleton] getInt:@"dailyEnemies"] >= 500) {
		[self sessionEvent:@"kill500BadGuys"];
	}
	// SessionM achievement - Deep Pockets
	if([[SettingsManager sharedSingleton] getInt:@"currentCoins"] >= 500) {
		[self sessionEvent:@"500Coins"];
	}
	// SessionM achievement - Grounded
	if([[SettingsManager sharedSingleton] getInt:@"currentDropships"] >= 5) {
		[self sessionEvent:@"kill5DropShips"];
	}
	// SessionM achievement - Killing Spree
	if([[SettingsManager sharedSingleton] getInt:@"currentEnemies"] >= 25) {
		[self sessionEvent:@"killingSpree"];
	}
	// SessionM achievement - Chariots Of Fire
	if([[SettingsManager sharedSingleton] getInt:@"dailyDistance"] >= 25000) {
		[self sessionEvent:@"25000meters"];
	}
	// SessionM achievement - Going The Distance
	if([[SettingsManager sharedSingleton] getInt:@"currentDistance"] >= 1000) {
		[self sessionEvent:@"1000meters"];
	}
	// SessionM achievement - Dropship Destruction
	if([[SettingsManager sharedSingleton] getInt:@"dailyDropships"] >= 100) {
		[self sessionEvent:@"dropshipDestruction"];
	}
	[SessionM insertInteractable];
} 

#pragma mark -
#pragma mark SessionMDelegate
- (void) sessionMDidInitialize {
	initialized = YES;
	// attempt to clear out the queue
	[self clearQueue];
	// show an interactable
	[SessionM insertInteractable];
}

- (void) sessionMDidFail:(NSError *)error {
	initialized = NO;
}

- (void) interactableWillShow:(BOOL)willDisplay {
	NSLog(@"SessionMWrapper interactableWillShow: %i", willDisplay);
}

- (void) interactableFullScreenDidStartLoad {
	NSLog(@"SessionMWrapper interactableFullScreenDidStartLoad");
}

- (void) interactableDisplayStarted {
	NSLog(@"SessionMWrapper interactableDisplayStarted");
}

- (void) interactableDidStartLoad {
	NSLog(@"SessionMWrapper interactableDidStartLoad");
}

- (void) interactableDidFinishLoad {
	NSLog(@"SessionMWrapper interactableDidFinishLoad");
}

- (void) userDidPerformInteraction {
	NSLog(@"SessionMWrapper userDidPerformInteraction");
}

- (void) interactableDidClose {
	NSLog(@"SessionMWrapper interactableDidClose");
}

- (void) userInfoDidChange:(NSDictionary *)userInfo {
	NSLog(@"SessionMWrapper userInfoDidChange: %@", userInfo);
}

@end
