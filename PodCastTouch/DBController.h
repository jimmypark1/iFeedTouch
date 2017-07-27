//
//  DBController.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 20..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DBController : NSObject
@property (strong) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedManager;

- (void)saveTitle:(NSString*)title artworks:(NSArray*)artworks;
- (NSArray*)readFavorite;

@end
