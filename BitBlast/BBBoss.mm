//
//  BBBoss.m
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBBoss.h"

@implementation BBBoss

- (id) initWithFile:(NSString *)filename {
    if((self = [super initWithFile:filename])) {
        // make array for holding pieces
        pieces = [NSMutableArray new];
        // create boss pieces and add to boss
        NSArray *bossPieces = [dictionary objectForKey:@"pieces"];
        for(NSDictionary *d in bossPieces) {
            BBBossPiece *piece = [[BBBossPiece alloc] initWithDictionary:d];
            [self addChild:piece];
            [pieces addObject:piece];
            [piece release];
        }
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
    [pieces release];
}

@end
