//
//  AppListTableViewController.m
//  91助手-1.0
//
//  Created by Raizo on 15/11/1.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "AppListTableViewController.h"

@interface AppListTableViewController ()
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSMutableArray *appArr;
    AppDelegate *appdelegate;
}
@end

@implementation AppListTableViewController
@synthesize targeturl,navigationtitle;
- (void)viewDidLoad {
    [super viewDidLoad];
    appArr=[[NSMutableArray alloc]init];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD showWithStatus:@"正在载入.."];
    screenWidth=[UIScreen mainScreen].bounds.size.width;
    screenHeight=[UIScreen mainScreen].bounds.size.height;

    self.navigationController.navigationBar.translucent=NO;
    self.navigationController.navigationBar.tintColor=[UIColor grayColor];
    self.navigationController.navigationBar.barTintColor=[UIColor blackColor];
    self.navigationItem.title=navigationtitle;
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor=[UIColor whiteColor];
    //self.automaticallyAdjustsScrollViewInsets = NO;
        [self getdataFromnetWithTargerUrl:targeturl];

}
#pragma mark - 解析数据
-(void)getdataFromnetWithTargerUrl:(NSString *)targerurl
{

    NSURL *url=[NSURL URLWithString:targerurl];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data==nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD setStatus:@"加载失败,请稍后重试..."];
                [SVProgressHUD dismissWithDelay:2];
            });
            return;
        }

        NSDictionary *jsonDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *resultDic=[jsonDic objectForKey:@"Result"];
        NSArray *itemsArr=[resultDic objectForKey:@"items"];
        
        for (int i=0; i<itemsArr.count; i++)
        {
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            dic=[NSMutableDictionary dictionaryWithDictionary:[itemsArr objectAtIndex:i]];
            NSData *icondata=[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic objectForKey:@"icon"]]];
            UIImage *image=[[UIImage alloc]init];
            if (icondata==nil)
            {
                image=[UIImage imageNamed:@"pic_fresh_s@2x.png"];
                
            }
            else
            {
                image=[UIImage imageWithData:icondata];
            }
            [dic removeObjectForKey:@"icon"];
            [dic setObject:image forKey:@"icon"];
            
            NSString *size;
            if ([[dic objectForKey:@"size"] longLongValue]>1024*1024*1024)
            {
                size=[NSString stringWithFormat:@"%.2fGB",[[dic objectForKey:@"size"] longLongValue]/1024/1024/1024.0];
            }
            else
            {
                size=[NSString stringWithFormat:@"%.2fMB",[[dic objectForKey:@"size"] longLongValue]/1024/1024.0];
            }
            [dic removeObjectForKey:@"size"];
            [dic setObject:size forKey:@"size"];
            [appArr addObject:dic];
        }
        //NSLog(@"%@,url=%@",appArr,targerurl);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        });
    }];
    [task resume];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.backgroundColor=[UIColor whiteColor];
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 57, 57)];
    imageView.backgroundColor=[UIColor whiteColor];
    imageView.layer.masksToBounds=YES;
    imageView.layer.cornerRadius=10;
    imageView.image=[[appArr objectAtIndex:indexPath.row] objectForKey:@"icon"];
    [cell addSubview:imageView];
    UILabel *nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(57+10+10, 10, screenWidth/2, 20)];
    nameLabel.backgroundColor=[UIColor whiteColor];
    nameLabel.text=[[appArr objectAtIndex:indexPath.row] objectForKey:@"name"];
    [cell addSubview:nameLabel];
    UILabel *downLabel=[[UILabel alloc]initWithFrame:CGRectMake(57+10+10, 50, screenWidth/4, 15)];
    downLabel.backgroundColor=[UIColor whiteColor];
    downLabel.textColor=[UIColor grayColor];
    downLabel.font=[UIFont systemFontOfSize:13];
    downLabel.text=[NSString stringWithFormat:@"%@次下载",[[appArr objectAtIndex:indexPath.row] objectForKey:@"downTimes"]];
    [cell addSubview:downLabel];
    UILabel *sizeLabel=[[UILabel alloc]initWithFrame:CGRectMake(57+10+10+screenWidth/4+5, 50, screenWidth/5, 15)];
    sizeLabel.backgroundColor=[UIColor whiteColor];
    sizeLabel.font=[UIFont systemFontOfSize:13];
    sizeLabel.text=[[appArr objectAtIndex:indexPath.row] objectForKey:@"size"];
    [cell addSubview:sizeLabel];
    UIButton *downButton=[[UIButton alloc]initWithFrame:CGRectMake(57+10+10+screenWidth/4+5+screenWidth/6+((screenWidth-(57+10+10+screenWidth/4+5+screenWidth/6))/2-screenWidth/16), (57+20+10)/2-15, screenWidth/7, 30)];
    downButton.backgroundColor=[UIColor orangeColor];
    downButton.titleLabel.font=[UIFont systemFontOfSize:11];
    downButton.layer.cornerRadius=3;
    if ([[[appArr objectAtIndex:indexPath.row] objectForKey:@"price"] isEqualToString:@"0.00"])
    {
        [downButton setTitle:@"免费" forState:UIControlStateNormal];
    }
    else
    {
        [downButton setTitle:[NSString stringWithFormat:@"%@",[[appArr objectAtIndex:indexPath.row] objectForKey:@"price"]] forState:UIControlStateNormal];
    }
    downButton.tag=indexPath.row+1;
    [downButton addTarget:self action:@selector(downButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:downButton];
    int starNumber=[[[appArr objectAtIndex:indexPath.row] objectForKey:@"star"] intValue];
    for (int i=0; i<starNumber; i++)
    {
        UIImageView *startImageView=[[UIImageView alloc]initWithFrame:CGRectMake((57+10+10)+i*((screenWidth/2)/9), 30, (screenWidth/2)/9, ((screenWidth/2)/9))];
        [startImageView setImage:[UIImage imageNamed:@"detail_star@2x.png"]];
        [cell addSubview:startImageView];
    }
    if (starNumber<5)
    {
        int i=5-starNumber;
        for (int k=0; k<i; k++)
        {
            UIImageView *startImageView=[[UIImageView alloc]initWithFrame:CGRectMake((57+10+10)+(starNumber+k)*((screenWidth/2)/9), 30, (screenWidth/2)/9,((screenWidth/2)/9))];
            [startImageView setImage:[UIImage imageNamed:@"detail_unstar@2x.png"]];
            [cell addSubview:startImageView];
        }
    }
    
    UIView *underView=[[UIView alloc]initWithFrame:CGRectMake(0, 57+20+10-1, screenWidth, 1)];
    underView.backgroundColor=[UIColor lightGrayColor];
    [cell addSubview:underView];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDetailViewController *appdetail=[[AppDetailViewController alloc]init];
    appdetail.navigationItem.hidesBackButton=YES;
    appdetail.hidesBottomBarWhenPushed=YES;
    NSString *detailUrl=[[appArr objectAtIndex:indexPath.row] objectForKey:@"detailUrl"];
    appdetail.detailUrlpath=detailUrl;
    [self.navigationController pushViewController:appdetail animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 87;
}
#pragma mark - 跳转APPSTORE
-(void)downButton:(UIButton *)sender
{
    NSString *resid=[[appArr objectAtIndex:sender.tag-1] objectForKey:@"resId"];
    [self openAppWithResId:resid andWithViewController:self];
}
-(void)openAppWithResId:(NSString *)resid andWithViewController:(UIViewController *)view
{
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:resid forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error)
     {
         if (result)
         {
             [view presentViewController:storeProductVC animated:YES completion:nil];
         }
     }];
}
-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
@end
