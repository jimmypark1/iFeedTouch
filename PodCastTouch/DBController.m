
//
//  DBController.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 20..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "DBController.h"
#import "Favorite.h"
@interface DBController ()
{
 
    NSManagedObjectContext *_managedContext;
    NSPersistentStoreCoordinator *_persistentCoordinator;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}
@end



@implementation DBController

+ (instancetype)sharedManager
{
    
    static DBController *this = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        this = [[DBController alloc] init];
        [this initializeCoreData];

    });
    
    return this;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    
    return self;
}

- (void)initializeCoreData
{
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FavoriteModel" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    _persistentCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    _managedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedContext setPersistentStoreCoordinator:_persistentCoordinator];
    [self setManagedObjectContext:_managedContext];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"FavoriteModel.sqlite"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        _persistentStoreCoordinator = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        //NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
    
}

- (NSManagedObjectContext*)managedObjectContext
{
    return _managedContext;
}

- (NSPersistentStoreCoordinator *)persistentCoordinator {
    
    return _persistentCoordinator;
}

//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    return _persistentStoreCoordinator;
}

- (void)saveTitle:(NSString*)title artworks:(NSArray*)artworks
{
    Favorite *employee = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:[self managedObjectContext]];
    
    employee.title = title;
    //  NSArray *artworks = [NSArray arrayWithObjects:searchData.artworkUrl60,searchData.artworkUrl100,searchData.artworkUrl600, nil];
    
    employee.artworkUrl60 =  artworks[0];
    employee.artworkUrl100 =  artworks[1];
    employee.artworkUrl600 =  artworks[2];
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }

}


- (NSArray*)readFavorite
{
  //  NSManagedObjectContext *moc = …;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorite"];
    
    NSError *error = nil;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!results) {
     //   DLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    return results;
}

@end
