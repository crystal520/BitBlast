//
//  IAPManager.h
//  GunRunner
//
//  Created by Kristian Bauer on 3/17/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <StoreKit/StoreKit.h>
#import "SettingsManager.h"

@interface IAPManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate> {
	// cached response from apple so store can be loaded immediately
    SKProductsResponse *cachedResponse;
}

+ (IAPManager*) sharedSingleton;
// getters
- (NSArray*) getProducts;
// actions
- (void) requestIAP;
- (void) startTransaction:(NSString*)productID;

@end
