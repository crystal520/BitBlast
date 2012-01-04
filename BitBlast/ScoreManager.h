//
//  ScoreManager.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/2/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ScoreManager : NSObject {
    
	int distance;
}

@property (nonatomic) int distance;

+ (ScoreManager*) sharedSingleton;

- (void) reset;
- (int) getScore;
- (NSString*) getScoreString;

@end
