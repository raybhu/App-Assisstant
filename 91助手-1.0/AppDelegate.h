//
//  AppDelegate.h
//  91助手-1.0
//
//  Created by Raizo on 15/10/27.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "MJRefresh.h"
#import "FMDB.h"
#import "App.h"
#import "HBUtil.h"
#import "AppDetailViewController.h"
#import "AppListTableViewController.h"
#import "ClassesAppListTableViewController.h"
#import "SearchTableViewController.h"
#import "HomePageTableViewController.h"
#import "ChatBarTableViewController.h"
#import "ClassesTableViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FMDatabase *db;

-(BOOL)isHasNetwork;
+(FMDatabaseQueue *)getSharedDatabaseQueue;

@end

