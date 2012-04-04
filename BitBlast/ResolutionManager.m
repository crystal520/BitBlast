//
//  ResolutionManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/22/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "ResolutionManager.h"


@implementation ResolutionManager

@synthesize imageScale, positionScale, position, size, inversePositionScale;

+ (ResolutionManager*) sharedSingleton {
	
	static ResolutionManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[ResolutionManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		
		// iPhone, retina
		imageScale = 1;
		positionScale = 0.5;
		position = ccp(0, 0);
		size = [CCDirector sharedDirector].winSize;
		if(![[CCDirector sharedDirector] enableRetinaDisplay:YES]) {
			
			// iPhone, non-retina
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
				imageScale = 0.5;
				positionScale = 1;
				size = CGSizeMake([CCDirector sharedDirector].winSize.width * 2, [CCDirector sharedDirector].winSize.height * 2);
				position = ccp(-[CCDirector sharedDirector].winSize.width * imageScale * 0.5, -[CCDirector sharedDirector].winSize.height * imageScale * 0.5);
			}
			// iPad, non-retina
			else {
				positionScale = 1;
			}
		}
		else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			imageScale = 2;
			positionScale = 0.5;
			size = CGSizeMake([CCDirector sharedDirector].winSize.width * 0.5, [CCDirector sharedDirector].winSize.height * 0.5);
			position = ccp([CCDirector sharedDirector].winSize.width * 0.25, [CCDirector sharedDirector].winSize.height * 0.25);
		}
		inversePositionScale = 1 / positionScale;
	}
	return self;
}

@end
