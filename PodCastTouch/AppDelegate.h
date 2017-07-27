//
//  AppDelegate.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 14..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DBController *dbController;

@end

