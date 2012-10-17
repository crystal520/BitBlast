//
//  BBDeviceManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 10/17/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBDeviceManager : NSObject

+ (BOOL) iOSVersionGreaterThan:(NSString*)iosVersion;

@end
