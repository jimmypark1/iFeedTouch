//
//  VideoView.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 16..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "VideoView.h"
#import <KeepLayout.h>



@implementation VideoView
{
    id playbackObserver;
    AVPlayerLayer *playerLayer;
    BOOL viewIsShowing;
}
- (void)setVideoLayer:(AVPlayerLayer*)videoLayer
{
    _videoLayer = videoLayer;
    [self.layer addSublayer:_videoLayer];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    self.layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}
- (void)playerOfURL:(NSURL*)url
{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [playerLayer setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_player seekToTime:kCMTimeZero];
    [self.layer addSublayer:playerLayer];
    
    
    [_player play];
}

- (void)playerOfURL:(NSURL*)url frame:(CGRect)frame
{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [playerLayer setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_player seekToTime:kCMTimeZero];
    
    [self.layer addSublayer:playerLayer];
    
    [self initializePlayer:frame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
 //   [_player play];
}

-(void) setupConstraints
{
    
    // bottom HUD view
    self.playerHudBottom.keepHorizontalInsets.equal = KeepRequired(0);
    self.playerHudBottom.keepBottomInset.equal = KeepRequired(0);
    
    // play/pause button
    [self.playPauseButton keepHorizontallyCentered];
    [self.playPauseButton keepVerticallyCentered];
    
    // current time label
    self.playBackTime.keepLeftInset.equal = KeepRequired(5);
    [self.playBackTime keepVerticallyCentered];
    
    
    // progress bar
    self.progressBar.keepLeftOffsetTo(self.playBackTime).equal = KeepRequired(5);
    self.progressBar.keepBottomInset.equal = KeepRequired(0);
    [self.progressBar keepVerticallyCentered];
    
    // total time label
    self.playBackTotalTime.keepLeftOffsetTo(self.progressBar).equal = KeepRequired(5);
    [self.playBackTotalTime keepVerticallyCentered];
    
    // zoom button
    self.zoomButton.keepRightInset.equal = KeepRequired(5);
    [self.zoomButton keepVerticallyCentered];
    
    // airplay button
    self.airplayButton.keepRightOffsetTo(self.zoomButton).equal = KeepRequired(self.airplayButton.frame.size.width);
    self.airplayButton.keepLeftOffsetTo(self.playBackTotalTime).equal = KeepRequired(5);
    self.airplayButton.keepBottomInset.equal = KeepRequired(6);
    [self.airplayButton keepVerticallyCentered];
    
}

-(void)initializePlayer:(CGRect)frame
{
    int frameWidth =  frame.size.width;
    int frameHeight = frame.size.height;
    
    self.backgroundColor = [UIColor blackColor];
    viewIsShowing =  NO;
    
    [self.layer setMasksToBounds:YES];
    
    self.playerHudBottom = [[UIView alloc] init];
    self.playerHudBottom.frame = CGRectMake(0, 0, frameWidth, 25);
    [self.playerHudBottom setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.playerHudBottom];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0, 0, frameWidth, 48*frameHeight/160);
    bgView.backgroundColor = [UIColor blackColor];
    
    // Create the colors for our gradient.
    UIColor *transparent = [UIColor colorWithWhite:1.0f alpha:0.f];
    UIColor *opaque = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    // Create a masklayer.
    CALayer *maskLayer = [[CALayer alloc]init];
    maskLayer.frame = bgView.bounds;
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc]init];
    gradientLayer.frame = CGRectMake(0,0,bgView.bounds.size.width, bgView.bounds.size.height);
    gradientLayer.colors = @[(id)transparent.CGColor, (id)transparent.CGColor, (id)opaque.CGColor, (id)opaque.CGColor];
    gradientLayer.locations = @[@0.0f, @0.09f, @0.8f, @1.0f];
    
    // Add the mask.
    [maskLayer addSublayer:gradientLayer];
    bgView.layer.mask = maskLayer;
    
    [self.playerHudBottom addSubview:bgView];
    
    //Play Pause Button
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.playPauseButton.frame = CGRectMake(5*frameWidth/240, 6*frameHeight/160, 16*frameWidth/240, 16*frameHeight/160);
    [self.playPauseButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton setSelected:NO];
    [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"avplayer.bundle/playback_pause"] forState:UIControlStateSelected];
    [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"avplayer.bundle/playback_play"] forState:UIControlStateNormal];
    [self.playPauseButton setTintColor:[UIColor clearColor]];
    self.playPauseButton.layer.opacity = 0;
    [self addSubview:self.playPauseButton];
    
    //Seek Time Progress Bar
    self.progressBar = [[UISlider alloc] init];
    self.progressBar.frame = CGRectMake(0, 0, frameWidth, 15);
    [self.progressBar addTarget:self action:@selector(progressBarChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressBar addTarget:self action:@selector(proressBarChangeEnded:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.progressBar setThumbImage:[UIImage imageNamed:@"Slider_button"] forState:UIControlStateNormal];
    [self.playerHudBottom addSubview:self.progressBar];
    
    //Current Time Label
    self.playBackTime = [[UILabel alloc] init];
    [self.playBackTime sizeToFit];
    self.playBackTime.text = [self getStringFromCMTime:_player.currentTime];
    [self.playBackTime setTextAlignment:NSTextAlignmentLeft];
    [self.playBackTime setTextColor:[UIColor whiteColor]];
    self.playBackTime.font = [UIFont systemFontOfSize:12*frameWidth/240];
    [self.playerHudBottom addSubview:self.playBackTime];
    
    //Total Time label
    self.playBackTotalTime = [[UILabel alloc] init];
    [self.playBackTotalTime sizeToFit];
    self.playBackTotalTime.text = [self getStringFromCMTime:_player.currentItem.asset.duration];
    [self.playBackTotalTime setTextAlignment:NSTextAlignmentRight];
    [self.playBackTotalTime setTextColor:[UIColor whiteColor]];
    self.playBackTotalTime.font = [UIFont systemFontOfSize:12*frameWidth/240];
    [self.playerHudBottom addSubview:self.playBackTotalTime];
    
    // Airplay button
    self.airplayButton = [ [MPVolumeView alloc] init] ;
    [self.airplayButton setShowsVolumeSlider:NO];
    [self.airplayButton sizeToFit];
    [self.playerHudBottom addSubview:self.airplayButton];
    
    //zoom button
    UIImage *image = [UIImage imageNamed:@"avplayer.bundle/zoomin"];
    self.zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.zoomButton.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [self.zoomButton addTarget:self action:@selector(zoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.zoomButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.playerHudBottom addSubview:self.zoomButton];
    
    for (UIView *view in [self subviews]) {
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    CMTime interval = CMTimeMake(33, 1000);
    __weak __typeof(self) weakself = self;
    playbackObserver = [_player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
        CMTime endTime = CMTimeConvertScale (weakself.player.currentItem.asset.duration, weakself.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            double normalizedTime = (double) weakself.player.currentTime.value / (double) endTime.value;
            weakself.progressBar.value = normalizedTime;
        }
        weakself.playBackTime.text = [weakself getStringFromCMTime:weakself.player.currentTime];
    }];
    
    [self setupConstraints];
    [self showHud:NO];
}
-(void) showHud:(BOOL)show
{
    __weak __typeof(self) weakself = self;
    if(show) {
        CGRect frame = self.playerHudBottom.frame;
        frame.origin.y = self.bounds.size.height;
        
        [UIView animateWithDuration:0.3 animations:^{
            weakself.playerHudBottom.frame = frame;
            weakself.playPauseButton.layer.opacity = 0;
            viewIsShowing = show;
        }];
    } else {
        CGRect frame = self.playerHudBottom.frame;
        frame.origin.y = self.bounds.size.height-self.playerHudBottom.frame.size.height;
        
        [UIView animateWithDuration:0.3 animations:^{
            weakself.playerHudBottom.frame = frame;
            weakself.playPauseButton.layer.opacity = 1;
            viewIsShowing = show;
        }];
    }
}
-(NSString*)getStringFromCMTime:(CMTime)time
{
    Float64 currentSeconds = CMTimeGetSeconds(time);
    int mins = currentSeconds/60.0;
    int secs = fmodf(currentSeconds, 60.0);
    NSString *minsString = mins < 10 ? [NSString stringWithFormat:@"0%d", mins] : [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < 10 ? [NSString stringWithFormat:@"0%d", secs] : [NSString stringWithFormat:@"%d", secs];
    return [NSString stringWithFormat:@"%@:%@", minsString, secsString];
}

-(void)zoomButtonPressed:(UIButton*)sender
{
        [UIView animateWithDuration:0.5 animations:^{
            [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
        }];
    //    [self.delegate playerViewZoomButtonClicked:self];
}
-(void)setIsFullScreenMode:(BOOL)isFullScreenMode
{
    _isFullScreenMode = isFullScreenMode;
    if (isFullScreenMode) {
        self.backgroundColor = [UIColor blackColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

-(void)playerFinishedPlaying
{
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    [self.playPauseButton setSelected:NO];
    self.isPlaying = NO;
    if ([self.delegate respondsToSelector:@selector(playerFinishedPlayback:)]) {
        [self.delegate playerFinishedPlayback:self];
    }
}

-(void)playButtonAction:(UIButton*)sender
{
    if (self.isPlaying) {
        [self pause];
        //        [sender setSelected:NO];
    } else {
        [self play];
        //        [sender setSelected:YES];
    }
}

-(void)progressBarChanged:(UISlider*)sender
{
    if (self.isPlaying) {
        [_player pause];
    }
    CMTime seekTime = CMTimeMakeWithSeconds(sender.value * (double)self.player.currentItem.asset.duration.value/(double)self.player.currentItem.asset.duration.timescale, self.player.currentTime.timescale);
    [_player seekToTime:seekTime];
}

-(void)proressBarChangeEnded:(UISlider*)sender
{
    if (self.isPlaying) {
        [self.player play];
    }
}

-(void)volumeBarChanged:(UISlider*)sender
{
    [self.player setVolume:sender.value];
}

-(void)play
{
    [self.player play];
    self.isPlaying = YES;
    [self.playPauseButton setSelected:YES];
}

-(void)pause
{
    [self.player pause];
    self.isPlaying = NO;
    [self.playPauseButton setSelected:NO];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(playerLayer.frame, point)) {
        [self showHud:!viewIsShowing];
    }
}


-(void)dealloc
{
    [self.player removeTimeObserver:playbackObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
