//
//  BBDeviceManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 10/17/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBDeviceManager : NSObject

+ (BOOL) iOSVersionGreaterThan:(NSString*)iosVersion;

@end
