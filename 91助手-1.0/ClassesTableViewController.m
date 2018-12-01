//
//  ClassesTableViewController.m
//  91助手-1.0
//
//  Created by Raizo on 15/10/29.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "ClassesTableViewController.h"

@interface ClassesTableViewController ()
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    AppDelegate *appdelegate;
    FMDatabase *db;
    FMDatabaseQueue *queue;
    
    NSMutableArray *onetablecellArr;
    NSMutableArray *twotablecellArr;
    
    UISegmentedControl *segmented;
    UITableView *oneTable;
    UITableView *twoTable;
}
@end

@implementation ClassesTableViewController
-(void)viewWillAppear:(BOOL)animated
{
    [self createSegmentedcontrol];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [segmented removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    screenWidth=[UIScreen mainScreen].bounds.size.width;
    screenHeight=[UIScreen mainScreen].bounds.size.height;
    
    self.navigationController.navigationBar.translucent=NO;
    self.tabBarController.tabBar.tintColor=[UIColor orangeColor];
    self.navigationController.navigationBar.barTintColor=[UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.view.backgroundColor=[UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    appdelegate=[UIApplication sharedApplication].delegate;
    db=appdelegate.db;
    queue=[AppDelegate getSharedDatabaseQueue];
    
    onetablecellArr=[[NSMutableArray alloc]init];
    twotablecellArr=[[NSMutableArray alloc]init];
    
    
    oneTable=[[UITableView alloc]init];
    twoTable=[[UITableView alloc]init];
    self.tableView=oneTable;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"three"]==nil)
    {
        if([appdelegate isHasNetwork]==NO)
        {
            return;
        }
        NSString *str=@"three";
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"three"];
        [self getdatafromnet];
    }
    else
    {
        
        [self getdatafromsql];
        if([appdelegate isHasNetwork]==NO)
        {
            return;
        }
        else
        {
            [self getdatafromnet];
        }
    }
    
    
}
#pragma mark - 从网络获得数据
-(void)getdatafromnet
{
    [self gettablecelldatafromnetWithUrlPath:@"http://applebbx.sj.91.com/soft/phone/cat.aspx?act=213&cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&pi=1&spid=2&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&osv=9.1&dm=iPhone7,1&sv=3.1.3&nt=10&mt=1&pid=2" andWithTableNumber:@"1" andWithCellArr:onetablecellArr];
    [self gettablecelldatafromnetWithUrlPath:@"http://applebbx.sj.91.com/soft/phone/cat.aspx?act=218&cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&pi=1&spid=2&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&osv=9.1&dm=iPhone7,1&sv=3.1.3&nt=10&mt=1&pid=2" andWithTableNumber:@"2" andWithCellArr:twotablecellArr];
}
-(void)getdatafromsql
{
    [self gettablecelldatafromsqlWithTableNumber:@"1" andWithCellArr:onetablecellArr];
    [self gettablecelldatafromsqlWithTableNumber:@"2" andWithCellArr:twotablecellArr];
}
#pragma mark - 从服务器获取CELL数据
-(void)gettablecelldatafromnetWithUrlPath:(NSString *)urlPath andWithTableNumber:(NSString *)tablenumber andWithCellArr:(NSMutableArray *)cellarr
{
    NSURL *url=[NSURL URLWithString:urlPath];
    NSURLSessionConfiguration *config=[NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *datadic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray *arr=[datadic objectForKey:@"Result"];
        NSMutableArray *dataarr=[[NSMutableArray alloc]init];
        
        for (int i=0; i<arr.count; i++)
        {
            NSMutableDictionary *mydic=[[NSMutableDictionary alloc]init];
            mydic=[NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:i]];
            NSData *mydata=[NSData dataWithContentsOfURL:[NSURL URLWithString:[mydic objectForKey:@"icon"]]];
            
            if (mydata==nil)
            {
                NSString *path=[[NSBundle mainBundle] pathForResource:@"pic_fresh_s@2x.png" ofType:nil];
                mydata=[NSData dataWithContentsOfFile:path];
                [mydic setObject:mydata forKey:@"imagedata"];
            }
            else
            {
                [mydic setObject:mydata forKey:@"imagedata"];
            }
            [mydic setObject:tablenumber forKey:@"tablenumber"];
            NSMutableArray *listtagsArr=[mydic objectForKey:@"listTags"];
            [mydic removeObjectForKey:@"listTags"];
            for (int i=0; i<listtagsArr.count; i++)
            {
                NSDictionary *listtagsDic=[listtagsArr objectAtIndex:i];
                NSString *tagName=[listtagsDic objectForKey:@"tagName"];
                NSString *url_=[listtagsDic objectForKey:@"url"];
                
                [mydic setObject:url_ forKey:tagName];
            }
            [dataarr addObject:mydic];
            
        }
        
        
        [cellarr removeAllObjects];
        [cellarr addObjectsFromArray:dataarr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [queue inDatabase:^(FMDatabase *database)
         {
             [database executeUpdate:@"delete from classescell where tablenumber=?",tablenumber];
             for (NSDictionary *mydic in cellarr)
             {
                 [database executeUpdate:@"insert into classescell (name,icon,summary,imagedata,限时免费,免费应用,降价应用,收费应用,tablenumber) values (?,?,?,?,?,?,?,?,?)",[mydic objectForKey:@"name"],[mydic objectForKey:@"icon"],[mydic objectForKey:@"summary"],[mydic objectForKey:@"imagedata"],[mydic objectForKey:@"限时免费"],[mydic objectForKey:@"免费应用"],[mydic objectForKey:@"降价应用"],[mydic objectForKey:@"收费应用"],[mydic objectForKey:@"tablenumber"]];
             }
         }];
    }];
    [task resume];
}
#pragma mark - 从本地数据库获取CELL数据
-(void)gettablecelldatafromsqlWithTableNumber:(NSString *)tablenumber andWithCellArr:(NSMutableArray *)cellarr
{
    FMResultSet *result=[db executeQuery:@"select * from classescell where tablenumber=?",tablenumber];
    while ([result next])
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        for (int i=0; i<[result columnCount]; i++)
        {
            if ([[result columnNameForIndex:i]isEqualToString:@"imagedata"])
            {
                [dic setObject:[result dataForColumnIndex:i] forKey:[result columnNameForIndex:i]];
            }
            else
            {
                [dic setObject:[result stringForColumnIndex:i] forKey:[result columnNameForIndex:i]];
            }
        }
        [cellarr addObject:dic];
        
    }
    [self.tableView reloadData];
}
#pragma mark - 创建NAVIGATION BAR上的分页控制器
-(void)createSegmentedcontrol
{
    CGFloat segmentedWeight=screenWidth/3*2;
    segmented=[[UISegmentedControl alloc]initWithFrame:CGRectMake(screenWidth/2-segmentedWeight/2, 4, segmentedWeight, 30)];
    [segmented insertSegmentWithTitle:@"应用" atIndex:0 animated:NO];
    [segmented insertSegmentWithTitle:@"游戏" atIndex:1 animated:NO];
    [segmented setSelectedSegmentIndex:0];
    segmented.tintColor=[UIColor whiteColor];
    [segmented addTarget:self action:@selector(segmentedTap:) forControlEvents:UIControlEventValueChanged];
    [self.navigationController.navigationBar addSubview:segmented];
}
#pragma mark - 分页控制器点击事件
-(void)segmentedTap:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex==0)
    {
        self.tableView=oneTable;
        [self.tableView reloadData];
    }
    else if(sender.selectedSegmentIndex==1)
    {
        self.tableView=twoTable;
        [self.tableView reloadData];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rowNumber=0;
    if (tableView==oneTable)
    {
        rowNumber=onetablecellArr.count;
    }
    else if (tableView==twoTable)
    {
        rowNumber=twotablecellArr.count;
    }
    return rowNumber;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 60, 60)];
    imageview.backgroundColor=[UIColor whiteColor];
    imageview.layer.masksToBounds=YES;
    imageview.layer.cornerRadius=10;
    [cell addSubview:imageview];
    UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(80, 10, 80, 20)];
    namelable.backgroundColor=[UIColor whiteColor];
    [cell addSubview:namelable];
    UILabel *summarylabel=[[UILabel alloc]initWithFrame:CGRectMake(80, 45, screenWidth-80, 15)];
    summarylabel.backgroundColor=[UIColor whiteColor];
    summarylabel.font=[UIFont systemFontOfSize:12];
    [cell addSubview:summarylabel];
    if (tableView==oneTable)
    {
        NSData *data=[[onetablecellArr objectAtIndex:indexPath.row] objectForKey:@"imagedata"];
        imageview.image=[UIImage imageWithData:data];
        namelable.text=[[onetablecellArr objectAtIndex:indexPath.row] objectForKey:@"name"];
        summarylabel.text=[[onetablecellArr objectAtIndex:indexPath.row] objectForKey:@"summary"];
    }
    
    else if (self.tableView==twoTable)
    {
        NSData *data=[[twotablecellArr objectAtIndex:indexPath.row] objectForKey:@"imagedata"];
        imageview.image=[UIImage imageWithData:data];
        namelable.text=[[twotablecellArr objectAtIndex:indexPath.row] objectForKey:@"name"];
        summarylabel.text=[[twotablecellArr objectAtIndex:indexPath.row] objectForKey:@"summary"];
    }
    UIView *underView=[[UIView alloc]initWithFrame:CGRectMake(0, 70-1, screenWidth, 1)];
    underView.backgroundColor=[UIColor lightGrayColor];
    [cell addSubview:underView];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==oneTable)
    {
        ClassesAppListTableViewController *classesapplist=[[ClassesAppListTableViewController alloc]initWithStyle:UITableViewStylePlain];
        classesapplist.xsmfUrl=[[onetablecellArr objectAtIndex:indexPath.row] objectForKey:@"限时免费"];
        classesapplist.mfyyUrl=[[onetablecellArr objectAtIndex:indexPath.row] objectForKey:@"免费应用"];
        classesapplist.jjyyUrl=[[onetablecellArr objectAtIndex:indexPath.row] objectForKey:@"降价应用"];
        classesapplist.sfyyUrl=[[onetablecellArr objectAtIndex:indexPath.row] objectForKey:@"收费应用"];
        classesapplist.navigationtitle=[[onetablecellArr objectAtIndex:indexPath.row] objectForKey:@"name"];
        UIBarButtonItem *backBarbutton=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.backBarButtonItem=backBarbutton;
        [self.navigationController pushViewController:classesapplist animated:YES];
    }
    else if (self.tableView==twoTable)
    {
        ClassesAppListTableViewController *classesapplist=[[ClassesAppListTableViewController alloc]initWithStyle:UITableViewStylePlain];
        classesapplist.xsmfUrl=[[twotablecellArr objectAtIndex:indexPath.row] objectForKey:@"限时免费"];
        classesapplist.mfyyUrl=[[twotablecellArr objectAtIndex:indexPath.row] objectForKey:@"免费应用"];
        classesapplist.jjyyUrl=[[twotablecellArr objectAtIndex:indexPath.row] objectForKey:@"降价应用"];
        classesapplist.sfyyUrl=[[twotablecellArr objectAtIndex:indexPath.row] objectForKey:@"收费应用"];
        classesapplist.navigationtitle=[[twotablecellArr objectAtIndex:indexPath.row] objectForKey:@"name"];
        UIBarButtonItem *backBarbutton=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.backBarButtonItem=backBarbutton;
        [self.navigationController pushViewController:classesapplist animated:YES];
    }
}

@end
