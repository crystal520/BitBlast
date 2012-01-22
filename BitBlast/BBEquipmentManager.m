//
//  BBEquipmentManager.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/18/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBEquipmentManager.h"


@implementation BBEquipmentManager

+ (BBEquipmentManager*) sharedSingleton {
	
	static BBEquipmentManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[BBEquipmentManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		// create equipment set
		equipment = [NSMutableSet new];
	}
	return self;
}

- (void) equip:(NSString*)newEquipment {
	if([newEquipment isEqualToString:@"doublejump"]) {
		[equipment addObject:[[BBDoubleJump new] autorelease]];
	}
	else if([newEquipment isEqualToString:@"glider"]) {
		[equipment addObject:[[BBGlider new] autorelease]];
	}
}

- (void) unequip:(NSString*)oldEquipment {
	for(BBEquipment *e in equipment) {
		if([[e identifier] isEqualToString:oldEquipment]) {
			[equipment removeObject:e];
			break;
		}
	}
}

@end
