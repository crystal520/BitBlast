//
//  BBBossPiece.h
//  GunRunner
//
//  Created by Kristian Bauer on 9/6/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import "BBGameObject.h"
#import "BBBullet.h"
#import "SimpleAudioEngine.h"

@interface BBBossPieceShape : BBGameObjectShape {}
@end

@interface BBBossPiece : BBGameObject {
    // what type of boss piece this is
    NSString *type;
    // whether or not this boss piece is enabled
    BOOL enabled;
    // reference to last bullet that hit this piece
    BBBullet *lastBulletHit;
    // particles for when boss piece is hit by bullet
	NSString *particles;
}

@property (nonatomic, assign) NSString *type;
@property (nonatomic, assign) BOOL enabled;

- (id) initWithDictionary:(NSDictionary *)dictionary;
// setters
- (void) setCollisionShape:(NSString*)newShape;
// update
- (void) update:(float)delta;
// actions
- (void) hitByBullet:(BBBullet*)bullet withContact:(GB2Contact*)contact;
- (void) flash;
- (void) die;

@end
