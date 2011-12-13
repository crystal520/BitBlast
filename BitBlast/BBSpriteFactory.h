//
//  BBSpriteFactory.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BBSpriteFactory : CCSprite {
    
}

+ (id) spriteWithFile:(NSString *)filename;
+ (id) spriteWithFile:(NSString *)filename scale:(int)sScale;

@end
