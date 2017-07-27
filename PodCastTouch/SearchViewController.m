//
//  SearchViewController.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 18..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "SearchViewController.h"
#import "EditViewCell.h"
#import "MWFeedParser.h"
#import "RSSData.h"
#import "SearchCell.h"
#import "DBController.h"
#import <iAd/iAd.h>

@interface RSSSearchData : NSObject <GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>

/*
 NSString *title = item.title ? item.title : @"[No Title]";
 NSString *link = item.link ? item.link : @"[No Link]";
 NSString *summary = item.summary ? item.summary : @"[No Summary]";
 NSMutableArray *enclosures = item.enclosures;
 
 
 */
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* link;
@property (nonatomic, copy) NSString* summary;
@property (nonatomic, copy) NSString* enclosures;
@property (nonatomic, copy) NSString* artworkUrl100;
@property (nonatomic, copy) NSString* artworkUrl60;
@property (nonatomic, copy) NSString* artworkUrl600;

@property (nonatomic, copy) NSString* type;
@end

@implementation RSSSearchData



@end


@interface SearchViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
{
    __weak IBOutlet UITableView    *tableView;
    __weak IBOutlet UISearchBar         *searchBar;
    
    NSMutableArray                  *_rssDatas;
    MWFeedParser                    *_feedParser;
    RSSSearchData                         *_rssData;
    UISearchController              *_controller;
    NSMutableDictionary             *imgDict;
    RSSSearchData *searchData;
    ADBannerView    *bannerView;
}
@property (nonatomic, strong) UISearchController *searchController;
@end



@implementation SearchViewController

//- (void)searchB

- (void)viewWillDisappear:(BOOL)animated {
    
    self.navigationController.navigationBar.topItem.title = @"iFeed Touch";
    
}

- (void)done
{
    
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
                                        
                                                  SearchCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                                                  cell.imgView.image = image;
                                                  
                                                  [imgDict setObject:image forKey:indexPath];
                                                  [self.tableView setNeedsDisplay];
                                              });
                                              
                                          }];
    [downloadTask resume];
    
}

- (void)addBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-8807882879991584/1756754633";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    
    [self.bannerView loadRequest:request];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBanner];
    imgDict = [[NSMutableDictionary alloc] init];
    self.navigationController.navigationBar.topItem.title =@"";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
   
    self.title = @"Search";
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;//self.searchController.searchBar;
    [self.view addSubview:self.searchController.searchBar];
    
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed

    _rssDatas = [[NSMutableArray alloc] init];
 /*
    bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    bannerView.delegate = self;
    self.canDisplayBannerAds = YES;
    bannerView.alpha = 0.0;
  */
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;                     // called when text starts editing
{
   // self.navigationController.navigationBar.hidden = YES;
    if([_rssDatas count])
    {
        [_rssDatas removeAllObjects];
        [imgDict removeAllObjects];
    }
    [self.tableView reloadData];

}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;                        // return NO to not resign first responder
{
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;                       // called when text ends editing
{
   // self.navigationController.navigationBar.hidden = NO;
    
    if([searchBar.text length])
        [self parseFeed:searchBar.text];

   // [tableView reloadData];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([_rssDatas count])
    {
        [imgDict removeAllObjects];
        
        [_rssDatas removeAllObjects];
    }
    [self parseFeed:searchBar.text];
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if (cell == nil) {
        cell = [[SearchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchCell"] ;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if(([indexPath row] >[_rssDatas count] )||[_rssDatas count]==0)
        return cell;
    RSSSearchData *rss = _rssDatas[[indexPath row]];
    
    CGRect rect = cell.imgView.frame ;
    
    rect.size.width = 60;
   // rect.size.height = 60;
    
   // cell.imgView.frame = rect;
   // cell.imgView.contentMode = UIViewContentModeScaleToFill;
    cell.imgView.clipsToBounds = YES;
    cell.imgView.layer.cornerRadius = 6;
    cell.imgView.layer.borderColor = [UIColor blackColor].CGColor;
    cell.imgView.layer.borderWidth =2;
    if(![imgDict objectForKey:indexPath])
    {
      //  - (void)imageDownload:(NSString*)strURL index:(NSIndexPath*)indexPath
        [self imageDownload:rss.artworkUrl60 index:indexPath];

    }
    else
        cell.imgView.image = imgDict[indexPath];

    cell.title.textColor = [UIColor blackColor];
    cell.title.font = [UIFont fontWithName:@"Helvetica" size:14];
    cell.title.text = rss.title;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rssDatas count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([_rssDatas count])
    {
        searchData = _rssDatas[[indexPath row] ];

    
    //Are you sure you want Bookmark this Post?
//    [self showMessage:@"해당 Post를 즐겨찾기 하시겠습니까?" title:@"정보"];
        [self showMessage:@"Are you sure you want Bookmark this Post?" title:@"Information"];
    }
  
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // extract array from observer
    _rssDatas = [(NSArray *)object valueForKey:@"results"];
    [tableView reloadData];
}
 */

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
                                              
                                              for(NSMutableDictionary *resultDict in results )
                                              {
                                                  _rssData = [[RSSSearchData alloc] init];
                                                  
                                                  _rssData.link = resultDict[@"feedUrl"];
                                                  _rssData.title= resultDict[@"collectionName"];
                                                  _rssData.artworkUrl60= resultDict[@"artworkUrl60"];
                                                  _rssData.artworkUrl100= resultDict[@"artworkUrl100"];
                                                  _rssData.artworkUrl600= resultDict[@"artworkUrl600"];
                                                  
                                                  [_rssDatas addObject:_rssData];
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self.tableView reloadData];
                                                      
                                                  });

                                              }
                                              
                                             
                                          }];
    
    [downloadTask resume];
    
    
    
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    // filter the search results
  //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@", self.controller.searchBar.text];
    //self.results = [self.data filteredArrayUsingPredicate:predicate];
    
    // NSLog(@"Search Results are: %@", [self.results description]);
}
#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}


- (void)showMessage:(NSString*)message title:(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
   // [alert setTag:tag];
    [alert show];

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSArray *artworks = [NSArray arrayWithObjects:searchData.artworkUrl60,searchData.artworkUrl100,searchData.artworkUrl600, nil];
        // - (void)saveTitle:(NSString*)title artworks:(NSArray*)artworks
        
        [[DBController sharedManager] saveTitle:searchData.title artworks:artworks];
        
    }
    
}


@end
