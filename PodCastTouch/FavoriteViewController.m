//
//  FavoriteViewController.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 20..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "FavoriteViewController.h"
#import "DBController.h"
#import "EditViewCell.h"
#import "Favorite.h"
#import "RSSViewController.h"
#import <iAd/iAd.h>

@interface FavoriteViewController ()<GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>
{
    __weak IBOutlet UICollectionView *editCollectionView;
    NSArray    *_favorites;
    NSMutableDictionary *_imgDict;
    NSString *_selectedTitle;
    ADBannerView *bannerView;
}

@end

@implementation FavoriteViewController
- (void)addBanner
{
    //
//    self.bannerView.adUnitID = @"ca-app-pub-2367841846534648/3089100414";
    self.bannerView.adUnitID = @"ca-app-pub-8807882879991584/1756754633";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    
    [self.bannerView loadRequest:request];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    self.navigationController.navigationBar.topItem.title = @"iFeed Touch";
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title = @"Favorites";
   // self.navigationController.navigationBar.topItem.title = @"Favorites";
   // self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    editCollectionView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rain2"]];
    [self addBanner];
    self.title = @"Favorites";
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"metal"]];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.contentMode = UIViewContentModeScaleToFill;
    visualEffectView.frame =  CGRectMake(0, 0, 2048, 2048);
    //[self.view addSubview:visualEffectView];
    [editCollectionView.backgroundView addSubview:visualEffectView];

    
    [editCollectionView registerClass:[EditViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    editCollectionView.showsHorizontalScrollIndicator = NO;;
    editCollectionView.showsVerticalScrollIndicator = NO;;
    
    editCollectionView.backgroundColor = [UIColor colorWithRed:235.0f/256.0f green:234.0f/256.0f blue:234.0f/256.0f alpha:1];//[UIColor lightGrayColor];
    
    _imgDict = [[NSMutableDictionary alloc] init];
     _favorites =  [[DBController sharedManager] readFavorite];
    
    
    [editCollectionView reloadData];
    /*
    bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    bannerView.delegate = self;
    self.canDisplayBannerAds = YES;
    bannerView.alpha = 0.0;
     */
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imageDownload:(NSString*)strURL index:(NSIndexPath*)indexPath
{
    NSURL *url = [NSURL URLWithString:strURL];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              // coverView.image = image;
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  UIImage *image = [UIImage imageWithData:data];
                                                  // coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                                                  
                                               //   EditViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                                                //  cell.imgView.image = image;
                                                  
                                                  //[imgDict setObject:image forKey:indexPath];
                                                 // [self.tableView setNeedsDisplay];
                                              });
                                              
                                          }];
    [downloadTask resume];
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [_favorites count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EditViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    Favorite *fav = _favorites[[indexPath row]];
    ///
    NSString *strKey = [NSString stringWithFormat:@"%d",[indexPath row]];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    imgView.layer.borderColor = [UIColor whiteColor].CGColor;
    imgView.layer.borderWidth = 2;
    imgView.layer.cornerRadius = 15;
    imgView.clipsToBounds = YES;
    imgView.layer.shadowColor = [UIColor blackColor].CGColor;
    imgView.layer.shadowOffset = CGSizeMake(10,10);
    if(_imgDict[strKey] == nil )
    {
        NSString *strURL = fav.artworkUrl60;
        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:fav.artworkUrl100]];
        UIImage *image = [UIImage imageWithData:data];
        //  imgView = [[UIImageView alloc] initWithImage:image];
        //  imgView.frame = CGRectMake(0, 0, 100, 100);
        imgView.image = image;
        _imgDict[strKey] = image;
        
    }
    else
        imgView.image = _imgDict[strKey] ;//= image;
    

    cell.backgroundColor = [UIColor clearColor];
    [cell addSubview:imgView];
    
    ///
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(100, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Favorite *fav = _favorites[[indexPath row]];
    _selectedTitle = fav.title;
     [self performSegueWithIdentifier:@"fav_detail" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if (YES == [@"fav_detail" isEqualToString:segue.identifier])
    {
        RSSViewController *view= [segue destinationViewController];
        view.rssTitle = _selectedTitle;
        
    }
    
    // view.rssDatas = _rssDatas;
    // *view= [segue destinationViewController];
    // view.mystring = @"넘기는 값";
}

@end
