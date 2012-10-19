//
//  CCAnimateFrame.h
//  Gun Runner
//
//  Created by Kristian Bauer on 10/17/12.
//
//

@class CCAnimation;
@class CCTexture2D;
/** Animates a sprite given the name of an Animation */
@interface CCAnimateFrame : CCActionInterval <NSCopying>
{
	CCAnimation *animation_;
	id origFrame_;
	BOOL restoreOriginalFrame_;
	int startFrame_;
}
/** animation used for the animage */
@property (readwrite,nonatomic,retain) CCAnimation * animation;

/** creates the action with an Animation and will restore the original frame when the animation is over */
+(id) actionWithAnimation:(CCAnimation*) a;
/** initializes the action with an Animation and will restore the original frame when the animtion is over */
-(id) initWithAnimation:(CCAnimation*) a;
/** creates the action with an Animation */
+(id) actionWithAnimation:(CCAnimation*) a restoreOriginalFrame:(BOOL)b;
/** initializes the action with an Animation */
-(id) initWithAnimation:(CCAnimation*) a restoreOriginalFrame:(BOOL)b;
/** creates the action with an animation that will restore the original frame when the animation is over and start at the given frame */
+(id) actionWithAnimation:(CCAnimation *)a restoreOriginalFrame:(BOOL)b startFrame:(int)f;
/** initializes the action with an animation that will restore the original frame when the animation is over and start at the given frame */
-(id) initWithAnimation:(CCAnimation *)a restoreOriginalFrame:(BOOL)b startFrame:(int)f;
/** creates an action with a duration, animation and depending of the restoreOriginalFrame, it will restore the original frame or not.
 The 'delay' parameter of the animation will be overrided by the duration parameter.
 @since v0.99.0
 */
+(id) actionWithDuration:(ccTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)b;
/** initializes an action with a duration, animation and depending of the restoreOriginalFrame, it will restore the original frame or not.
 The 'delay' parameter of the animation will be overrided by the duration parameter.
 @since v0.99.0
 */
-(id) initWithDuration:(ccTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)b;
@end
