//
//  CCAnimateFrame.m
//  Gun Runner
//
//  Created by Kristian Bauer on 10/17/12.
//
//

#import "CCAnimateFrame.h"

@implementation CCAnimateFrame

@synthesize animation = animation_;

+(id) actionWithAnimation: (CCAnimation*)anim
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:YES] autorelease];
}

+(id) actionWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:b] autorelease];
}

+(id) actionWithAnimation:(CCAnimation *)anim restoreOriginalFrame:(BOOL)b startFrame:(int)frame
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:b startFrame:frame] autorelease];
}

+(id) actionWithDuration:(ccTime)duration animation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithDuration:duration animation:anim restoreOriginalFrame:b] autorelease];
}

-(id) initWithAnimation: (CCAnimation*)anim
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	return [self initWithAnimation:anim restoreOriginalFrame:YES];
}

-(id) initWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	return [self initWithAnimation:anim restoreOriginalFrame:b startFrame:0];
}

-(id) initWithAnimation:(CCAnimation *)anim restoreOriginalFrame:(BOOL)b startFrame:(int)frame
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	
	if( (self=[super initWithDuration: [[anim frames] count] * [anim delayPerUnit]]) ) {
		
		restoreOriginalFrame_ = b;
		self.animation = anim;
		origFrame_ = nil;
		startFrame_ = frame;
	}
	return self;
}

-(id) initWithDuration:(ccTime)aDuration animation: (CCAnimation*)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	
	if( (self=[super initWithDuration:aDuration] ) ) {
		
		restoreOriginalFrame_ = b;
		self.animation = anim;
		origFrame_ = nil;
		startFrame_ = 0;
	}
	return self;
}


-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:duration_ animation:animation_ restoreOriginalFrame:restoreOriginalFrame_];
}

-(void) dealloc
{
	[animation_ release];
	[origFrame_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	CCSprite *sprite = target_;
    
	[origFrame_ release];
    
	if( restoreOriginalFrame_ )
		origFrame_ = [((CCAnimationFrame*)([sprite displayFrame])).spriteFrame retain];
}

-(void) stop
{
	if( restoreOriginalFrame_ ) {
		CCSprite *sprite = target_;
		[sprite setDisplayFrame:origFrame_];
	}
	
	[super stop];
}

-(void) update: (ccTime) t
{
	NSArray *frames = [animation_ frames];
	NSUInteger numberOfFrames = [frames count];
	
	NSUInteger idx = startFrame_ + t * numberOfFrames;
    
	if( idx >= numberOfFrames ) {
		if(startFrame_ != 0)
		{
			idx -= numberOfFrames;
			// handle any potential overtime issues
			if(idx >= startFrame_)
				idx = startFrame_-1;
		}
		else
			idx = numberOfFrames -1;
	}
	
	CCSprite *sprite = target_;
	if (! [sprite isFrameDisplayed: ((CCAnimationFrame*)([frames objectAtIndex: idx])).spriteFrame] )
		[sprite setDisplayFrame: ((CCAnimationFrame*)([frames objectAtIndex:idx])).spriteFrame];
}

- (CCActionInterval *) reverse
{
	NSArray *oldArray = [animation_ frames];
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[oldArray count]];
    NSEnumerator *enumerator = [oldArray reverseObjectEnumerator];
    for (id element in enumerator)
        [newArray addObject:[[element copy] autorelease]];
	
	CCAnimation *newAnim = [CCAnimation animationWithSpriteFrames:newArray delay:animation_.delayPerUnit];
	return [[self class] actionWithDuration:duration_ animation:newAnim restoreOriginalFrame:restoreOriginalFrame_];
}

@end
