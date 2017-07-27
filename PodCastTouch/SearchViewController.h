//
//  SearchViewController.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 18..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;
@import UIKit;
@class GADBannerView;

@interface SearchViewController : UITableViewController

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end
