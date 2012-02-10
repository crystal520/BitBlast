//
//  EnemyManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 2/9/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "EnemyManager.h"


@implementation EnemyManager

+ (EnemyManager*) sharedSingleton {
	
	static EnemyManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[EnemyManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

@end
