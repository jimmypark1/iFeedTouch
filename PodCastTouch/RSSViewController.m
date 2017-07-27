//
//  RSSViewController.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 15..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "RSSViewController.h"
#import "RSSData.h"
#import "MWFeedParser.h"
#import "RSSData.h"
#import "RSSDetailViewController.h"

@interface RSSViewController ()<GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>
{
    __weak IBOutlet UIImageView *coverView;
    __weak IBOutlet UIView *backView;
    
    __weak IBOutlet UITableView *tableView;
    MWFeedParser    *_feedParser;
    RSSData         *_rssData;
    RSSData         *_selectedRssData;
    NSString        *_selectedTitle;
    UIActivityIndicatorView *indicator;
    
}
@end


@implementation RSSViewController

- (void)addBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-8807882879991584/1756754633";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    
    [self.bannerView loadRequest:request];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
   // self.view.ba = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wood"]];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2048, 250)];
    backgroundView.image = [UIImage imageNamed:@"rain2"];
    [self.view addSubview:backgroundView];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = CGRectMake(0, 0, 2048, 250);
    
    [self.view addSubview:visualEffectView];

    [self.view addSubview:coverView];
   // tableView.backgroundColor = [UIColor clearColor];
  //  tableView.backgroundView = backgroundView;
    [self.view addSubview:tableView];
    
  
 
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    _rssDatas = [[NSMutableArray alloc] init];
    [indicator setCenter:CGPointMake(75, 75)];
    [coverView addSubview:indicator];
    [indicator startAnimating];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @"";
    self.title = _rssTitle;
    coverView.layer.cornerRadius = 75;
    coverView.layer.masksToBounds = YES;
    coverView.layer.borderWidth = 2;
    coverView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self parseFeed:_rssTitle];
    
    [self addBanner];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    self.navigationController.navigationBar.topItem.title = @"iFeed Touch";
    
    
}

- (void)imageDownload:(NSString*)strURL
{
    NSURL *url = [NSURL URLWithString:strURL];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                               // coverView.image = image;
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  UIImage *image = [UIImage imageWithData:data];
                                                 // coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                                                  [indicator stopAnimating];
                                                  
                                                  coverView.image = image;
                                                  coverView.layer.cornerRadius = 75;
                                                  coverView.layer.masksToBounds = YES;
                                                  coverView.layer.borderWidth = 2;
                                                  coverView.layer.borderColor = [UIColor whiteColor].CGColor;
                                                  [self.view addSubview:coverView];
                                                  
                                                  [self.view setNeedsDisplay];
                                              });
                                              
                                          }];
    [downloadTask resume];
                                          
}

- (void)parseFeed:(NSString*)title
{
    
    NSHTTPURLResponse *response = nil;
    NSString *base = @"https://itunes.apple.com/search?term";
    NSString *queryURL = [NSString stringWithFormat:@"%@=%@&entity=podcast",base, title];
    NSString *jsonUrlString = queryURL;
    NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              // 4: Handle response here
                                              NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                              NSLog(@"Result = %@",result);
                                              
                                              
                                              NSMutableArray *results= result[@"results"];
                                              if([results count] ==0)
                                                  return;
                                              
                                              NSMutableDictionary *resultDict = results[0];
                                              //   NSString *feedURL =  resultDict[@"feedUrl"];
                                              
                                              [self imageDownload:resultDict[@"artworkUrl600"]];
                                              
                                              
                                              NSURL *feedURL = [NSURL URLWithString:resultDict[@"feedUrl"]];
                                              NSLog(@"feedURL=%@",feedURL);
                                              
                                              _feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
                                              _feedParser.delegate = self;
                                              _feedParser.feedParseType = ParseTypeFull;
                                              _feedParser.connectionType = ConnectionTypeSynchronously;
                                              [_feedParser parse];
                                          }];
    
    [downloadTask resume];
    
    
    
    
}


- (void)feedParserDidStart:(MWFeedParser *)parser // Called when data has downloaded and parsing has begun
{
    
}
- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info // Provides info about the feed
{
    
}
- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item // Provides info about a feed item
{
    _rssData = [[RSSData alloc] init];
    NSString *title = item.title ? item.title : @"[No Title]";
    NSString *link = item.link ? item.link : @"[No Link]";
    NSString *summary = item.summary ? item.summary : @"[No Summary]";
    NSMutableArray *enclosures = item.enclosures;
    NSMutableDictionary *enclosureDict =  enclosures[0];
  //  item.artworkUrl600;
    NSLog(@"type=%@ url=%@",enclosureDict[@"type"],enclosureDict[@"url"]);
    
    _rssData.title = title;
    _rssData.enclosures = enclosureDict[@"url"];
    _rssData.summary = summary;
    _rssData.link = link;
    _rssData.type = enclosureDict[@"type"];
    [_rssDatas addObject:_rssData];
}
- (void)feedParserDidFinish:(MWFeedParser *)parser
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [tableView reloadData];
    });
}
- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error
{
    //
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"] ;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    RSSData *rss = _rssDatas[[indexPath row]];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    cell.textLabel.text = rss.title;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rssDatas count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSData *rss = _rssDatas[[indexPath row]];
    _selectedRssData = rss;
    _selectedTitle = rss.title;
    
    [self performSegueWithIdentifier:@"rss_detail" sender:nil];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    RSSDetailViewController *view= [segue destinationViewController];
    view.rssTitle = _selectedTitle;
    view.rssData = _selectedRssData;
    view.thumb = coverView.image ;
    // view.rssDatas = _rssDatas;
    // *view= [segue destinationViewController];
    // view.mystring = @"넘기는 값";
}
@end
