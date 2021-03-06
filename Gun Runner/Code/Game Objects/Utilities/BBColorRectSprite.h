//
//  BBColorRectSprite.h
//  GunRunner
//
//  Created by Kristian Bauer on 10/4/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import "CCSprite.h"

@interface BBColorRectSprite : CCSprite

- (id) initWithColor:(ccColor3B)color alpha:(float)alpha size:(CGSize)size;
+ (id) spriteWithColor:(ccColor3B)color alpha:(float)alpha;
+ (id) spriteWithColor:(ccColor3B)color alpha:(float)alpha size:(CGSize)size;

@end
