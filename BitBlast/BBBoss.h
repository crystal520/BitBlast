//
//  BBBoss.h
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBMovingObject.h"
#import "BBBossPiece.h"

@interface BBBoss : BBMovingObject {
    // different pieces of the boss
    NSMutableArray *pieces;
}

@end
