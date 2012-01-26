//
//  BBGlider.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/21/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBEquipment.h"

@interface BBGlider : BBEquipment {
    float maxVelocity, oldMaxVelocity;
	int glideCount;
	BOOL enabled;
}

- (void) setEnabled:(BOOL)newEnabled withNotification:(NSNotification*)n;

@end