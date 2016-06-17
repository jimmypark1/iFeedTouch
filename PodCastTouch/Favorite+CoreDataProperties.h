//
//  Favorite+CoreDataProperties.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 20..
//  Copyright © 2016년 Junsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Favorite.h"

NS_ASSUME_NONNULL_BEGIN

@interface Favorite (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *artworkUrl60;
@property (nullable, nonatomic, retain) NSString *artworkUrl100;
@property (nullable, nonatomic, retain) NSString *artworkUrl600;

@end

NS_ASSUME_NONNULL_END
