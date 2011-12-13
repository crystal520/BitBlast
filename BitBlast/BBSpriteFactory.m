//
//  BBSpriteFactory.m
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "BBSpriteFactory.h"


@implementation BBSpriteFactory

+ (id) spriteWithFile:(NSString *)filename {
	
	// Create a normal sprite
	CCSprite *sprite = [CCSprite spriteWithFile:filename];
	
	// Set texture params
	[sprite.texture setAliasTexParameters];
	
	// Scale up
	sprite.scale = 2;
	
	return sprite;
}

+ (id) spriteWithFile:(NSString *)filename scale:(int)sScale {
	
	// Create a normal sprite
	CCSprite *sprite = [CCSprite spriteWithFile:filename];
	
	// Set texture params
	[sprite.texture setAliasTexParameters];
	
	// Scale up
	sprite.scale = sScale;
	
	return sprite;
}

@end
