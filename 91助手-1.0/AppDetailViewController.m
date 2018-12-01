//
//  AppDetailViewController.m
//  91助手-1.0
//
//  Created by Raizo on 15/10/31.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "AppDetailViewController.h"

@interface AppDetailViewController ()
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    NSMutableDictionary *resultDic;
    
    UITableView *tableview;
    UIView *tableHeaderview;
    UIScrollView *headerScrollview;
    
    UILabel *versionLabel;
    UIImageView *iconImageview;
    UILabel *nameLabel;
    UILabel *sizeLabel;
    UIButton *downButton;
    
    UILabel *compatibilityLabel;
    UILabel *descLabel;
    
    
    AppDelegate *appdelegate;
    
    BOOL isOpen;
    
}
@end

@implementation AppDetailViewController
@synthesize detailUrlpath;
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD showWithStatus:@"正在载入.."];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    screenWidth=[UIScreen mainScreen].bounds.size.width;
    screenHeight=[UIScreen mainScreen].bounds.size.height;
    resultDic=[[NSMutableDictionary alloc]init];
    
    
    [self createHeaderview];
    
    tableview=[[UITableView alloc]initWithFrame:CGRectMake(0,20, screenWidth,screenHeight ) style:UITableViewStylePlain];
    tableview.dataSource=self;
    tableview.delegate=self;
    tableview.backgroundColor=[UIColor whiteColor];
    tableview.tableHeaderView=tableHeaderview;
    
    [self.view addSubview:tableview];
    
    [self createHeaderbutton];
    [self getappDatafromUrlPath:detailUrlpath];
    
}
#pragma mark - 从服务器获取APP详细信息
-(void)getappDatafromUrlPath:(NSString *)urlpath
{
    NSURL *url=[NSURL URLWithString:urlpath];
    NSURLSessionConfiguration *config=[NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data==nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD setStatus:@"加载失败,请稍后重试..."];
                [SVProgressHUD dismissWithDelay:2];
            });
            return;
        }
        
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        resultDic=[NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"Result"]];
        NSArray *snapshotsurlpathArr=[resultDic objectForKey:@"snapshots"];
        
        [resultDic removeObjectForKey:@"snapshots"];
        NSMutableArray *snapshotsimageArr=[[NSMutableArray alloc]init];
        for (int i=0; i<snapshotsurlpathArr.count; i++)
        {
            
            NSString *snapshotsurlpath=[snapshotsurlpathArr objectAtIndex:i];
            
            NSURL *snapshotsurl=[NSURL URLWithString:snapshotsurlpath];
            NSData *imagedata=[NSData dataWithContentsOfURL:snapshotsurl];
            UIImage *snapshotimage=[UIImage imageWithData:imagedata];
            [snapshotsimageArr addObject:snapshotimage];
        }
        [resultDic setObject:snapshotsimageArr forKey:@"snapshots"];
        
        NSData *icondata=[NSData dataWithContentsOfURL:[NSURL URLWithString:[resultDic objectForKey:@"icon"]]];
        [resultDic removeObjectForKey:@"icon"];
        if (icondata==nil)
        {
            [resultDic setObject:[UIImage imageNamed:@"pic_fresh_s@2x.png"] forKey:@"icon"];
        }
        else
        {
            [resultDic setObject:[UIImage imageWithData:icondata] forKey:@"icon"];
        }
        
        NSString *size;
        if ([[resultDic objectForKey:@"size"] longLongValue]>1024*1024*1024)
        {
            size=[NSString stringWithFormat:@"%.2fGB",[[resultDic objectForKey:@"size"] longLongValue]/1024/1024/1024.0];
        }
        else
        {
            size=[NSString stringWithFormat:@"%.2fMB",[[resultDic objectForKey:@"size"] longLongValue]/1024/1024.0];
        }
        [resultDic removeObjectForKey:@"size"];
        [resultDic setObject:size forKey:@"size"];
        NSMutableArray *recommendsoftsArr=[[NSMutableArray alloc]init];
        NSArray *recommendArr=[resultDic objectForKey:@"recommendSofts"];
        for (NSDictionary *recommendstrDic in recommendArr)
        {
            NSMutableDictionary *recomDic=[[NSMutableDictionary alloc]init];
            recomDic=[NSMutableDictionary dictionaryWithDictionary:recommendstrDic];
            UIImage *icon=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[recommendstrDic objectForKey:@"icon"]]]];
            [recomDic removeObjectForKey:@"icon"];
            [recomDic setObject:icon forKey:@"icon"];
            [recommendsoftsArr addObject:recomDic];
        }
        [resultDic removeObjectForKey:@"recommendSofts"];
        [resultDic setObject:recommendsoftsArr forKey:@"recommend"];
        //NSLog(@"%@",resultDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshTableview];
            [tableview reloadData];
            [SVProgressHUD dismiss];
            
        });
    }];
    [task resume];
}
#pragma mark - 数据接收完成 刷新视图
-(void)refreshTableview
{
    NSArray *snapshotsArr=[resultDic objectForKey:@"snapshots"];
    for (int i=0; i<snapshotsArr.count; i++)
    {
        if (i==snapshotsArr.count-1)
        {
            [[headerScrollview viewWithTag:i+1] setImage:[snapshotsArr objectAtIndex:i] forState:UIControlStateNormal];
            [[headerScrollview viewWithTag:i+2] setImage:[snapshotsArr objectAtIndex:i-1] forState:UIControlStateNormal];
        }
        else
        {
            [[headerScrollview viewWithTag:i+1] setImage:[snapshotsArr objectAtIndex:i] forState:UIControlStateNormal];
        }
    }
    versionLabel.text=[NSString stringWithFormat:@"版本:%@",[resultDic objectForKey:@"versionCode"]];
    iconImageview.image=[resultDic objectForKey:@"icon"];
    nameLabel.text=[resultDic objectForKey:@"name"];
    int starNumber=[[resultDic objectForKey:@"star"] intValue];
    for (int i=0; i<starNumber; i++)
    {
        UIImageView *starImageview=[[UIImageView alloc]initWithFrame:CGRectMake(100+i*((screenWidth/2)/9), (screenHeight/5*2)+5, ((screenWidth/2)/9), ((screenWidth/2)/9))];
        [starImageview setImage:[UIImage imageNamed:@"detail_star@2x.png"]];
        [tableHeaderview addSubview:starImageview];
    }
    
    if (starNumber<5)
    {
        int i=5-starNumber;
        for (int k=0; k<i; k++)
        {
            UIImageView *startImageView=[[UIImageView alloc]initWithFrame:CGRectMake(100+(starNumber+k)*((screenWidth/2)/9),(screenHeight/5*2)+5, (screenWidth/2)/9,((screenWidth/2)/9))];
            [startImageView setImage:[UIImage imageNamed:@"detail_unstar@2x.png"]];
            [tableHeaderview addSubview:startImageView];
        }
    }
    sizeLabel.text=[NSString stringWithFormat:@"大小：%@",[resultDic objectForKey:@"size"]];
    
}
#pragma mark - 创建返回分享按钮
-(void)createHeaderbutton
{
    UIButton *backButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 30, 40, 40)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"detail_back_press@2x.png"] forState:UIControlStateNormal];
    backButton.tag=1;
    [backButton addTarget:self action:@selector(headerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    UIButton *shareButton=[[UIButton alloc]initWithFrame:CGRectMake(screenWidth-50, 30, 40, 40)];
    [shareButton setImage:[UIImage imageNamed:@"detail_share_press@2x.png"] forState:UIControlStateNormal];
    shareButton.tag=2;
    [shareButton addTarget:self action:@selector(headerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
}
#pragma mark - HEADERBUTTON点击事件
-(void)headerButton:(UIButton *)sender
{
    if (sender.tag==1)
    {
        self.navigationController.navigationBarHidden=NO;
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender.tag==2)
    {
        NSLog(@"2");
        [tableHeaderview viewWithTag:1].backgroundColor=[UIColor yellowColor];
    }
}
#pragma mark - 创建HEADERVIEW
-(void)createHeaderview
{
    tableHeaderview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight/5*2)];
    
    headerScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight/5*2)];
    headerScrollview.backgroundColor=[UIColor whiteColor];
    headerScrollview.delegate=self;
    headerScrollview.pagingEnabled=YES;
    headerScrollview.showsHorizontalScrollIndicator=NO;
    headerScrollview.showsVerticalScrollIndicator=NO;
    headerScrollview.contentSize=CGSizeMake(screenWidth*3, screenHeight/5*2);
    for (int i=0; i<6; i++)
    {
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(i*screenWidth/2, 0, screenWidth/2, screenHeight/5*2)];
        button.backgroundColor=[UIColor grayColor];
        button.tag=i+1;
        [button setBackgroundImage:[UIImage imageNamed:@"detail_image_default@2x.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(headerScrollviewBtn:) forControlEvents:UIControlEventTouchUpInside];
        [headerScrollview addSubview:button];
    }
    [tableHeaderview addSubview:headerScrollview];
    
    iconImageview=[[UIImageView alloc]initWithFrame:CGRectMake(20, (screenHeight/5*2)-35, 70, 70)];
    iconImageview.backgroundColor=[UIColor yellowColor];
    iconImageview.layer.masksToBounds=YES;
    iconImageview.layer.cornerRadius=10;
    iconImageview.image=[UIImage imageNamed:@"pic_fresh_s@2x.png"];
    [tableHeaderview addSubview:iconImageview];
    nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, (screenHeight/5*2)-25, 100, 20)];
    nameLabel.textAlignment=NSTextAlignmentLeft;
    nameLabel.textColor=[UIColor whiteColor];
    nameLabel.font=[UIFont boldSystemFontOfSize:15];
    
    [tableHeaderview addSubview:nameLabel];
    sizeLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, (screenHeight/5*2)+5+((screenWidth/2)/9), ((screenWidth/2)/9)*5+5, 35-((screenWidth/2)/9)-5)];
    sizeLabel.font=[UIFont systemFontOfSize:12];
    sizeLabel.text=@"大小：";
    [tableHeaderview addSubview:sizeLabel];
    versionLabel=[[UILabel alloc]initWithFrame:CGRectMake(100+((screenWidth/2)/9)*5+5+5,  (screenHeight/5*2)+5+((screenWidth/2)/9), ((screenWidth/2)/9)*4, 35-((screenWidth/2)/9)-5)];
    versionLabel.font=[UIFont systemFontOfSize:12];
    versionLabel.text=@"版本:";
    [tableHeaderview addSubview:versionLabel];
    
    
    
}
#pragma mark - TABLEVIEW设置
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.row==0)
    {
        UIButton *openBarbutton=[[UIButton alloc]initWithFrame:CGRectMake((screenWidth-screenWidth/8*6)/2, screenHeight/5/2-5, screenWidth/8*6, screenHeight/5/3)];
        openBarbutton.layer.borderWidth=0.3;
        openBarbutton.layer.borderColor=[UIColor grayColor].CGColor;
        openBarbutton.layer.cornerRadius=5;
        
        [openBarbutton setTitle:[NSString stringWithFormat:@"打开%@吧",[resultDic objectForKey:@"name"]] forState:UIControlStateNormal];
        if ([resultDic objectForKey:@"name"]==nil)
        {
            [openBarbutton setTitle:@"" forState:UIControlStateNormal];
        }
        [openBarbutton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [cell addSubview:openBarbutton];
        
        downButton=[[UIButton alloc]initWithFrame:CGRectMake(100+((screenWidth/2)/9)*5+10+((screenWidth/2)/9)*4, 5, screenWidth-(100+((screenWidth/2)/9)*5+10+((screenWidth/2)/9)*4)-10, ((screenWidth/2)/9)*1.3)];
        [downButton addTarget:self action:@selector(downButton:) forControlEvents:UIControlEventTouchUpInside];
        downButton.titleLabel.font=[UIFont systemFontOfSize:13];
        downButton.backgroundColor=[UIColor orangeColor];
        downButton.layer.cornerRadius=3;
        [downButton setTitle:@"" forState:UIControlStateNormal];
        if ([[resultDic objectForKey:@"price"] isEqualToString:@"0.00"])
        {
            [downButton setTitle:@"免费" forState:UIControlStateNormal];
        }
        else
        {
            [downButton setTitle:[NSString stringWithFormat:@"%@",[resultDic objectForKey:@"price"]] forState:UIControlStateNormal];
        }
        if ([resultDic objectForKey:@"price"]==nil)
        {
            [downButton setTitle:@"" forState:UIControlStateNormal];
        }
        [cell addSubview:downButton];
    }
    else if (indexPath.row==1)
    {
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 20,200, 20)];
        titleLabel.text=@"应用简介";
        titleLabel.font=[UIFont boldSystemFontOfSize:15];
        [cell addSubview:titleLabel];
        descLabel=[[UILabel alloc]init];
        descLabel.text=[resultDic objectForKey:@"desc"];
        descLabel.font=[UIFont systemFontOfSize:13];
        UIButton *contentButton=[[UIButton alloc]init];
        contentButton.titleLabel.font=[UIFont systemFontOfSize:12];
        contentButton.backgroundColor=[UIColor magentaColor];
        contentButton.layer.cornerRadius=3;
        [contentButton addTarget:self action:@selector(contentTap:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:contentButton];
        
        if (!isOpen)
        {
            descLabel.numberOfLines=2;
            descLabel.lineBreakMode=NSLineBreakByCharWrapping;
            descLabel.frame=CGRectMake(20, 40, screenWidth-20, 40);
            [contentButton setTitle:@"展开" forState:UIControlStateNormal];
            contentButton.frame=CGRectMake(screenWidth-10-40, 90, 40, 15);
        }
        else
        {
            CGRect tmpRect=[[resultDic objectForKey:@"desc"] boundingRectWithSize:CGSizeMake(screenWidth-20, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:descLabel.font,NSFontAttributeName, nil] context:nil];
            descLabel.text=[resultDic objectForKey:@"desc"];
            descLabel.frame=CGRectMake(20, 40, tmpRect.size.width, tmpRect.size.height);
            descLabel.numberOfLines=0;
            descLabel.lineBreakMode=NSLineBreakByCharWrapping;
            [contentButton setTitle:@"收起" forState:UIControlStateNormal];
            contentButton.frame=CGRectMake(screenWidth-10-40, 60+tmpRect.size.height, 40, 15);
        }
        [cell addSubview:descLabel];
        
    }
    else if (indexPath.row==2)
    {
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 20, 200, 20)];
        titleLabel.text=@"下载此应用的人也下载了";
        titleLabel.font=[UIFont boldSystemFontOfSize:15];
        [cell addSubview:titleLabel];
        UIScrollView *recommendScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(10, 40, screenWidth-20, screenHeight/5-40)];
        
        NSArray *recomArr=[resultDic objectForKey:@"recommend"];
        for (int i=0;i<recomArr.count;i++)
        {
            NSDictionary *dic=[recomArr objectAtIndex:i];
            UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(i*(57+10+10), 0, 57+10, 57+10)];
            button.layer.cornerRadius=10;
            button.layer.masksToBounds=YES;
            [button setImage:[dic objectForKey:@"icon"] forState:UIControlStateNormal];
            button.tag=i+1;
            [button addTarget:self action:@selector(recomButton:) forControlEvents:UIControlEventTouchUpInside];
            [recommendScrollview addSubview:button];
        }
        recommendScrollview.contentSize=CGSizeMake(recomArr.count*77, screenHeight/5-40);
        recommendScrollview.showsHorizontalScrollIndicator=NO;
        recommendScrollview.showsVerticalScrollIndicator=NO;
        [cell addSubview:recommendScrollview];
    }
    else if (indexPath.row==3)
    {
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 20, 300, 20)];
        titleLabel.text=@"信息";
        titleLabel.font=[UIFont boldSystemFontOfSize:15];
        [cell addSubview:titleLabel];
        UILabel *downtimes=[[UILabel alloc]initWithFrame:CGRectMake(20, 40, 300, 20)];
        downtimes.text=[NSString stringWithFormat:@"下   载:%@次下载",[resultDic objectForKey:@"downTimes"]];
        downtimes.font=[UIFont systemFontOfSize:13];
        [cell addSubview:downtimes];
        UILabel *classLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 60, 300, 20)];
        classLabel.text=[NSString stringWithFormat:@"分   类:%@",[resultDic objectForKey:@"cateName"]];
        classLabel.font=[UIFont systemFontOfSize:13];
        [cell addSubview:classLabel];
        UILabel *timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 80, 300, 20)];
        timeLabel.text=[NSString stringWithFormat:@"分   类:%@",[resultDic objectForKey:@"updateTime"]];
        timeLabel.font=[UIFont systemFontOfSize:13];
        [cell addSubview:timeLabel];
        UILabel *lauguageLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 100, 300, 20)];
        lauguageLabel.text=@"语   言:";
        lauguageLabel.text=[NSString stringWithFormat:@"语   言:%@",[resultDic objectForKey:@"lan"]];
        lauguageLabel.font=[UIFont systemFontOfSize:13];
        [cell addSubview:lauguageLabel];
        UILabel *authorLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 120, 300, 20)];
        authorLabel.text=[NSString stringWithFormat:@"作   者:%@",[resultDic objectForKey:@"author"]];
        authorLabel.font=[UIFont systemFontOfSize:13];
        [cell addSubview:authorLabel];
        compatibilityLabel=[[UILabel alloc]init];
        compatibilityLabel.text=[NSString stringWithFormat:@"兼容性:%@",[resultDic objectForKey:@"requirement"]];
        compatibilityLabel.font=[UIFont systemFontOfSize:13];
        
        compatibilityLabel.numberOfLines=0;
        compatibilityLabel.lineBreakMode=NSLineBreakByCharWrapping;
        CGRect tmpRect=[compatibilityLabel.text boundingRectWithSize:CGSizeMake(screenWidth-20, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:compatibilityLabel.font,NSFontAttributeName, nil] context:nil];
        compatibilityLabel.frame=CGRectMake(20, 140, tmpRect.size.width, tmpRect.size.height);
        [cell addSubview:compatibilityLabel];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowHeight = 0;
    if (indexPath.row==0)
    {
        rowHeight=screenHeight/5;
    }
    else if (indexPath.row==1)
    {
        rowHeight=80+descLabel.frame.size.height;
    }
    if (indexPath.row==2)
    {
        rowHeight=screenHeight/5;
    }
    else if (indexPath.row==3)
    {
        rowHeight=200+compatibilityLabel.frame.size.height;
    }
    return rowHeight;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title=@"";
    if (section==1)
    {
        title=@"应用简介";
    }
    else if (section==2)
    {
        title=@"下载此应用的人也下载了";
    }
    else if (section==3)
    {
        title=@"信息";
    }
    return title;
}
#pragma mark - CELL上展开全文点击事件
-(void)contentTap:(UIButton *)sender
{
    if (!isOpen)
    {
        isOpen=YES;
        [tableview reloadData];
    }
    else
    {
        isOpen=NO;
        [tableview reloadData];
    }
    
    
}
#pragma mark - 推荐应用点击事件
-(void)recomButton:(UIButton *)sender
{
    NSArray *recomArr=[resultDic objectForKey:@"recommend"];
    NSDictionary *recomDic=[recomArr objectAtIndex:sender.tag-1];
    AppDetailViewController *appdetailVC=[[AppDetailViewController alloc]init];
    appdetailVC.detailUrlpath=[recomDic objectForKey:@"detailUrl"];
    [self.navigationController pushViewController:appdetailVC animated:YES];
}
#pragma 顶部滚动视图图片点击放大
-(void)headerScrollviewBtn:(UIButton *)sender
{
    UIButton *button=[[UIButton alloc]init];
    [button setBackgroundImage:sender.imageView.image forState:UIControlStateNormal];
    button.frame=[UIScreen mainScreen].bounds;
    [button addTarget:self action:@selector(closeImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
-(void)closeImage:(UIButton *)sender
{
    [sender removeFromSuperview];
}
-(void)downButton:(UIButton *)sender
{
    [self openAppWithResId:[resultDic objectForKey:@"resId"] andWithViewController:self];
}
#pragma mark - 打开appstore
-(void)openAppWithResId:(NSString *)resid andWithViewController:(UIViewController *)view
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showWithStatus:@"正在载入.."];
    
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:resid forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [view presentViewController:storeProductVC animated:YES completion:nil];
        }
        if ([appdelegate isHasNetwork]==NO)
        {
            [SVProgressHUD setStatus:@"加载失败,请稍后重试..."];
            [SVProgressHUD dismissWithDelay:3];
        }
    }];
}
-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 滚动title

@end
