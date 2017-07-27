
//
//  RSSDetailViewController.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 15..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "RSSDetailViewController.h"
#import "STKAudioPlayer.h"
#import "VideoView.h"
#import <iAd/iAd.h>
#import <Social/Social.h>

#import <Accounts/Accounts.h>
#import "NMRangeSlider.h"
#import <iAd/iAd.h>
#import "Chameleon.h"

@interface RSSDetailViewController ()<GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>
{
    __weak IBOutlet UITextView *desc;
    __weak IBOutlet UISlider *slider;
    __weak IBOutlet UIButton* playButton;
    __weak IBOutlet UILabel* label;
    __weak IBOutlet UIButton* shareButton;
    
    
    STKAudioPlayer* audioPlayer;
  //  AVAudioPlayer   *_audioPlayer;
    NSString *_path;
    AVPlayer *_audioPlayer;
    NSTimer  *timer;
    AVPlayerItem   *playerItem;
    AVPlayer *player;
    ADBannerView    *bannerView;
}
@end

@implementation RSSDetailViewController

-(void) setupTimer
{
    timer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void) tick
{
    if (!audioPlayer)
    {
        slider.value = 0;
     //   label.text = @"";
     //   statusLabel.text = @"";
        
        return;
    }
    
    if (audioPlayer.currentlyPlayingQueueItemId == nil)
    {
        slider.value = 0;
        slider.minimumValue = 0;
        slider.maximumValue = 0;
        
     //   label.text = @"";
        
        return;
    }
    
    if (audioPlayer.duration != 0)
    {
        slider.minimumValue = 0;
        slider.maximumValue = audioPlayer.duration;
        slider.value = audioPlayer.progress;
        
        label.text = [NSString stringWithFormat:@"%@ - %@", [self formatTimeFromSeconds:audioPlayer.progress], [self formatTimeFromSeconds:audioPlayer.duration]];
    }
    else
    {
        slider.value = 0;
        slider.minimumValue = 0;
        slider.maximumValue = 0;
        
        label.text =  [NSString stringWithFormat:@"Live stream %@", [self formatTimeFromSeconds:audioPlayer.progress]];
    }
    
  //  statusLabel.text = audioPlayer.state == STKAudioPlayerStateBuffering ? @"buffering" : @"";
    
    CGFloat newWidth = 320 * (([audioPlayer averagePowerInDecibelsForChannel:1] + 60) / 60);
    
    //meter.frame = CGRectMake(0, 460, newWidth, 20);
}

-(void) updateControls
{
    if (audioPlayer == nil)
    {
        [playButton setTitle:@"" forState:UIControlStateNormal];
    }
    else if (audioPlayer.state == STKAudioPlayerStatePaused)
    {
      //  [playButton setTitle:@"Resume" forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
  }
    else if (audioPlayer.state & STKAudioPlayerStatePlaying)
    {
     //   [playButton setTitle:@"Pause" forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];

    }
    else
    {
        [playButton setTitle:@"" forState:UIControlStateNormal];
    }
    
    [self tick];
}
-(NSString*) formatTimeFromSeconds:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    [self updateControls];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    [self updateControls];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    /*
    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
    
    NSLog(@"Started: %@", [queueId.url description]);
    
       */
    [self updateControls];
    
}


-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    /*
    [self updateControls];
    
    // This queues on the currently playing track to be buffered and played immediately after (gapless)
    
    if (repeatSwitch.on)
    {
        SampleQueueId* queueId = (SampleQueueId*)queueItemId;
        
        NSLog(@"Requeuing: %@", [queueId.url description]);
        
        [self->audioPlayer queueDataSource:[STKAudioPlayer dataSourceFromURL:queueId.url] withQueueItemId:[[SampleQueueId alloc] initWithUrl:queueId.url andCount:queueId.count + 1]];
    }
     */
    [self updateControls];
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    /*
    [self updateControls];
    
    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
    
    NSLog(@"Finished: %@", [queueId.url description]);
     */
}

-(void) audioPlayer:(STKAudioPlayer *)audioPlayer logInfo:(NSString *)line
{
    NSLog(@"%@", line);
}

-(void) playButtonPressed
{
    if (!audioPlayer)
    {
        return;
    }
    
    if (audioPlayer.state == STKAudioPlayerStatePaused)
    {
        [audioPlayer resume];
    }
    else
    {
        [audioPlayer pause];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.topItem.title = @"";
    self.title = _rssTitle;

}

- (void)customSlider
{
    /*
     UIImage *minImage = [[UIImage imageNamed:@"slider_minimum.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
     UIImage *maxImage = [[UIImage imageNamed:@"slider_maximum.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
     UIImage *thumbImage = [UIImage imageNamed:@"sliderhandle.png"];
     
     [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
     [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
     [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];

     */
    UIImage *minImage = [[UIImage imageNamed:@"slider-track-fill.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *maxImage = [UIImage imageNamed:@"slider-track.png"];
    UIImage *thumbImage = [UIImage imageNamed:@"slider-cap.png"];
    
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
}

- (void)addBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-7915959670508279/2709107179";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    
    [self.bannerView loadRequest:request];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    [self addBanner];
  
    [self customSlider];
    UIImage *faceImage = [UIImage imageNamed:@"share2"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 10, 0, faceImage.size.width, faceImage.size.height );//set bound as per you want
    [face addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    
    if( [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
        self.navigationItem.rightBarButtonItem = backButton;
   
    
    NSArray *colors = @[FlatBlueDark, FlatBlueDark, FlatNavyBlueDark, FlatNavyBlue];
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
                                                      withFrame:self.view.frame
                                                      andColors:colors];
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
                                                           withFrame:self.view.frame
                                                           andColors:colors];
    
    
    /*
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2048, 2048)];
    backgroundView.image = [UIImage imageNamed:@"rain2"];
    backgroundView.layer.zPosition = -1;
    [self.view addSubview:backgroundView];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = CGRectMake(0, 0, 2048, 2048);
    */
   // [self.view addSubview:visualEffectView];

    desc.backgroundColor = [UIColor clearColor];
    desc.textColor = [UIColor whiteColor]
    ;
    playButton.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:desc];
    [self.view addSubview:slider];
    [self.view addSubview:playButton];
    [self.view addSubview:label];
 
    
    self.title = _rssTitle;
  //  desc.font = [UIFont systemFontOfSize:16];
    desc.textColor = [UIColor whiteColor];
    
    if(![_rssData.summary isEqualToString:@"[No Summary]"])
        desc.text = _rssData.summary;
    
    
    if( [_rssData.type containsString:@"mp3"] ||
       [_rssData.enclosures containsString:@"mp3"])
    {
        [playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
        audioPlayer.meteringEnabled = YES;
        audioPlayer.delegate = self;
        
        slider.continuous = YES;
        [slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
        [self setupTimer];
        
        [audioPlayer play:_rssData.enclosures];
        [self updateControls];
    }
    else if([_rssData.type containsString:@"video"]||
            [_rssData.enclosures containsString:@"mp4"])
    {
        playButton.hidden = YES;
        slider.hidden = YES;
        label.hidden = YES;
        [self playMovie:_rssData.enclosures];
        //playMovie
    }
    /*
    bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    bannerView.delegate = self;
    self.canDisplayBannerAds = YES;
    bannerView.alpha = 0.0;
     */

  
}

- (void)share
{
    [self postFeedText:_rssData.summary image:_thumb url:[NSURL URLWithString:_rssData.enclosures]];

}

-(void) sliderChanged
{
    if (!audioPlayer)
    {
        return;
    }
    
    NSLog(@"Slider Changed: %f", slider.value);
    
    [audioPlayer seekToTime:slider.value];
}


- (void)playAudio:(NSString*)strURL
{
    NSURL *url = [NSURL URLWithString:strURL];
    _audioPlayer = [[AVPlayer alloc] initWithURL:url];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_audioPlayer currentItem]];
   
    [_audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (_audioPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
        } else if (_audioPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [_audioPlayer play];
            
            
        } else if (_audioPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next sound file
    
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [audioPlayer stop];
   
    
    self.navigationController.navigationBar.topItem.title = _rssTitle;
    
    
}

- (void)playMovie:(NSString*)strURL
{
  //  [VideoPlayerKit initWithContainingViewController:optionalTopView:hideTopViewWithControls:];
    NSURL *url = [NSURL URLWithString:strURL];

    AVPlayerViewController *avVideoController = [[AVPlayerViewController alloc] init];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    avVideoController.showsPlaybackControls = YES;
    
    avVideoController.player = player;
     [self presentViewController:avVideoController animated:YES completion:^{
        
        //Play the preroll ad
        [avVideoController playPrerollAdWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            }
            [avVideoController.player play];
        }];
        
    }];
  
}

- (void)postFeedText:(NSString*)text image:(UIImage*)image url:(NSURL*)url
{
    /*
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [composeViewController setInitialText:text];
    if(image)
        [composeViewController addImage:image];
 
    [composeViewController addURL:url];
    
    [self presentViewController:composeViewController animated:YES completion:nil];
    
    */
  //  NSMutableArray *array = [[NSMutableArray alloc] init];
 //   if(text)
  //      [array addObject:text];
   /*
    if(image)
        [array addObject:image];
    if(url)
        [array addObject:url];
    */
    
    NSString *apiEndpoint = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",[url absoluteString]];
    NSString *shortURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpoint]
                                                  encoding:NSASCIIStringEncoding
                                                     error:nil];

    
    NSArray * shareItems = @[ image, self.title,[NSURL URLWithString:shortURL]];
    
    UIActivity *activity = [[UIActivity alloc] init];
    
    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:shareItems, nil];
   
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];

    
    [self presentViewController:avc animated:YES completion:nil];

    
}
@end
