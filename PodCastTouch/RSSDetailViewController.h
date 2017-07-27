//
//  RSSDetailViewController.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 15..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSData.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
@import GoogleMobileAds;
@import UIKit;
@class GADBannerView;

@interface RSSDetailViewController : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic, copy) NSString* rssTitle;
@property (nonatomic, retain) RSSData *rssData;

@property (nonatomic, retain) UIImage *thumb;
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end
