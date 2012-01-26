//
//  ResolutionManager.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/22/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ResolutionManager : NSObject {
    float imageScale, positionScale, inversePositionScale;
	CGPoint position;
	CGSize size;
}

@property (nonatomic, readonly) float imageScale, positionScale, inversePositionScale;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, readonly) CGSize size;

+ (ResolutionManager*) sharedSingleton;

@end
