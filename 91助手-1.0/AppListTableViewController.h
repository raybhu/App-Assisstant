//
//  AppListTableViewController.h
//  91助手-1.0
//
//  Created by Raizo on 15/11/1.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface AppListTableViewController : UITableViewController<SKStoreProductViewControllerDelegate>
@property (strong,nonatomic) NSString *targeturl;
@property (strong,nonatomic) NSString *navigationtitle;
@end
