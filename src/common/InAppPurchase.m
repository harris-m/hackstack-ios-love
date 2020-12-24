//
//  InAppPurchase.m
//  love
//
//  Created by Bruce Hill on 4/20/16.
//
//

#import "InAppPurchase.h"
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@implementation IAPResponder

- (void)restorePurchases
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@[] forKey:@"purchases"];
	SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
	[paymentQueue addTransactionObserver:self];
	[paymentQueue restoreCompletedTransactions];
}

- (IBAction)makePurchase:(NSString*) productIdentifier
{
	NSLog(@"User requests purchase");
	
	if([SKPaymentQueue canMakePayments]){
		NSLog(@"User can make payments");
		
		SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productIdentifier]];
		productsRequest.delegate = self;
		[productsRequest start];
	}
	else{
		NSLog(@"User cannot make payments due to parental controls");
		//this is called the user cannot make payments, most likely due to parental controls
	}
}

- (BOOL)queryPurchase:(NSString *)productIdentifier
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *purchases = [defaults arrayForKey:@"purchases"];
	if (!purchases) {
		return NO;
	} else {
		return [purchases containsObject:productIdentifier];
	}
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
#pragma unused(request)
	SKProduct *validProduct = nil;
	NSUInteger count = [response.products count];
	if(count > 0){
		validProduct = [response.products objectAtIndex:0];
		NSLog(@"Products Available!");
		SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
		SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
		[paymentQueue addTransactionObserver:self];
		[paymentQueue addPayment:payment];
	}
	else if(!validProduct){
		NSLog(@"No products available");
		//this is called if your product id is not valid, this shouldn't be called unless that happens.
	}
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
	for(SKPaymentTransaction *transaction in queue.transactions){
		if(transaction.transactionState == SKPaymentTransactionStateRestored){
			//called when the user successfully restores a purchase
			NSLog(@"Transaction state -> Restored");
			[queue finishTransaction:transaction];
			break;
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for(SKPaymentTransaction *transaction in transactions){
		switch(transaction.transactionState){
			case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
				//called when the user is in the process of purchasing, do not add any of your own code here.
				break;
			case SKPaymentTransactionStatePurchased:
				//this is called when the user has successfully purchased the package (Cha-Ching!)
				[self markOwned:transaction.payment.productIdentifier];
				[queue finishTransaction:transaction];
				NSLog(@"Transaction state -> Purchased");
				break;
			case SKPaymentTransactionStateRestored:
				[self markOwned:transaction.payment.productIdentifier];
				NSLog(@"Transaction state -> Restored");
				//add the same code as you did from SKPaymentTransactionStatePurchased here
				[queue finishTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				//called when the transaction does not finish
				if(transaction.error.code == SKErrorPaymentCancelled){
					NSLog(@"Transaction state -> Cancelled");
					//the user cancelled the payment ;(
				}
				[queue finishTransaction:transaction];
				break;
			case SKPaymentTransactionStateDeferred:
				NSLog(@"Transaction state -> Deferred");
				[queue finishTransaction:transaction];
				break;
				
		}
	}
	
}

- (void)markOwned:(NSString*)productIdentifier
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *purchases = [defaults arrayForKey:@"purchases"];
	[defaults setObject:[purchases arrayByAddingObject:productIdentifier] forKey:@"purchases"];
	[defaults synchronize];
}

@end
