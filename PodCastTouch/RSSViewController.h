//
//  RSSViewController.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 15..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;
@import UIKit;
@class GADBannerView;

@interface RSSViewController : UIViewController

@property (nonatomic, retain) NSMutableArray *rssDatas;
@property (nonatomic, retain) NSString *rssTitle;
@property (nonatomic, retain) UIImage         *thumb;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end
