//
//  AppDetailViewController.h
//  91助手-1.0
//
//  Created by Raizo on 15/10/31.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface AppDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,SKStoreProductViewControllerDelegate>
@property (strong, nonatomic) NSString *detailUrlpath;
@end
