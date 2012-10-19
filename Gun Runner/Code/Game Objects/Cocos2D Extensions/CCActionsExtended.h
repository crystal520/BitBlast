//
//  CCActionsExtended.h
//  Gun Runner
//
//  Created by Kristian Bauer on 10/18/12.
//
//

#import <Foundation/Foundation.h>

/** Fades an object that implements the CCRGBAProtocol protocol. It modifies the opacity from the current value to a custom one.
 */
@interface CCFadeBy : CCActionInterval <NSCopying>
{
	float deltaOpacity_;
	float fromOpacity_;
}
/** creates an action with duration and opacity */
+(id) actionWithDuration:(ccTime)duration opacity:(float)opacity;
/** initializes the action with duration and opacity */
-(id) initWithDuration:(ccTime)duration opacity:(float)opacity;
@end
