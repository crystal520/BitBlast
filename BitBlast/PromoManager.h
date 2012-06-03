//
//  PromoManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 4/22/12.
//  Copyright (c) 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPromoURL @"http://www.manuptimestudios.com/promos/gunrunner/current.plist"
//Use the one below to test Promos when the game is live.
//#define kPromoURL @"http://www.manuptimestudios.com/promos/testing/current.plist"

@interface PromoManager : NSObject <NSURLConnectionDataDelegate> {
	// unique identifier of the promo
	NSString *promoID;
	// reward for clicking through promo
	int incentive;
	// url to go to upon clicking through promo
	NSString *url;
	// data from the plist url request
	NSMutableData *promoData;
	// data from the icon url request
	NSMutableData *iconData;
	// dictionary to contain promo info
	NSMutableDictionary *promoDictionary;
	// connection for grabbing the plist
	NSURLConnection *plistConnection;
	// connection for grabbing the icon
	NSURLConnection *iconConnection;
}

+ (PromoManager*) sharedSingleton;
// actions
- (void) resume;
- (void) checkForPromo;

@end
