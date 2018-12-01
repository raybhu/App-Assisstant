//
//  AppDelegate.m
//  91助手-1.0
//
//  Created by Raizo on 15/10/27.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize db;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self createDatabase];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    UITabBarController *rootTBV=[[UITabBarController alloc]init];
    
    HomePageTableViewController *homepageTVC=[[HomePageTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    homepageTVC.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"首页" image:[UIImage imageNamed:@"homepage_home@2x.png"] tag:1];
    UINavigationController *homepageNC=[[UINavigationController alloc]initWithRootViewController:homepageTVC];
    
    
    ChatBarTableViewController *chatbarTVC=[[ChatBarTableViewController alloc]initWithStyle:UITableViewStylePlain];
    chatbarTVC.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"聊吧" image:[UIImage imageNamed:@"homepage_talk@2x.png"] tag:2];
    UINavigationController *chatbarNC=[[UINavigationController alloc]initWithRootViewController:chatbarTVC];
    
    ClassesTableViewController *classesTVC=[[ClassesTableViewController alloc]initWithStyle:UITableViewStylePlain];
    classesTVC.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"分类" image:[UIImage imageNamed:@"homepage_cate@2x.png"] tag:3];
    UINavigationController *classesNC=[[UINavigationController alloc]initWithRootViewController:classesTVC];
    
    SearchTableViewController *searchTVC=[[SearchTableViewController alloc]initWithStyle:UITableViewStylePlain];
    searchTVC.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"搜索" image:[UIImage imageNamed:@"homepage_seach@2x.png"] tag:4];
    UINavigationController *searchNC=[[UINavigationController alloc]initWithRootViewController:searchTVC];
    
    rootTBV.viewControllers=@[homepageNC,chatbarNC,classesNC,searchNC];
    self.window.rootViewController=rootTBV;
    [self.window makeKeyAndVisible];
    return YES;
}
#pragma mark - 创建数据库
-(void)createDatabase
{
    NSString *path=NSHomeDirectory();
    path=[path stringByAppendingPathComponent:@"Documents/db.db"];
    db=[FMDatabase databaseWithPath:path];
    if ([db open])
    {
        NSString *sql=@"create table if not exists apps (page text not null,section text not null,appType text null,author text null,cateName text null,detailUrl text null,downAct text null,downTimes text null,icon text null,name text null,originalPrice text null,price text null,resId text null,size text null,star text null,state text null,summary text null,imagedata blob null)";
        [db executeUpdate:sql];
        sql=@"create table if not exists homepagescrollview (desc text null,logourl text null,targeturl text null,imagedata blob null)";
        [db executeUpdate:sql];
        sql=@"create table if not exists homepagesection (name text null,act text null,page text null)";
        [db executeUpdate:sql];
        sql=@"create table if not exists homepageappspecial (name text null,icon text null,url text null,imagedata blob null)";
        [db executeUpdate:sql];
        sql=@"create table if not exists chatbarcell (name text null,icon text null,act text null,imagedata blob null)";
        [db executeUpdate:sql];
        sql=@"create table if not exists classescell (name text null,icon text null,summary text null,imagedata blob null,tablenumber text null,限时免费 text null,免费应用 text null,降价应用 text null,收费应用 text null)";
        [db executeUpdate:sql];
    }
    NSLog(@"%@",path);
}
#pragma mark - 网络判断
-(BOOL)isHasNetwork
{
    Reachability * reach=[Reachability reachabilityWithHostName:@"www.baidu.com"];
    return reach.currentReachabilityStatus;
}
#pragma mark - 创建数据库线程单例
+(FMDatabaseQueue *)getSharedDatabaseQueue
{
    {
        static FMDatabaseQueue *my_FMDatabaseQueue=nil;
        
        if (!my_FMDatabaseQueue) {
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/db.db"];
            my_FMDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
        }
        return my_FMDatabaseQueue;
    }
}
@end
