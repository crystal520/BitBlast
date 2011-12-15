//
//  RepeatableLayer.mm
//
//  Created by Rolando Abarca on 12/13/09.
//

#import "RepeatableLayer.h"


@implementation RepeatableLayer
+ (id)layerWithFile:(NSString *)file {
	RepeatableLayer *layer = [RepeatableLayer spriteWithFile:file];
	layer.anchorPoint = CGPointZero;
	ccTexParams params = { GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT };
	[layer.texture setTexParameters:&params];
	return layer;
}

- (void)draw {
	glEnableClientState( GL_VERTEX_ARRAY); 
	glEnableClientState( GL_TEXTURE_COORD_ARRAY ); 
	glEnable( GL_TEXTURE_2D); 
	glColor4ub( color_.r, color_.g, color_.b, opacity_); 
	//Adjust the texture matrix 
	glMatrixMode(GL_TEXTURE); 
	glPushMatrix(); 
	glLoadIdentity(); 
	//We are just doing horizontal scrolling here so only adjusting x 
	glTranslatef(texOffset.x/self.contentSize.width, 0, 0); 
	//Draw the texture 
	[texture_ drawAtPoint:CGPointZero]; 
	//Restore texture matrix and switch back to modelview matrix 
	glPopMatrix(); 
	glMatrixMode(GL_MODELVIEW); 
	glColor4ub( 255, 255, 255, 255);
	glDisable( GL_TEXTURE_2D); 
	glDisableClientState(GL_VERTEX_ARRAY ); 
	glDisableClientState( GL_TEXTURE_COORD_ARRAY ); 
}

//
// adapted from
// http://www.codza.com/making-seamless-repeating-backgrounds-photoshop-cocos2d-iphone
// 
// it only scrolls on x-axis
//
- (void)scroll:(float)offset {
	texOffset = ccpAdd(texOffset, CGPointMake(offset, 0.0f));
	CGSize contentSize = texture_.contentSize;
	if (texOffset.x > contentSize.width) texOffset.x -= contentSize.width;
	if (texOffset.y > contentSize.height) texOffset.y -= contentSize.height;
	if (texOffset.x < 0) texOffset.x += contentSize.width;
	if (texOffset.y < 0) texOffset.y += contentSize.height;
}

- (void)scrollTest {
	[self scroll:0.3f];
}
@end
