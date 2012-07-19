//
//  IAPManager.m
//  GunRunner
//
//  Created by Kristian Bauer on 3/17/12.
//  Copyright 2012 Man Up Time Studios. All rights reserved.
//

#import "IAPManager.h"


@implementation IAPManager

+ (IAPManager*) sharedSingleton {
	
	static IAPManager *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[IAPManager alloc] init];
		
		return sharedSingleton;
	}
	return nil;
}

- (id) init {
	if((self = [super init])) {
		// get info about the IAP from apple
		[self requestIAP];
		// listen for updates to the payment queue
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}

#pragma mark -
#pragma mark getters
- (NSArray*) getProducts {
	if(cachedResponse && cachedResponse.products) {
		return cachedResponse.products;
	}
	return nil;
}

#pragma mark -
#pragma mark actions
- (void) requestIAP {
	// make set of product IDs
	NSMutableSet *productIDs = [NSMutableSet setWithObjects:@"com.manuptimestudios.gunrunner.cashpack1", @"com.manuptimestudios.gunrunner.cashpack2", @"com.manuptimestudios.gunrunner.cashpack3", nil];
	// make the request using the product IDs
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDs];
	request.delegate = self;
	[request start];
	[request release];
	// set timeout
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(requestTimeout) forTarget:self interval:30 paused:NO];
}

- (void) requestTimeout {
	// make sure this function doesn't continue to get called
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(requestTimeout) forTarget:self];
	// no response from apple yet, so just fail the product request
	[self productsRequest:nil didReceiveResponse:nil];
}

- (void) startTransaction:(NSString*)productID {
	// check to make sure IAP is enabled on device
	if([SKPaymentQueue canMakePayments]) {
		// TODO: show dialog letting player know that we're contacting the server
		// add payment to queue
		[[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProductIdentifier:productID]];
	}
	// IAP disabled
	else {
		// TODO: dialog telling player iap is disabled in their device settings
	}
}

#pragma mark -
#pragma mark SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	if(response && response.products && [response.products count] > 0) {
		// cache result for later
		if(cachedResponse) {
			[cachedResponse release];
		}
		cachedResponse = [response retain];
	}
	else {
		NSLog(@"Error requesting IAP");
	}
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	// loop through transactions
	for(int i=0,j=[transactions count];i<j;i++) {
		// get current transaction
		SKPaymentTransaction *trans = [transactions objectAtIndex:i];
		// if the transaction is completed
		if([trans transactionState] == SKPaymentTransactionStatePurchased) {
			// get product identifier
			NSString *productID = [[trans payment] productIdentifier];
			BOOL validProduct = NO;
			// check against the game's product IDs
			if([productID isEqualToString:@"com.manuptimestudios.gunrunner.cashpack1"]) {
				[[SettingsManager sharedSingleton] incrementInteger:1000 keyString:@"totalCoins"];
				validProduct = YES;
			}
			else if([productID isEqualToString:@"com.manuptimestudios.gunrunner.cashpack2"]) {
				[[SettingsManager sharedSingleton] incrementInteger:10000 keyString:@"totalCoins"];
				validProduct = YES;
			}
			else if([productID isEqualToString:@"com.manuptimestudios.gunrunner.cashpack3"]) {
				[[SettingsManager sharedSingleton] incrementInteger:100000 keyString:@"totalCoins"];
				validProduct = YES;
			}
			else if([productID isEqualToString:@"com.manuptimestudios.gunrunner.tip"]) {
				validProduct = YES;
			}
			// make sure it was a valid product
			if(validProduct) {
				[queue finishTransaction:trans];
				[[SettingsManager sharedSingleton] saveToFile:@"player.plist"];
				// TODO: dialog - thank you for your purchase!
			}
		}
		// if the transaction was cancelled
		else if([trans transactionState] == SKPaymentTransactionStateFailed) {
			// TODO: dialog - purchase cancelled
			[queue finishTransaction:trans];
		}
	}
}

#pragma mark -
#pragma mark SKRequestDelegate
- (void) request:(SKRequest *)request didFailWithError:(NSError *)error {
	// TODO: dialog - store currently unavailable
}

@end
