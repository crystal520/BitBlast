//
//  BBDialog.h
//  GunRunner
//
//  Created by Kristian Bauer on 4/14/12.
//  Copyright 2012 One Happy Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelButton.h"

typedef enum {
	DIALOG_BUTTON_LEFT,
	DIALOG_BUTTON_RIGHT
} DialogButtonID;

@interface BBDialog : CCLayer {
	// for scaling during display animation
	CCNode *container;
	// buttons for checking touches
	CCLabelButton *leftButton, *rightButton;
	// used for callback
	id target;
	SEL selector;
	// used to check which button was pressed
	int buttonIndex;
}

@property (nonatomic, readonly) int buttonIndex;
@property (nonatomic, assign) CCNode *container;

// setup
+ (BBDialog*) dialogWithTitle:(NSString*)title text:(NSString*)text buttons:(NSString*)buttons target:(id)t selector:(SEL)s;
+ (BBDialog*) dialogWithTitleLabel:(CCLabelBMFont*)title textLabel:(CCLabelBMFont*)text buttonLabels:(NSArray*)buttons target:(id)t selector:(SEL)s;
- (id) initWithTitle:(NSString*)title text:(NSString*)text buttons:(NSString*)buttons target:(id)t selector:(SEL)s;
- (id) initWithTitleLabel:(CCLabelBMFont*)title textLabel:(CCLabelBMFont*)text buttonLabels:(NSArray*)buttons target:(id)t selector:(SEL)s;
// actions
- (void) animateDisplay;

@end
