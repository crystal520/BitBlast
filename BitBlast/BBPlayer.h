//
//  BBPlayer.h
//  BitBlast
//
//  Created by Kristian Bauer on 12/12/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBGameObject.h"
#import "ChunkManager.h"
#import "BBBullet.h"

@interface BBPlayer : BBGameObject {
	
}

- (void) die:(NSString*)reason;
- (void) jump;
- (void) shoot;

@end
