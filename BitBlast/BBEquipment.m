//
//  BBEquipment.m
//  BitBlast
//
//  Created by Kristian Bauer on 1/18/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import "BBEquipment.h"


@implementation BBEquipment

- (id) init {
	if((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:kPlayerUpdateNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectCoin:) name:kPlayerCollectCoinNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpApex:) name:kPlayerEndJumpNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(damage:) name:kPlayerDamagedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collidePlatform:) name:kPlayerCollidePlatformNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(die:) name:kPlayerDeadNotification object:nil];
	}
	return self;
}

- (NSString*) identifier {
	return @"";
}

- (void) update:(NSNotification*)n {
	
}

- (void) restart:(NSNotification*)n {
	
}

- (void) die:(NSNotification*)n {
	
}

- (void) collectCoin:(NSNotification*)n {
	
}

- (void) jumpApex:(NSNotification*)n {
	
}

- (void) damage:(NSNotification*)n {
	
}

- (void) collidePlatform:(NSNotification*)n {
	
}

@end
