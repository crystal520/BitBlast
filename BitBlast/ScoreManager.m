//
//  ScoreManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/2/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "ScoreManager.h"


@implementation ScoreManager

@synthesize distance;

+ (ScoreManager*) sharedSingleton {
	
	static ScoreManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[ScoreManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	
	if((self = [super init])) {
		
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (int) getScore {
	return distance;
}

- (NSString*) getScoreString {
	return [NSString stringWithFormat:@"%im", distance];
}

@end
