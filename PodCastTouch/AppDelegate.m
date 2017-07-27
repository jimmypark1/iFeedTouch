//
//  AppDelegate.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 14..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "finger.h"

@import Firebase;

@interface AppDelegate (){
    finger *fingerManager;
    NSDictionary *dicUserInfo;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
 
    _dbController = [DBController sharedManager];
    /*
    [ [UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:46.0f/256.0f green:46.0f/256.0f blue:46.0f/256.0f alpha:1]];
    
    [ [UINavigationBar appearance] setTranslucent:NO];
   // [ [UINavigationBar appearance] setTitleTextAttributes:@{[UIColor whiteColor]:UITextAttributeTextColor}];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
     */
    [ [UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:2.0f/256.0f green:5.0f/256.0f blue:17.0f/256.0f alpha:1]];
    
    [ [UINavigationBar appearance] setTranslucent:YES];
    // [ [UINavigationBar appearance] setTitleTextAttributes:@{[UIColor whiteColor]:UITextAttributeTextColor}];
    // [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor grayColor];//[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    

    NSError* error;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    Float32 bufferLength = 0.1;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(bufferLength), &bufferLength);
    
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

  //  [MPMoviePlayerController preparePrerollAds];
    [Fabric with:@[[Crashlytics class]]];
    CrashlyticsKit.debugMode = YES;
    
  //  [FIRApp configure];
    NSLog(@"SDK VERSION : %@",[finger getSdkVer]);
    
    fingerManager = [finger sharedData];
#ifdef DEBUG
    [fingerManager setAppKey:@"핑거푸시 APP KEY를 등록해주세요."];          //App Key
    [fingerManager setAppScrete:@"핑거푸시 APP SECRET KEY를 등록해주세요."];       //App Secret
#else
    [fingerManager setAppKey:@"63QNG87UENHP415Z5S3Q4Y5BTDOMACLN"];          //App Key
    [fingerManager setAppScrete:@"5M1vqKs1I54zdA1wWmBahthdKOea8rfJ"];       //App Secret
#endif
    
    
    /*apns 등록*/
    [self registeredForRemoteNotifications];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - apns 등록
- (void)registeredForRemoteNotifications {
#if !TARGET_IPHONE_SIMULATOR
    //푸시 등록
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else{
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
#endif
}

#pragma mark - push notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /*핑거푸시에 기기등록*/
    [fingerManager registerUserWithBlock:deviceToken :^(NSString *posts, NSError *error) {
        
        NSLog(@"토큰 : %@",fingerManager.getToken);
        NSLog(@"토큰idx : %@",fingerManager.getDeviceIdx);
        
        if (!error) {
            NSLog(@"기기등록  %@", posts);
        } else {
            NSLog(@"기기등록 error %@", error);
        }
    }];
    
}

//iOS7  이상
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    
    if([userInfo[@"aps"][@"content-available"] intValue] == 1) {
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    }else{
        
        [self showAlertViewController:userInfo];
        [self checkPush:userInfo];
        
        completionHandler(UIBackgroundFetchResultNoData);
        
    }
    
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@", [error description]);
}

#pragma mark -
- (void)showAlertViewController:(NSDictionary*)userInfo {
    /*
    UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topRootViewController.presentedViewController)
    {
        topRootViewController = topRootViewController.presentedViewController;
    }
    
    if ([topRootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navi = (UINavigationController*)topRootViewController;
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PopUpTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PopUpTableViewController"];
        [vc setUserInfo:userInfo];
        
        [navi pushViewController:vc animated:NO];
        
    }else if ([topRootViewController isKindOfClass:[MyTabBarController class]]){
        
        MyTabBarController *tab = (MyTabBarController*)topRootViewController;
        [tab showPopUp:userInfo];
        
    }
    */
}

- (void)checkPush:(NSDictionary*)userInfo{
    
    [[finger sharedData] requestPushCheckWithBlock:userInfo :^(NSString *posts, NSError *error) {
        if (!error) {
            NSLog(@"check : %@", posts);
        } else {
            NSLog(@"check error %@", error);
        }
    }];
    
}

@end
