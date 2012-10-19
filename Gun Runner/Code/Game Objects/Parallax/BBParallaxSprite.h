//
//  BBParallaxSprite.h
//  GunRunner
//
//  Created by Kristian Bauer on 10/11/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import "CCSprite.h"

@interface BBParallaxSprite : CCSprite {
    CGPoint dummyPosition;
}

@property (nonatomic, assign) CGPoint dummyPosition;

@end
