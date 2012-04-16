//
//  BBDialog.h
//  GunRunner
//
//  Created by Kristian Bauer on 4/14/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNodeColorBackground.h"
#import "CCButton.h"

@interface BBDialog : CCNodeColorBackground {
    CCLabelBMFont *title;
	CCLabelBMFont *text;
}

@property (nonatomic, retain) CCLabelBMFont *title;
@property (nonatomic, retain) CCLabelBMFont *text;

// setup
+ (BBDialog*) dialogWithTitle:(NSString*)title text:(NSString*)text leftButton:(CCButton*)leftButton rightButton:(CCButton*)rightButton;
- (id) initWithTitle:(NSString*)title text:(NSString*)text leftButton:(CCButton*)leftButton rightButton:(CCButton*)rightButton;

@end
