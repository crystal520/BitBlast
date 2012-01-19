//
//  BBEquipmentManager.h
//  BitBlast
//
//  Created by Kristian Bauer on 1/18/12.
//  Copyright 2012 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBEquipment.h"
#import "BBDoubleJump.h"

@interface BBEquipmentManager : NSObject {
	// set of equipment that the player has currently equipped
    NSMutableSet *equipment;
}

+ (BBEquipmentManager*) sharedSingleton;

// adds the specified equipment to the equipment set
- (void) equip:(NSString*)newEquipment;
// removes the specified equipment from the equipment set
- (void) unequip:(NSString*)oldEquipment;

@end
