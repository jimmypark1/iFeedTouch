//
//  ViewController.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 14..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
@import GoogleMobileAds;
@import UIKit;
@class GADBannerView;

@interface ViewController : UIViewController <ADBannerViewDelegate>

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

