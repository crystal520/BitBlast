//
//  BBGameWin.h
//  GunRunner
//
//  Created by Kristian Bauer on 10/3/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import "cocos2d.h"
#import "BBColorRectSprite.h"

@interface BBGameWin : CCNode <CCTargetedTouchDelegate> {
    // the text that needs to be typed out
    NSString *typeText;
    // which character the typer is at
    int typeCounter;
    // game win label
    CCLabelBMFont *gameWinLabel;
    // tap to continue label
    CCLabelBMFont *tapToContinueLabel;
}

@end
