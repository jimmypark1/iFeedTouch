//
//  Feeds.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 15..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feeds : NSObject
@property (nonatomic, copy) NSString *thumbURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *releaseDate;

@end
