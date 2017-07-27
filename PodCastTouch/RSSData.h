//
//  RSSData.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 15..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSData : NSObject

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
@property (nonatomic, copy) NSString* artworkUrl600;
@property (nonatomic, copy) NSString* type;
@end
