//
//  PromoManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 4/22/12.
//  Copyright (c) 2012 One Happy Giant. All rights reserved.
//

#import "PromoManager.h"
#import "BBDialogQueue.h"

@implementation PromoManager

+ (PromoManager*) sharedSingleton {
	
	static PromoManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[PromoManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
	}
	return self;
}

#pragma mark -
#pragma mark actions
- (void) resume {
	[self checkForPromo];
}

- (void) checkForPromo {
	// requst plist from URL
	plistConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kPromoURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30] delegate:self];
	[plistConnection start];
}

- (void) receivedPromo:(NSDictionary*)plist {
	promoDictionary = [[NSMutableDictionary alloc] initWithDictionary:plist];
	
	// make icon connection
	iconConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[promoDictionary objectForKey:@"icon"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30] delegate:self];
	[iconConnection start];
}

- (void) receivedImage:(CGImageRef)image {
	// pull data from plist
	NSString *title = [promoDictionary objectForKey:@"title"];
	NSString *message = [promoDictionary objectForKey:@"message"];
	NSString *buttons = [promoDictionary objectForKey:@"buttons"];
	incentive = [[promoDictionary objectForKey:@"incentive"] intValue];
	url = [[promoDictionary objectForKey:@"url"] retain];
	promoID = [[promoDictionary objectForKey:@"id"] retain];
	
	BOOL override = NO;
#if DEBUG_ALWAYS_SHOW_PROMO
	override = YES;
#endif
	
	// make sure player hasn't seen this promo
	if([[[SettingsManager sharedSingleton] getString:@"lastSeenPromo"] isEqualToString:promoID] && !override) {
		return;
	}
	else {
		BBDialog *promoDialog = [BBDialog dialogWithTitle:title text:message buttons:buttons target:self selector:@selector(promoCallback:)];
		[[BBDialogQueue sharedSingleton] addDialog:promoDialog];
		
		// turn CGImage into a sprite to add to the dialog
		CCSprite *icon = [CCSprite spriteWithCGImage:image key:nil];
		[promoDialog.container addChild:icon];
		
		// add incentive image and text if there is any
		if(incentive) {
			// create incentive image and text, position it, and add it to the dialog
			CCSprite *incentiveImage = [CCSprite spriteWithSpriteFrameName:@"oldCoin1.png"];
			incentiveImage.position = ccpMult(ccp(140, 100), [ResolutionManager sharedSingleton].positionScale);
			incentiveImage.anchorPoint = ccp(0, 0.5);
			[promoDialog.container addChild:incentiveImage];
			
			CCLabelBMFont *incentiveText = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"get %i", incentive] fntFile:@"gamefont.fnt"];
			incentiveText.color = ccc3(255, 215, 0);
			incentiveText.position = ccpMult(ccp(135, 100), [ResolutionManager sharedSingleton].positionScale);
			incentiveText.scale = 0.4;
			incentiveText.anchorPoint = ccp(1, 0.5);
			[promoDialog.container addChild:incentiveText];
			
			icon.position = ccpMult(ccp(-15.0f * incentiveText.string.length, 100), [ResolutionManager sharedSingleton].positionScale);
		}
		else {
			icon.position = ccp(icon.position.x, 100 * [ResolutionManager sharedSingleton].positionScale);
		}
	}
}

- (void) promoCallback:(BBDialog*)dialog {
	// save promo ID to device so player doesn't see this promo again
	[[SettingsManager sharedSingleton] setString:promoID keyString:@"lastSeenPromo"];
	[promoID release];
	// give incentive and go to URL
	if(dialog.buttonIndex == 1) {
		[[SettingsManager sharedSingleton] incrementInteger:incentive keyString:@"totalCoins"];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kEventPromoCoinsAwarded object:nil]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		[url release];
	}
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if(connection == plistConnection) {
		if(!promoData) {
			promoData = [[NSMutableData alloc] initWithLength:0];
		}
	}
	else if(connection == iconConnection) {
		if(!iconData) {
			iconData = [[NSMutableData alloc] initWithLength:0];
		}
	}
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if(connection == plistConnection) {
		[promoData appendData:data];
	}
	else if(connection == iconConnection) {
		[iconData appendData:data];
	}
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
	if(connection == plistConnection) {
		// turn promo data into a dictionary
		CFPropertyListRef plist = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)promoData, kCFPropertyListImmutable, NULL);
		
		if([(id)plist isKindOfClass:[NSDictionary class]]) {
			[self receivedPromo:[(NSDictionary*)plist autorelease]];
		}
		
		// free up plist data and connection
		[promoData release];
		promoData = nil;
		[plistConnection release];
		plistConnection = nil;
	}
	else if(connection == iconConnection) {
		// turn image data into an image
		CFDataRef imgData = (CFDataRef)iconData;
		CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData(imgData);
		CGImageRef image = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
		[self receivedImage:image];
		
		// free up image data and connection
		[iconData release];
		iconData = nil;
		[iconConnection release];
		iconConnection = nil;
	}
}

@end
