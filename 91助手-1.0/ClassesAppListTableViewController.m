//
//  ClassesAppListTableViewController.m
//  91助手-1.0
//
//  Created by Raizo on 15/11/2.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "ClassesAppListTableViewController.h"

@interface ClassesAppListTableViewController ()
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    UIView *Headertableview;
    
    NSMutableArray *appArr;
    NSMutableArray *mfyyArr;
    NSMutableArray *xsmfArr;
    NSMutableArray *jjyyArr;
    NSMutableArray *sfyyArr;
    AppDelegate *appdelegate;
}
@end

@implementation ClassesAppListTableViewController
@synthesize xsmfUrl,mfyyUrl,sfyyUrl,jjyyUrl,navigationtitle;
- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD showWithStatus:@"正在载入.."];
    screenWidth=[UIScreen mainScreen].bounds.size.width;
    screenHeight=[UIScreen mainScreen].bounds.size.height;
    [self createHeadertableview];
    self.navigationController.navigationBar.translucent=NO;
    self.navigationController.navigationBar.tintColor=[UIColor grayColor];
    self.navigationController.navigationBar.barTintColor=[UIColor blackColor];
    self.navigationItem.title=navigationtitle;
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor=[UIColor whiteColor];
    appArr=[[NSMutableArray alloc]init];
    mfyyArr=[[NSMutableArray alloc]init];
    xsmfArr=[[NSMutableArray alloc]init];
    jjyyArr=[[NSMutableArray alloc]init];
    sfyyArr=[[NSMutableArray alloc]init];
    [self getData];
    [[Headertableview viewWithTag:1] setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [[Headertableview viewWithTag:1] viewWithTag:5].backgroundColor=[UIColor orangeColor];
}
#pragma mark - 创建头视图
-(void)createHeadertableview
{
    Headertableview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
    NSArray *buttontitleArr=[NSArray arrayWithObjects:@"免费应用",@"限时免费",@"降价应用",@"收费应用", nil];
    for(int i=0;i<4;i++)
    {
        UIButton *button=[[UIButton alloc]init];
        button.frame=CGRectMake(i*screenWidth/4, 0, screenWidth/4, 30);
        button.backgroundColor=[UIColor whiteColor];
        [button setTitle:[buttontitleArr objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button.tag=i+1;
        [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        UIView *underview=[[UIView alloc]init];
        underview.frame=CGRectMake(0, 27, screenWidth/4, 3);
        underview.backgroundColor=[UIColor clearColor];
        underview.tag=5;
        [button addSubview:underview];
        [Headertableview addSubview:button];
    }
    self.tableView.tableHeaderView=Headertableview;
}
-(void)selectButton:(UIButton *)sender
{
    for (int i=0; i<[Headertableview subviews].count; i++)
    {
        [[[Headertableview subviews] objectAtIndex:i] setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [[[[Headertableview subviews] objectAtIndex:i] viewWithTag:5] setBackgroundColor:[UIColor clearColor]];
    }
    if (sender.tag==1)
    {
        appArr=mfyyArr;
        [[Headertableview viewWithTag:1] setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [[Headertableview viewWithTag:1] viewWithTag:5].backgroundColor=[UIColor orangeColor];
        [self.tableView reloadData];
        
    }
    else if (sender.tag==2)
    {
        appArr=xsmfArr;
        [[Headertableview viewWithTag:2] setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [[Headertableview viewWithTag:2] viewWithTag:5].backgroundColor=[UIColor orangeColor];
        [self.tableView reloadData];
    }
    else if (sender.tag==3)
    {
        appArr=jjyyArr;
        [[Headertableview viewWithTag:3] setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [[Headertableview viewWithTag:3] viewWithTag:5].backgroundColor=[UIColor orangeColor];
        [self.tableView reloadData];
    }
    else if (sender.tag==4)
    {
        appArr=sfyyArr;
        [[Headertableview viewWithTag:4] setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [[Headertableview viewWithTag:4] viewWithTag:5].backgroundColor=[UIColor orangeColor];
        [self.tableView reloadData];
    }
}
#pragma mark - 解析数据
-(void)getData
{
    [self getdataFromnetWithTargerUrl:mfyyUrl andWithArr:mfyyArr];
    [self getdataFromnetWithTargerUrl:xsmfUrl andWithArr:xsmfArr];
    [self getdataFromnetWithTargerUrl:jjyyUrl andWithArr:jjyyArr];
    [self getdataFromnetWithTargerUrl:sfyyUrl andWithArr:sfyyArr];
}
#pragma mark - 解析数据方法
-(void)getdataFromnetWithTargerUrl:(NSString *)targerurl andWithArr:(NSMutableArray *)myarr
{
    NSURL *url=[NSURL URLWithString:targerurl];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data==nil)
        {
            return;
        }
        NSDictionary *jsonDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *resultDic=[jsonDic objectForKey:@"Result"];
        NSArray *itemsArr=[resultDic objectForKey:@"items"];
        
        NSMutableArray *tempArr=[[NSMutableArray alloc]init];
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
            [tempArr addObject:dic];
        }
        [myarr removeAllObjects];
        [myarr addObjectsFromArray:tempArr];
              dispatch_async(dispatch_get_main_queue(), ^{
        if (myarr==mfyyArr)
        {
            [appArr addObjectsFromArray:myarr];
      
                [self.tableView reloadData];
            [SVProgressHUD dismiss];
           
        }
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
