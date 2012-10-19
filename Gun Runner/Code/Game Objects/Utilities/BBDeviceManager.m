//
//  BBDeviceManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 10/17/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import "BBDeviceManager.h"

@implementation BBDeviceManager

+ (BOOL) iOSVersionGreaterThan:(NSString *)iosVersion {
    return ([[[UIDevice currentDevice] systemVersion] compare:iosVersion options:NSNumericSearch] != NSOrderedAscending);
}

@end
