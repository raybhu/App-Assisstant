//
//  ClassesAppListTableViewController.h
//  91助手-1.0
//
//  Created by Raizo on 15/11/2.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface ClassesAppListTableViewController : UITableViewController<SKStoreProductViewControllerDelegate>
@property (strong,nonatomic) NSString *xsmfUrl;
@property (strong,nonatomic) NSString *mfyyUrl;
@property (strong,nonatomic) NSString *jjyyUrl;
@property (strong,nonatomic) NSString *sfyyUrl;
@property (strong,nonatomic) NSString *navigationtitle;
@end
