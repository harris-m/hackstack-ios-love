/**
 * Created by bio1712 for love2d
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 **/

#import "InterstitialDelegate.h"

@interface InterstitialDelegate ()

@end

@implementation InterstitialDelegate

#pragma mark - InterstitialDelegate

-(void)initProperties {
	printf("Creating Interstitial delegate\n");
	self.interstitialDidClose = false;
	self.interstitialFailedToLoad = false;
}

/// Called when an interstitial ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
	NSLog(@"interstitialDidReceiveAd");
}

/// Called when an interstitial ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
	NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
	self.interstitialFailedToLoad = true;
}

/// Called just before presenting an interstitial.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
	NSLog(@"interstitialWillPresentScreen");
	
}

/// Called before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
	NSLog(@"interstitialWillDismissScreen");
}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
	NSLog(@"interstitialDidDismissScreen");
	self.interstitialDidClose = true;
}

// Called just before the application will background or terminate because the user clicked on an ad
// that will launch another application (such as the App Store).
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
	NSLog(@"interstitialWillLeaveApplication");
	
}

@end
