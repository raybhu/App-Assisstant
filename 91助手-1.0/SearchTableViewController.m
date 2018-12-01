//
//  SearchTableViewController.m
//  91助手-1.0
//
//  Created by Raizo on 15/11/3.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "SearchTableViewController.h"

@interface SearchTableViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    UISearchController *searchController;
    UITableViewController *searchresultTVC;
    
    NSMutableArray *searchhistoryArr;
    NSMutableArray *searchrecommendArr;
    NSMutableArray *searchresultArr;
    
    
    AppListTableViewController *applist;
}
@end

@implementation SearchTableViewController
-(void)viewWillAppear:(BOOL)animated
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    screenWidth=[UIScreen mainScreen].bounds.size.width;
    screenHeight=[UIScreen mainScreen].bounds.size.height;
    self.tableView.scrollEnabled=NO;
    self.tableView.rowHeight=screenWidth/2;
    self.tableView.sectionHeaderHeight=20;
    self.definesPresentationContext=YES;
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.translucent=NO;
    self.navigationController.navigationBar.barTintColor=[UIColor blackColor];
    [self createSearchcontroller];
    searchhistoryArr=[[NSMutableArray alloc]init];
    searchrecommendArr=[[NSMutableArray alloc]init];
    searchresultArr=[[NSMutableArray alloc]init];
    [self getrecommendDatafromnet];
}
#pragma mark - 创建搜索框
-(void)createSearchcontroller
{
    searchresultTVC=[[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    searchresultTVC.tableView.backgroundColor=[UIColor clearColor];
    searchresultTVC.tableView.dataSource=self;
    searchresultTVC.tableView.delegate=self;
    searchresultTVC.automaticallyAdjustsScrollViewInsets=NO;
    
    searchController=[[UISearchController alloc]initWithSearchResultsController:searchresultTVC];
    searchController.searchBar.delegate=self;
    searchController.searchResultsUpdater=self;
    searchController.hidesNavigationBarDuringPresentation=NO;
    searchController.dimsBackgroundDuringPresentation=YES;
    self.navigationItem.titleView=searchController.searchBar;
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
    {
        [applist.view removeFromSuperview];
    }
}

-(void)updateSearchResultsForSearchController:(UISearchController *)SC
{
    searchresultTVC.view.frame=CGRectMake(20, 0, screenWidth-40, 200);
    [self getpreviewDatafromnetWithKeyWord:SC.searchBar.text];
}
#pragma mark - 搜索结果预览数据
-(void)getpreviewDatafromnetWithKeyWord:(NSString *)keyword
{
    keyword=[keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlPath=[NSString stringWithFormat:@"http://suggestion.sj.91.com/service.ashx?keyword=%@&spid=2&osv=9.1&size=30&cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&sv=3.1.3&dm=iPhone7,1&act=303&nt=10&pid=2&mt=1",keyword];
    NSURL *url=[NSURL URLWithString:urlPath];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data==nil)
        {
            return;
        }
        NSDictionary *jsonDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (jsonDic==nil)
        {
            return;
        }
        searchresultArr=[NSMutableArray arrayWithArray:[jsonDic objectForKey:@"words"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [searchresultTVC.tableView reloadData];
        });
    }];
    [task resume];
}
#pragma mark - 接收推荐搜索数据
-(void)getrecommendDatafromnet
{
    NSString *urlPath=@"http://applebbx.sj.91.com/softs.ashx?cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&act=104&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&spid=2&osv=9.1&dm=iPhone7,1&sv=3.1.3&nt=10&mt=1&pid=2";
    NSURL *url=[NSURL URLWithString:urlPath];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *jsonDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        searchrecommendArr=[NSMutableArray arrayWithArray:[jsonDic objectForKey:@"Result"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    [task resume];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int sectionNumber;
    if (tableView==searchresultTVC.tableView)
    {
        sectionNumber=1;
    }
    else if (tableView==self.tableView)
    {
        sectionNumber=2;
    }
    return sectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rowNumber;
    if (tableView==searchresultTVC.tableView)
    {
        rowNumber=(int)searchresultArr.count;
    }
    else if (tableView==self.tableView)
    {
        rowNumber=1;
    }
    return rowNumber;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerSectionview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, screenWidth/2, 20)];
    
    [headerSectionview addSubview:titleLabel];
    NSString *sectionTitle=@"";
    if (tableView==searchresultTVC.tableView)
    {
        sectionTitle=@"";
    }
    else if (tableView==self.tableView)
    {
        if (section==0)
        {
            sectionTitle=@"热门搜索";
        }
        else if (section==1)
        {
            
            
            UIButton *deleteHistorybutton=[[UIButton alloc]initWithFrame:CGRectMake(screenWidth-40, 0, 20, 20)];
            [deleteHistorybutton setImage:[UIImage imageNamed:@"del_nor@2x.png"] forState:UIControlStateNormal];
            [deleteHistorybutton setImage:[UIImage imageNamed:@"del_click@2x.png"] forState:UIControlStateHighlighted];
            [deleteHistorybutton addTarget:self action:@selector(deleteHistory:) forControlEvents:UIControlEventTouchUpInside];
            
            if (searchhistoryArr.count>0)
            {
                sectionTitle=@"搜索历史";
                [headerSectionview addSubview:deleteHistorybutton];
            }
        }
    }
    //headerSectionview.backgroundColor=[UIColor whiteColor];
    titleLabel.text=sectionTitle;
    return headerSectionview;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selected=NO;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (tableView==searchresultTVC.tableView)
    {
        
            cell.textLabel.text=[searchresultArr objectAtIndex:indexPath.row];
        
    }
    else if (tableView==self.tableView)
    {
        if (indexPath.section==0)
        {
            CGFloat tmpWidth=0;
            int tmp=1;
            CGFloat buttonY=10;
            for (int i=0; i<searchrecommendArr.count; i++)
            {
                CGRect tmpRect=[[searchrecommendArr objectAtIndex:i] boundingRectWithSize:CGSizeMake(100,100) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14],NSFontAttributeName, nil] context:nil];
                UIButton *button=[[UIButton alloc]init];
                [button setTitle:[searchrecommendArr objectAtIndex:i] forState:UIControlStateNormal];
                button.tag=i+1;
                if (i==4)
                {
                    buttonY=10+20+10;
                    tmpWidth=0;
                    tmp-=4;
                }
                else if (i==8)
                {
                    buttonY=40+30;
                    tmpWidth=0;
                    tmp-=4;
                }
                
                button.frame=CGRectMake(10*tmp+tmpWidth, buttonY, tmpRect.size.width+[UIScreen mainScreen].bounds.size.width/12, 20);
                tmp++;
                tmpWidth+=tmpRect.size.width+[UIScreen mainScreen].bounds.size.width/12;
                
                CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
                CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
                CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
                button.backgroundColor=[UIColor colorWithRed:hue green:saturation blue:brightness alpha:1];
                
                button.titleLabel.font=[UIFont systemFontOfSize:14];
                [button addTarget:self action:@selector(searchRecommendtap:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:button];
            }
            
        }
        else if (indexPath.section==1)
        {
            CGFloat tmpWidth=0;
            int tmp=1;
            CGFloat buttonY=10;
            for (int i=0; i<searchhistoryArr.count; i++)
            {
                CGRect tmpRect=[[searchrecommendArr objectAtIndex:i] boundingRectWithSize:CGSizeMake(100,100) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14],NSFontAttributeName, nil] context:nil];
                UIButton *button=[searchhistoryArr objectAtIndex:i];
                if (i==4)
                {
                    buttonY=10+20+10;
                    tmpWidth=0;
                    tmp-=4;
                }
                else if (i==8)
                {
                    buttonY=40+30;
                    tmpWidth=0;
                    tmp-=4;
                }
                button.titleLabel.font=[UIFont systemFontOfSize:14];
                button.frame=CGRectMake(10*tmp+tmpWidth, buttonY, tmpRect.size.width+[UIScreen mainScreen].bounds.size.width/12, 20);
                tmp++;
                tmpWidth+=tmpRect.size.width+[UIScreen mainScreen].bounds.size.width/12;
                [cell addSubview:button];
            }
            
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==searchresultTVC.tableView)
    {
        NSString *keyword=[searchresultArr objectAtIndex:indexPath.row];
        [self getApplistfromnetWithKeyWord:keyword];
    }
}

-(void)getApplistfromnetWithKeyWord:(NSString *)keyword
{
    NSString *utf8Str=[keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlPath=[NSString stringWithFormat:@"http://applebbx.sj.91.com/api/?keyword=%@&pi=1&spid=2&osv=9.1&cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&dm=iPhone7,1&sv=3.1.3&act=203&nt=10&pid=2&mt=1",utf8Str];
    NSLog(@"%@",urlPath);
    applist=[[AppListTableViewController alloc]initWithStyle:UITableViewStylePlain];
    
    applist.targeturl=urlPath;
    [self addChildViewController:applist];
    [self.view addSubview:applist.view];
    [self didMoveToParentViewController:applist];
    applist.view.frame=CGRectMake(0, 0, screenWidth, screenHeight-110);
    
    

    searchController.active=NO;
    searchController.searchBar.text=keyword;
}

-(void)searchRecommendtap:(UIButton *)sender
{
    [self getApplistfromnetWithKeyWord:sender.titleLabel.text];
    if (searchhistoryArr.count<=10)
    {
        for (UIButton *button in searchhistoryArr)
        {
            if ([button.titleLabel.text isEqualToString:sender.titleLabel.text])
            {
                return;
            }
        }
        UIButton *button=[[UIButton alloc]init];
        [button setTitle:sender.titleLabel.text forState:UIControlStateNormal];
        [button setBackgroundColor:sender.backgroundColor];
        [searchhistoryArr addObject:button];
        //[self.tableView reloadData];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
    }
    
    NSLog(@"%@",sender.titleLabel.text);
}
-(void)deleteHistory:(UIButton *)sender
{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:@"确定删除全部记录?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOK=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [searchhistoryArr removeAllObjects];
        [self.tableView reloadData];
    }];
    UIAlertAction *actionCancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:actionOK];
    [alert addAction:actionCancel];

    [self presentViewController:alert animated:YES completion:nil];
    
    
}
#pragma mark - 开始搜索
@end
