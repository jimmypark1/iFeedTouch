//
//  FavoriteViewController.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 20..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;
@import UIKit;
@class GADBannerView;

@interface FavoriteViewController : UIViewController
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end
