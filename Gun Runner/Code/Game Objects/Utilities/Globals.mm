//
//  Globals.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/3/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "Globals.h"
#import "AppDelegate.h"

@implementation Globals

@synthesize playerPosition, playerVelocity, cameraOffset, playerStartingHealth, playerReasonForDeath, gameState, numKeysForMiniboss, numPiecesForFinalBoss, endBossSequence, introBossSequence;

+ (Globals*) sharedSingleton {
	
	static Globals *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[Globals alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

+ (UIViewController*) getAppViewController {
    AppController *appController = ((AppController*)([[UIApplication sharedApplication] delegate]));
    return [appController.navController visibleViewController];
}

@end
