//
//  ViewController.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 14..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "ViewController.h"
#import "EditViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "Feeds.h"
#import "MWFeedParser.h"
#import "RSSViewController.h"
#import "RSSData.h"
#import "ShapeImageView.h"
#import "DBController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface ViewController ()<GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>
{
    __weak IBOutlet UICollectionView    *editCollectionView;
    __weak IBOutlet UIView              *backView;
    
    ADBannerView        *bannerView;
    NSMutableArray *_feeds;
    NSMutableArray *_rssDatas;
    Feeds           *_feedDatas;
    MWFeedParser    *_feedParser;
    RSSData         *_rssData;
    NSString        *_selectedTitle;
    BOOL             _bannerIsVisible;
    NSMutableDictionary *_imgDict;

}
@end

@implementation ViewController

- (void)drawBannerViewForAdMob
{
    self.bannerView.adUnitID = @"ca-app-pub-2367841846534648/4638055615";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];   // [self.view addSubview:self.bannerView];

}

- (void)search
{
    [self performSegueWithIdentifier:@"common_search" sender:nil];
    
}
- (void)favorite
{
    //
    [self performSegueWithIdentifier:@"common_favorite" sender:nil];

}
- (void)addBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-7915959670508279/2709107179";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    //ca8f54d4f237c1f1f447db562e6b991f97803261
//    request.testDevices = @[ kGADSimulatorID ];
  //  request.testDevices = @[ kGADSimulatorID,                       // All simulators
  //                           @"AC98C820A50B4AD8A2106EDE96FB87D4" ]; // Sample device ID
    [self.bannerView loadRequest:request];

}
- (void)viewDidLoad {
    [super viewDidLoad];
//    editCollectionView.backgroundColor = [UIColor clearColor];

    [self addBanner];
    /////
    UIImage *faceImage = [UIImage imageNamed:@"tool"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 10, 0, faceImage.size.width, faceImage.size.height );//set bound as per you want
    [face addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.rightBarButtonItem = backButton;
    
    
    UIImage *leftImage = [UIImage imageNamed:@"favorite"];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.bounds = CGRectMake( 10, 0, leftImage.size.width, leftImage.size.height );//set bound as per you want
    [left addTarget:self action:@selector(favorite) forControlEvents:UIControlEventTouchUpInside];
    [left setImage:leftImage forState:UIControlStateNormal];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    ////
    
    
    editCollectionView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rain2"]];

    
   // self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"metal"]];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.contentMode = UIViewContentModeScaleToFill;
    visualEffectView.frame =  CGRectMake(0, 0, 2048, self.view.bounds.size.height);;
    //[self.view addSubview:visualEffectView];
    [editCollectionView.backgroundView addSubview:visualEffectView];
    //editCollectionView.alpha = 0;
    self.title = @"iFeed Touch";
    /*
    bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    bannerView.delegate = self;
    self.canDisplayBannerAds = YES;
    bannerView.alpha = 0.0;
    */
    [editCollectionView registerClass:[EditViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
  
    _imgDict = [[NSMutableDictionary alloc] init];
    
    // [self performSpeaech:@"박상범 자나?"];
    _feeds = [[NSMutableArray alloc] init];
    editCollectionView.showsHorizontalScrollIndicator = NO;;
    editCollectionView.showsVerticalScrollIndicator = NO;;
    
    editCollectionView.backgroundColor = [UIColor colorWithRed:235.0f/256.0f green:234.0f/256.0f blue:234.0f/256.0f alpha:1];//[UIColor lightGrayColor];
    
   // editCollectionView.backgroundColor = [UIColor darkGrayColor];
    
    
    [self parse];
    //https://itunes.apple.com/kr/rss/toppodcasts/limit=10/json
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(20, 20, 20, 20);
}
/*
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 0;
    
}
 */
- (void)parse
{
    NSHTTPURLResponse *response = nil;
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
  //  countryCode = @"kr";
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://itunes.apple.com/%@/rss/toppodcasts/limit=200/json",countryCode];
    NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //-- Get request and response though URL
  //  NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    
    ///
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error) {
                                              NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
                                              NSLog(@"Result = %@",result);
                                              NSMutableDictionary *feedDict =  result[@"feed"];
                                              NSMutableArray *entrys =  feedDict[@"entry"];
                                              int i=0;
                                              for (NSMutableDictionary *dic in entrys)
                                              {
                                                  _feedDatas = [[Feeds alloc] init];
                                                  
                                                  //NSString *string = dic[@"im:image"];
                                                  NSMutableArray *images = dic[@"im:image"];
                                                  NSMutableDictionary *imageDict = images[2];
                                                  NSString *imgLink = imageDict[@"label"];
                                                  
                                                  NSMutableDictionary *releaseDict = dic[@"im:releaseDate"];
                                                  NSMutableDictionary *attrDict = releaseDict[@"attributes"];
                                                  NSString *releaseDate =  attrDict[@"label"];
                                                  NSMutableDictionary * summaryDict = dic[@"summary"];
                                                  NSMutableDictionary * titleDict = dic[@"im:name"];
                                                  NSString *summary = summaryDict[@"label"];
                                                  NSString *title = titleDict[@"label"];
                                                  //
                                                  _feedDatas.thumbURL = imgLink;
                                                  _feedDatas.releaseDate = releaseDate;
                                                  _feedDatas.title = title;
                                                  _feedDatas.desc = summary;
                                                
                                                  NSLog(@"%@",imgLink);
                                                  
                                                  [_feeds addObject:_feedDatas];
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [editCollectionView reloadData];
                                                     
                                                      
                                                  });
                                                  i++;
                                                  
                                              }
                                              
                                         //
                                              
                                          }];
    
    [downloadTask resume];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performSpeaech:(NSString*)string
{
    AVSpeechUtterance *utternce = [AVSpeechUtterance speechUtteranceWithString:string];
    
    CGFloat rateRange = AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate;
    utternce.rate = AVSpeechUtteranceMinimumSpeechRate +rateRange*0.5;
    
    NSString *languageCode = @"ko-kr";//[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] ?:@"en-us";
    
    utternce.voice = [AVSpeechSynthesisVoice voiceWithLanguage:languageCode];
    
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    synthesizer.delegate = self;
    [synthesizer speakUtterance:utternce];
    
}

- (void)speechSythesizer:(AVSpeechSynthesizer*)synthesizer willSpeakRangeOfSpeechString:(NSRange)charactRange utterance:(AVSpeechUtterance*)utternace
{
    NSString *substring = [utternace.speechString substringWithRange:charactRange];
    NSLog(@"Speaking:%@", substring);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [_feeds count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EditViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
  //  UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
 //   NSString *url = _feeds[[indexPath row]];
    Feeds *feeds = _feeds[[indexPath row]];
    
    NSString *strKey = [NSString stringWithFormat:@"%d",[indexPath row]];
    NSData *data;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    imgView.layer.borderColor = [UIColor whiteColor].CGColor;
    imgView.layer.borderWidth = 2;
    imgView.layer.cornerRadius = 15;
    imgView.clipsToBounds = YES;
    imgView.layer.shadowColor = [UIColor blackColor].CGColor;
    imgView.layer.shadowOffset = CGSizeMake(10,10);
    if(_imgDict[strKey] == nil )
    {
        data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:feeds.thumbURL]];
        UIImage *image = [UIImage imageWithData:data];
      //  imgView = [[UIImageView alloc] initWithImage:image];
      //  imgView.frame = CGRectMake(0, 0, 100, 100);
         imgView.image = image;
        _imgDict[strKey] = image;
        
    }
    else
        imgView.image = _imgDict[strKey] ;//= image;
    
    
    imgView.contentMode = UIViewContentModeScaleToFill;
   
    cell.backgroundColor = [UIColor clearColor];
    [cell addSubview:imgView];
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
 
    return CGSizeMake(100, 100);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Feeds *feeds =  _feeds[[indexPath row]];
    _selectedTitle = feeds.title;
    /*
    NSRange range = [feeds.title rangeOfString:@")"];
    if(range.length)
    {
        _selectedTitle =[feeds.title substringFromIndex:range.location+1];
        range = [feeds.title rangeOfString:@"-"];
        if(range.length)
        {
            _selectedTitle = [_selectedTitle substringToIndex:range.location];
            
        }
    }
    */
    
  //  _selectedTitle = @"(공식)이근철의 굿모닝팝스";
    NSLog(@"feeds.title=%@",_selectedTitle);
   [self performSegueWithIdentifier:@"detail" sender:nil];
    
    /*
    
    if([_rssDatas count])
       [_rssDatas removeAllObjects];
       
    _rssDatas = [[NSMutableArray alloc] init];
    [self parseFeed:title];
    
  */
  
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error // Parsing failed
{
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if (YES == [@"detail" isEqualToString:segue.identifier])
    {
        RSSViewController *view= [segue destinationViewController];
        view.rssTitle = _selectedTitle;
        
    }
        
   // view.rssDatas = _rssDatas;
     // *view= [segue destinationViewController];
    // view.mystring = @"넘기는 값";
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    
    [UIView animateWithDuration:0.5 animations:^{
        bannerView.alpha = 1.0;
    }];
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
  //  [banner removeFromSuperview];
  //  [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        bannerView.alpha = 0.0;
    }];
}

@end
