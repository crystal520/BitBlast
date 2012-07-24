//
//  BBActionInterval.m
//  GunRunner
//
//  Created by Kristian Bauer on 5/6/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "BBActionInterval.h"

@implementation BBMoveTo

+(id) actionWithDuration: (ccTime) t position: (CGPoint) p
{	
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p
{
	if( (self=[super initWithDuration: t]) )
		endPosition_ = p;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: endPosition_];
	return copy;
}

-(void) startWithTarget:(BBGameObject *)aTarget
{
	[super startWithTarget:aTarget];
	startPosition_ = [(BBGameObject*)target_ dummyPosition];
	delta_ = ccpSub( endPosition_, startPosition_ );
}

-(void) update: (ccTime) t
{	
	[target_ setDummyPosition: ccp( (startPosition_.x + delta_.x * t ), (startPosition_.y + delta_.y * t ) )];
}

@end

@implementation BBMoveBy
+(id) actionWithDuration: (ccTime) t position: (CGPoint) p
{	
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p
{
	if( (self=[super initWithDuration: t]) )
		delta_ = p;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: delta_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	CGPoint dTmp = delta_;
	[super startWithTarget:aTarget];
	delta_ = dTmp;
}

-(void) update: (ccTime) t
{
	[target_ setDummyPosition: ccp( (([target_ dummyPosition].x - startPosition_.x) + startPosition_.x + delta_.x * t ), (([target_ dummyPosition].y - startPosition_.y) + startPosition_.y + delta_.y * t ) )];
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ position:ccp( -delta_.x, -delta_.y)];
}
@end
