//
//  BBColorRectSprite.m
//  GunRunner
//
//  Created by Kristian Bauer on 10/4/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBColorRectSprite.h"

@implementation BBColorRectSprite

- (id) initWithColor:(ccColor3B)color alpha:(float)alpha {
    CGSize winSize = [ResolutionManager sharedSingleton].size;
    
    if((self = [super initWithFile:@"white.png" rect:CGRectMake(0, 0, winSize.width * 2, winSize.height * 2)])) {
		self.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
		self.color = color;
		self.opacity = alpha * 255;
        self.tag = SPRITE_TAG_BACKGROUND;
		ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
		[self.texture setTexParameters:&params];
    }
    return self;
}

+ (id) spriteWithColor:(ccColor3B)color alpha:(float)alpha {
    return [[[BBColorRectSprite alloc] initWithColor:color alpha:alpha] autorelease];
}

@end
