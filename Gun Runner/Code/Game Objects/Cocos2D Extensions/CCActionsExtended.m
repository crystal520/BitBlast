//
//  CCActionsExtended.m
//  Gun Runner
//
//  Created by Kristian Bauer on 10/18/12.
//
//

#import "CCActionsExtended.h"

//
// CCFadeBy
//
#pragma mark -
#pragma mark CCFadeBy
@implementation CCFadeBy
+(id) actionWithDuration:(ccTime)t opacity:(float)opacity
{
	return [[(CCFadeBy*)[self alloc] initWithDuration:t opacity:opacity] autorelease];
}

-(id) initWithDuration:(ccTime)t opacity:(float)opacity
{
	if( (self=[super initWithDuration:t] ) ) {
		deltaOpacity_ = opacity;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return[(CCFadeBy*)[[self class] allocWithZone: zone] initWithDuration: [self duration] opacity:deltaOpacity_];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	fromOpacity_ = [(id<CCRGBAProtocol>)target_ opacity];
}

-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>)target_ setOpacity:fromOpacity_ + deltaOpacity_ * t];
}

- (CCActionInterval*) reverse
{
	return [CCFadeBy actionWithDuration:duration_ opacity:-deltaOpacity_];
}
@end
