//
//  BBDialog.m
//  GunRunner
//
//  Created by Kristian Bauer on 4/14/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "BBDialog.h"


@implementation BBDialog

@synthesize title, text;

+ (BBDialog*) dialogWithTitle:(NSString*)title text:(NSString*)text leftButton:(CCButton*)leftButton rightButton:(CCButton*)rightButton {
	return [[[BBDialog alloc] initWithTitle:title text:text leftButton:leftButton rightButton:rightButton] autorelease];
}

- (id) initWithTitle:(NSString*)title text:(NSString*)text leftButton:(CCButton*)leftButton rightButton:(CCButton*)rightButton {
	if((self = [super initWithColor:ccc3(0, 0, 0) withAlpha:0.5f])) {
		
	}
	return self;
}

@end
