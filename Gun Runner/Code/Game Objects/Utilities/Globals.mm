//
//  Globals.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/3/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import "Globals.h"
#import "AppDelegate.h"
#import "ChunkManager.h"

@implementation Globals

@synthesize playerPosition, playerVelocity, cameraOffset, playerStartingHealth, playerReasonForDeath, gameState, numKeysForMiniboss, numPiecesForFinalBoss, endBossSequence, introBossSequence, tutorial, tutorialState, tutorialStateCanChange;

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

- (void) setTutorialState:(TutorialState)newTutorialState {
    tutorialState = newTutorialState;
    tutorialStateCanChange = NO;
    // save current tutorial state
    [[SettingsManager sharedSingleton] setInteger:tutorialState keyString:@"tutorialState"];
    // reset chunk count for displaying tutorial
    [ChunkManager sharedSingleton].chunkCount = 0;
}

- (void) setTutorial:(BOOL)newTutorial {
    tutorial = newTutorial;
    // save current tutorial
    [[SettingsManager sharedSingleton] setBool:tutorial keyString:@"needsTutorial"];
}

@end
