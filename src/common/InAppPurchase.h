//
//  InAppPurchase.h
//  love
//
//  Created by Bruce Hill on 4/20/16.
//
//

#ifndef InAppPurchase_h
#define InAppPurchase_h

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface IAPResponder : UIResponder <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (void)restorePurchases;
- (IBAction)makePurchase:(NSString*) productIdentifier;
- (BOOL)queryPurchase:(NSString*) productIdentifier;

@end

#endif /* InAppPurchase_h */
