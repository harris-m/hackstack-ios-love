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

#import "VideoDelegate.h"

@interface VideoDelegate () <GADRewardBasedVideoAdDelegate>

@end

@implementation VideoDelegate

#pragma mark GADRewardBasedVideoDelegate implementation

- (void)initProperties {
	printf("Creating video delegate\n");
	self.rewardedAdDidFinish = false;
	self.rewardedAdDidStop = false;
	self.rewardType = @"???";
	self.rewardQuantity = 1.0;
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
	NSLog(@"Reward based video ad did receive");
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
	NSLog(@"Reward based video ad will leave application.");
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
	didFailToLoadWithError:(NSError *)error {
	NSLog(@"Reward based video ad failed to load.");
	NSLog(@"%@",[error localizedDescription]);
	self.rewardedAdFailedToLoad = true;
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
	NSString *rewardMessage =
	[NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
	 reward.type,
	 [reward.amount doubleValue]];
	NSLog(@"%@", rewardMessage);

	self.rewardedAdDidFinish = true;
	self.rewardQuantity = [reward.amount doubleValue];
	self.rewardType = reward.type;
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
	printf("User has closed the video.\n");
	self.rewardedAdDidStop = true;
}


@end

