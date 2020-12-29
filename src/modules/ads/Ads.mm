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

// LOVE
#include "common/config.h"
#include "Ads.h"

#if defined(LOVE_MACOSX)
#include <CoreServices/CoreServices.h>
#elif defined(LOVE_IOS)
#include "common/ios.h"
#elif defined(LOVE_LINUX) || defined(LOVE_ANDROID)
#include <signal.h>
#include <sys/wait.h>
#include <errno.h>
#elif defined(LOVE_WINDOWS)
#include "common/utf8.h"
#include <shlobj.h>
#include <shellapi.h>
#pragma comment(lib, "shell32.lib")
#endif
#if defined(LOVE_ANDROID)
#include "common/android.h"
#elif defined(LOVE_LINUX)
#include <spawn.h>
#endif

// SDL

//Objc
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <AudioToolbox/AudioServices.h>

#include <GoogleMobileAds/GoogleMobileAds.h>

#import "ads/VideoDelegate.h"

#import "ads/InterstitialDelegate.h"

#import "ads/BannerDelegate.h"

namespace love
{
namespace ads
{
	
	
GADBannerView * bannerView;
BannerDelegate * bannerDel;
	
GADInterstitial *interstitialAd;
InterstitialDelegate *interstitialDel;
	
GADRewardBasedVideoAd *videoAd;
VideoDelegate *videoDel;

GADExtras *requestExtras = [[GADExtras alloc] init];
	
		
Ads::Ads()
{
	this->privacyURL = [NSURL URLWithString:@"https://tunks.games/hackstack-privacy-policy/"];
	this->applicationID = @"ca-app-pub-2848378799294763~6518961681";
	this->publisherID = @"pub-2848378799294763"; //Your publisher ID
	this->collectConsent = false;
	
	[[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
	
	GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers =
	@[ @"Simulator" ];
	
	//Consent
	if (this->collectConsent)
	{
		consentForm = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:this->privacyURL];
		consentForm.shouldOfferPersonalizedAds = YES;
		consentForm.shouldOfferNonPersonalizedAds = YES;
		consentForm.shouldOfferAdFree = NO;
	
		[PACConsentInformation.sharedInstance
		 requestConsentInfoUpdateForPublisherIdentifiers:@[ this->publisherID ]
		 completionHandler:^(NSError *_Nullable error) {
			 if (error) {
				 // Consent info update failed.
				 printf("Consent info update failed\n");
			 } else {
				 // Consent info update succeeded. The shared PACConsentInformation
				 // instance has been updated.
				 printf("Consent info update succeeded\n");
				 if (PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown == NO)
				 {
					 printf("User is not in Europe, no need to present the consent form.\n");
					 this->statusConsent = "Personalized";
				 }
				 else
				 {
					 if (PACConsentInformation.sharedInstance.consentStatus == PACConsentStatusUnknown) {
						 this->loadConsentForm();
					 }
				 }
			 }
		}];
	}
	else
	{
		this->statusConsent = "Personalized";
		requestExtras = [[GADExtras alloc] init];
	}
	
	printf("GAD SDK Version: %s\n",GoogleMobileAdsVersionString);
}
	
void Ads::test() const {
	printf("ADS_TEST\n");
}
	
void Ads::loadConsentForm() {
	[consentForm loadWithCompletionHandler:^(NSError *_Nullable error) {
		NSLog(@"Load complete. Error: %@", error);
		if (error) {
			// Handle error.
		} else {
			// Load successful.
			[consentForm presentFromViewController:getRootViewController()
			  dismissCompletion:^(NSError *_Nullable error, BOOL userPrefersAdFree) {
				  if (error) {
					  // Handle error.
				  } else if (userPrefersAdFree) {
					  // The user prefers to use a paid version of the app.
				  } else {
					  // Check the user's consent choice.
					  requestExtras = [[GADExtras alloc] init];
					  PACConsentStatus status = PACConsentInformation.sharedInstance.consentStatus;
					  const char* s = (status == PACConsentStatusNonPersonalized ? "Non personalized" : "Personalized" );
					  printf("Consent status: %s",s);
					  this->statusConsent = s;
					  if (status == PACConsentStatusNonPersonalized) {
						  requestExtras.additionalParameters = @{@"npa": @"1"};
					  }
				  }
			  }];
		}
	}];
}
	
UIViewController * Ads::getRootViewController()
{
	static auto win = Module::getInstance<window::sdl::Window>(Module::M_WINDOW);
	
	
	SDL_Window *window = win-> getWindowObj();
	SDL_SysWMinfo systemWindowInfo;
	SDL_VERSION(&systemWindowInfo.version);
	if ( ! SDL_GetWindowWMInfo(window, &systemWindowInfo)) {
		printf("Error 0\n");
	}
	UIWindow * appWindow = systemWindowInfo.info.uikit.window;
	UIViewController * rootViewController = appWindow.rootViewController;
		
	return rootViewController;
}

void Ads::createBanner(const char *adID, const char *position) {
	
	if (hasBannerBeenCreated)
	{
		printf("Skipping banner creation! Banner has already been created!\n");
		return;
	}
	
	if (strcmp(adID,"TOP_SECRET") == 0)
	{
		adID = "ca-app-pub-3940256099942544/2934735716"; //Eventually to hide your ad ID
	}
	
	printf("Creating banner with adID= ");
	printf("%s", adID);
	printf(" position= %s\n",position);
	
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGFloat screenHeight = screenRect.size.height;
	CGFloat screenWidth = screenRect.size.width;
	
	//Safe area portrait
	if (screenHeight == 812.0 || screenHeight == 896.0 || screenHeight == 2388.0 || screenHeight == 1366.0)
	{
		screenHeight = screenHeight - 34.0;
	}
	else if (screenWidth == 812.0 || screenWidth == 896.0 || screenWidth == 2388.0 || screenWidth == 1366.0) //Safe area landscape
	{
		screenHeight = screenHeight - 21.0;
	}
	printf("Screen Height: %f\n",screenHeight);
	
	
	
	if (screenWidth > screenHeight)
	{
		bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
	}
	else
	{
		bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
	}
	
	//ADAPTIVE BANNER
	//bannerView = [[GADBannerView alloc] initWithAdSize:GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(screenWidth)];
	
	
	
	if (strcmp("bottom",position) == 0)
	{
		[bannerView setFrame:CGRectMake(screenWidth/2-bannerView.frame.size.width/2,screenHeight-bannerView.frame.size.height, bannerView.frame.size.width, bannerView.frame.size.height)];
	}
	else //TOP
	{
		[bannerView setFrame:CGRectMake(screenWidth/2-bannerView.frame.size.width/2, 0, bannerView.frame.size.width, bannerView.frame.size.height)];
	}
	
	bannerView.adUnitID = @(adID);
	
	
	UIViewController *VC = getRootViewController();
	bannerView.rootViewController = VC;
	
	bannerDel = [[BannerDelegate alloc] init];
	bannerView.delegate = bannerDel;
	
	GADRequest *request = [GADRequest request];
	
	[request registerAdNetworkExtras:requestExtras];
	
	[bannerView loadRequest:request];
	
	hasBannerBeenCreated = true;
}
	

void Ads::hideBanner()
{
	if (hasBannerBeenCreated)
	{
		[bannerView removeFromSuperview];
	}
	else
	{
		printf("Cannot hide banner: No banner has been created yet.\n");
	}
}
	
void Ads::showBanner()
{
	if (hasBannerBeenCreated)
	{
		UIViewController *VC = getRootViewController();
		[VC.view addSubview:bannerView];
	}
	else
	{
		printf("Cannot show banner: No banner has been created yet.\n");
	}
}
	
void Ads::requestInterstitial(const char *adID) {
	
	if (strcmp(adID,"TOP_SECRET") == 0)
	{
		adID = "ca-app-pub-3940256099942544/4411468910"; //Eventually to hide your ad ID
	}
	
	if (!adID)
	{
		printf("Interstitial ad unit ID is not valid.\n");
		return;
	}
	
	NSString *adUnitID = @(adID);
	interstitialAd = [[GADInterstitial alloc] initWithAdUnitID:adUnitID];
	
	interstitialDel = [[InterstitialDelegate alloc] init];
	
	interstitialAd.delegate = interstitialDel;
	[interstitialDel initProperties];
	
	GADRequest *intRequest = [GADRequest request];

	
	[intRequest registerAdNetworkExtras:requestExtras];
	[interstitialAd loadRequest:intRequest];
	

	
	return;
}
	
void Ads::showInterstitial()
{
	if (interstitialAd.isReady)
	{
		UIViewController *cont = getRootViewController();
		[interstitialAd presentFromRootViewController:cont];
		printf("Showing interstitial ad\n");
	}
	else
	{
		printf("Cannot show intersitial: Ad is not ready or has not been requested yet.\n");
	}
	
	return;
}

bool Ads::isInterstitialLoaded()
{
	return interstitialAd.isReady;
}
	
void Ads::requestRewardedAd(const char *adID) {
	
	if (strcmp(adID,"TOP_SECRET") == 0)
	{
		adID = "ca-app-pub-3940256099942544/1712485313"; //Eventually to hide your ad ID
	}
	
	NSString *adUnitID = @(adID);
	
	videoDel = [[VideoDelegate alloc] init];
	GADRequest *request = [GADRequest request];
	
	GADExtras *extras = [[GADExtras alloc] init];
	if (this->statusConsent == "Non personalized") {
		
		extras.additionalParameters = @{@"npa": @"1"};
	}
	
	
	[GADRewardBasedVideoAd sharedInstance].delegate =  videoDel;
	
	[request registerAdNetworkExtras:extras];
	
	[[GADRewardBasedVideoAd sharedInstance] loadRequest:request
										   withAdUnitID:adUnitID];
	[videoDel initProperties];
	
	
	if([[GADRewardBasedVideoAd sharedInstance].delegate respondsToSelector:@selector(rewardBasedVideoAdWillLeaveApplication:)]) {
		[[GADRewardBasedVideoAd sharedInstance].delegate rewardBasedVideoAdWillLeaveApplication:[GADRewardBasedVideoAd sharedInstance]];
	}
	return;
}
	
bool Ads::isRewardedAdLoaded()
{
	if ([GADRewardBasedVideoAd sharedInstance].isReady)
	{
		return true;
	}
	else
	{
		return false;
	}
}
	
void Ads::showRewardedAd()
{
	if (this->isRewardedAdLoaded())
	{
		UIViewController *cont = getRootViewController();
		[[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:cont];
		printf("Showing rewarded ad\n");
	}
	else
	{
		printf("Cannot show rewarded ad: Ad is not ready or has not been requested yet.\n");
	}
	
}
	
void Ads::changeEUConsent()
{
	if (PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown == NO)
	{
		printf("User is not in Europe, no need to present the consent form.\n");
		this->statusConsent = "Personalized";
		return;
	}
	else
	{
		NSLog(@"Request location: %d",PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown);
	}
	consentForm = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:privacyURL];
	consentForm.shouldOfferPersonalizedAds = YES;
	consentForm.shouldOfferNonPersonalizedAds = YES;
	consentForm.shouldOfferAdFree = NO;
	this->loadConsentForm();
}
	
//Private functions for callbacks
	
bool Ads::coreInterstitialError()
{ //Interstitial has failed to load
	if (interstitialDel.interstitialFailedToLoad) {
		interstitialDel.interstitialFailedToLoad = false; //reset property
		return true;
	}
	return false;
}
	
bool Ads::coreInterstitialClosed()
{ //Interstitial has been closed by user

	if (interstitialDel.interstitialDidClose) {
		interstitialDel.interstitialDidClose = false; //reset property
		return true;
	}
	return false;
}
	
bool Ads::coreRewardedAdError()
{ //Video has failed to load
	if (videoDel.rewardedAdFailedToLoad) {
		videoDel.rewardedAdFailedToLoad = false; //reset property
		return true;
	}
	return false;
}
	
bool Ads::coreRewardedAdDidFinish()
{ //Video has finished playing
	if (videoDel.rewardedAdDidFinish)
	{
		videoDel.rewardedAdDidFinish = false; //reset property
		return true;
	}
	return false;
}
	
std::string Ads::coreGetRewardType()
{ //Get reward type
	if (videoDel.rewardType)
	{
		std::string ret = [videoDel.rewardType UTF8String];
		return ret;
	}
	else
	{
		return "???";
	}
}
	
double Ads::coreGetRewardQuantity()
{ //Get reward qty
	if (videoDel.rewardQuantity)
	{
		return videoDel.rewardQuantity;
	}
	else
	{
		return 1.0;
	}
}
	
bool Ads::coreRewardedAdDidStop()
{ //Ad stopped by user
	if (videoDel.rewardedAdDidStop)
	{
		videoDel.rewardedAdDidStop = false; //reset property
		return true;
	}
	return false;
}
	
std::string Ads::getDeviceLanguage()
{
	//NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
	//NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
	
	NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
	NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
	NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
	languageCode  = [languageCode uppercaseString];
	
	return std::string([languageCode UTF8String]);
}
		
} // ads
} // love
