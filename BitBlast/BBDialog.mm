//
//  BBDialog.m
//  GunRunner
//
//  Created by Kristian Bauer on 4/14/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBDialog.h"
#import "BBDialogQueue.h"

@implementation BBDialog

@synthesize buttonIndex, container;

+ (BBDialog*) dialogWithTitle:(NSString*)title text:(NSString*)text buttons:(NSString*)buttons target:(id)t selector:(SEL)s {
	return [[[BBDialog alloc] initWithTitle:title text:text buttons:buttons target:t selector:s] autorelease];
}

+ (BBDialog*) dialogWithTitleLabel:(CCLabelBMFont*)title textLabel:(CCLabelBMFont*)text buttonLabels:(NSArray*)buttons target:(id)t selector:(SEL)s {
	return [[[BBDialog alloc] initWithTitleLabel:title textLabel:text buttonLabels:buttons target:t selector:s] autorelease];
}

- (id) initWithTitle:(NSString*)title text:(NSString*)text buttons:(NSString*)buttons target:(id)t selector:(SEL)s {
	
	// create button labels
	NSArray *buttonStrings = [buttons componentsSeparatedByString:@","];
	
	CCLabelBMFont *leftButtonLabel = [CCLabelBMFont labelWithString:[buttonStrings objectAtIndex:0] fntFile:@"gamefont.fnt"];
	leftButtonLabel.scale = 0.4;
	
	CCLabelBMFont *rightButtonLabel = [CCLabelBMFont labelWithString:[buttonStrings objectAtIndex:1] fntFile:@"gamefont.fnt"];
	rightButtonLabel.scale = 0.4;
	
	// create title
	CCLabelBMFont *titleLabel = [CCLabelBMFont labelWithString:title fntFile:@"gamefont.fnt"];
	
	// create text
	CCLabelBMFont *textLabel = [CCLabelBMFont labelWithString:text fntFile:@"gamefont.fnt" width:1200 * [ResolutionManager sharedSingleton].positionScale alignment:UITextAlignmentCenter];
	textLabel.scale = 0.4;
	
	if((self = [self initWithTitleLabel:titleLabel textLabel:textLabel buttonLabels:[NSArray arrayWithObjects:leftButtonLabel, rightButtonLabel, nil] target:t selector:s])) {
	}
	return self;
}

- (id) initWithTitleLabel:(CCLabelBMFont*)title textLabel:(CCLabelBMFont*)text buttonLabels:(NSArray*)buttons target:(id)t selector:(SEL)s {
	if((self = [super init])) {
		CGSize winSize = [ResolutionManager sharedSingleton].size;
		
		// background faded black
		CCLayerColor *shade = [CCLayerColor layerWithColor:(ccColor4B){0,0,0,128} width:winSize.width height:winSize.height];
		[self addChild:shade];
		
		// make container to hold everything
		container = [CCNode node];
		container.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
		[self addChild:container];
		
		// create background
		CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"shopConfirmBackground.png"];
		[container addChild:background];
		
		// sprite batch for buttons
		CCSpriteBatchNode *uiSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"uiatlas.png"];
		[container addChild:uiSpriteBatch];
		
		// left button
		leftButton = [CCLabelButton buttonWithLabel:[buttons objectAtIndex:0] normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] disabledSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(leftButtonSelected)];
		// hide and disable button if the label has 0 length
		leftButton.visible = [leftButton.label string].length;
		[leftButton setEnabled:[leftButton.label string].length];
		leftButton.position = ccp(-150 * [ResolutionManager sharedSingleton].positionScale, -126 * [ResolutionManager sharedSingleton].positionScale);
		[leftButton setSpriteBatchNode:uiSpriteBatch];
		[container addChild:leftButton];
		
		// right button
		rightButton = [CCLabelButton buttonWithLabel:[buttons objectAtIndex:1] normalSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButton.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] disabledSprite:[CCSprite spriteWithSpriteFrameName:@"shopConfirmButtonDown.png"] target:self selector:@selector(rightButtonSelected)];
		// hide and disable button if the label has 0 length
		rightButton.visible = [rightButton.label string].length;
		[rightButton setEnabled:[rightButton.label string].length];
		rightButton.position = ccp(150 * [ResolutionManager sharedSingleton].positionScale, -126 * [ResolutionManager sharedSingleton].positionScale);
		[rightButton setSpriteBatchNode:uiSpriteBatch];
		[container addChild:rightButton];
		
		title.position = ccp(0, 110);
		[container addChild:title];
		[container addChild:text];
		
		// add callback with target and selector
		target = t;
		selector = s;
	}
	return self;
}

- (void) dealloc {
	[[BBDialogQueue sharedSingleton] popDialog];
	[super dealloc];
}

#pragma mark -
#pragma mark actions
- (void) animateDisplay {
	// bouncy animation
	[container setScale:0.01];
	CCSequence *bounce = [CCSequence actions:[CCScaleTo actionWithDuration:0.15 scale:1.1],[CCScaleTo actionWithDuration:0.05 scale:1],nil];
	[container runAction:bounce];
	
	// swallow touches so other menus are disabled
	self.isTouchEnabled = YES;
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	// return true just to swallow touches
	[leftButton ccTouchBegan:touch withEvent:event];
	[rightButton ccTouchBegan:touch withEvent:event];
	return YES;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	[leftButton ccTouchMoved:touch withEvent:event];
	[rightButton ccTouchMoved:touch withEvent:event];
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	[leftButton ccTouchEnded:touch withEvent:event];
	[rightButton ccTouchEnded:touch withEvent:event];
}

- (void) leftButtonSelected {
	buttonIndex = DIALOG_BUTTON_LEFT;
	[target performSelector:selector withObject:self];
	[self removeFromParentAndCleanup:YES];
}

- (void) rightButtonSelected {
	buttonIndex = DIALOG_BUTTON_RIGHT;
	[target performSelector:selector withObject:self];
	[self removeFromParentAndCleanup:YES];
}

@end
