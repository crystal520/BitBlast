//
//  BBPowerupManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 5/2/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBPowerupManager.h"

@implementation BBPowerupManager

+ (BBPowerupManager*) sharedSingleton {
	
	static BBPowerupManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBPowerupManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

@end
