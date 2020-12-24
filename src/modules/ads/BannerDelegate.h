#ifndef BANNERDELEGATE_H
#define BANNERDELEGATE_H

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface BannerDelegate : UIResponder <GADBannerViewDelegate>
@property (nonatomic,strong) GADBannerView *bannerView;

@end
#endif
