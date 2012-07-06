//
//  Globals.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/3/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "Globals.h"


@implementation Globals

@synthesize playerPosition, playerVelocity, cameraOffset, playerStartingHealth, playerReasonForDeath;

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

@end
