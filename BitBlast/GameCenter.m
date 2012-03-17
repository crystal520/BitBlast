//
//  GameCenter.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/16/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "GameCenter.h"
#include <sys/sysctl.h>

@implementation GameCenter

+ (GameCenter*) sharedSingleton {
	
	static GameCenter *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[GameCenter alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		if([GameCenter getIsGameCenterAvailable]) {
			[self authenticateGameCenter];
		}
	}
	return self;
}

#pragma mark -
#pragma mark setters
- (void) setAchievementProgress:(NSString*)identifier percent:(float)percent {
	
}

#pragma mark -
#pragma mark getters
+ (BOOL) getIsGameCenterAvailable {
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	size_t size;  
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);  
	char *machine = malloc(size);  
	sysctlbyname("hw.machine", machine, &size, NULL, 0);  
	NSString *platform = [[NSString alloc] initWithCString:machine encoding:NSUTF8StringEncoding];  
	free(machine);
	BOOL isiPhone3G = [platform isEqualToString:@"iPhone1,2"];
	[platform release];
	
    return (gcClass && osVersionSupported && !isiPhone3G);
}

#pragma mark -
#pragma mark actions
- (void) authenticateGameCenter {
	// unregister and then register for game center authentication changed
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	// attempt to authenticate player with game center
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if(error) {
			NSLog(@"Game Center authentication failed");
		}
		else {
			NSLog(@"Game Center authentication success");
		}
	}];
}

- (void) authenticationChanged {
	if([GKLocalPlayer localPlayer].isAuthenticated) {
		
	}
	else {
		
	}
}

@end
