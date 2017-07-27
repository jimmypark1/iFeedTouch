//
//  VideoView.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 16..
//  Copyright © 2016년 Junsoft. All rights reserved.
//
@import AVFoundation;
#import <MediaPlayer/MediaPlayer.h>

#import <UIKit/UIKit.h>

@class VideoView;

@protocol playerViewDelegate <NSObject>
@optional
-(void)playerViewZoomButtonClicked:(VideoView*)view;
-(void)playerFinishedPlayback:(VideoView*)view;

@end

@interface VideoView : UIView
@property (assign, nonatomic) id <playerViewDelegate> delegate;

@property (nonatomic, strong) AVPlayerLayer *videoLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (retain, nonatomic) UIButton *playPauseButton;
@property (retain, nonatomic) UIButton *volumeButton;
@property (retain, nonatomic) UIButton *zoomButton;
@property (retain, nonatomic) MPVolumeView *airplayButton;

@property (retain, nonatomic) UISlider *progressBar;
@property (retain, nonatomic) UISlider *volumeBar;

@property (retain, nonatomic) UILabel *playBackTime;
@property (retain, nonatomic) UILabel *playBackTotalTime;

@property (retain,nonatomic) UIView *playerHudCenter;
@property (retain,nonatomic) UIView *playerHudBottom;


@property (assign, nonatomic) BOOL isFullScreenMode;
@property (assign, nonatomic) BOOL isPlaying;

- (void)playerOfURL:(NSURL*)url;
-(void)initializePlayer:(CGRect)frame;
- (void)playerOfURL:(NSURL*)url frame:(CGRect)frame;

@end
