
//
//  ResultViewController.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 18..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "ResultViewController.h"

@implementation ResultViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"] ;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    /*
    RSSSearchData *rss = _rssDatas[[indexPath row]];
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    cell.textLabel.text = rss.title;
     */
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    cell.textLabel.text = @"test";
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;//[_rssDatas count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


@end
