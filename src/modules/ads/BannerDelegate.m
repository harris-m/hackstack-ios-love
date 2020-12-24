//
//  bannerViewDelegate.m
//  liblove
//
//  Created by bio1712 on 14/01/17.
//
//

#import "BannerDelegate.h"

@interface BannerDelegate ()

@end

@implementation BannerDelegate

// Called when an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

// Called when an ad request failed.
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
	NSLog(@"%s: %@", __PRETTY_FUNCTION__, error.localizedDescription);
}

// Called just before presenting the user a full screen view, such as a browser, in response to
// clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
}

// Called just before dismissing a full screen view.
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
}

// Called just after dismissing a full screen view.
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

// Called just before the application will background or terminate because the user clicked on an ad
// that will launch another application (such as the App Store).
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
