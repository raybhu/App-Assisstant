//
//  HomePageTableViewController.m
//  91助手-1.0
//
//  Created by Raizo on 15/10/27.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "HomePageTableViewController.h"

@interface HomePageTableViewController ()
{
    
    CGFloat screenWidth;
    CGFloat screenHeight;
    AppDelegate *appdelegate;
    FMDatabase *db;
    FMDatabaseQueue *queue;
    UIScrollView *scrollView;
    UIPageControl *pageController;
    NSTimer *timer;
    
    UIScrollView *sectiononecellScrollView;
    UIScrollView *sectionthreecellScrollView;
    UIView *sectionfourView;
    
    NSMutableArray *sectionArr;
    NSMutableArray *scrollviewArr;
    NSMutableArray *sectiononeArr;
    NSMutableArray *sectiontwoArr;
    NSMutableArray *sectionthreeArr;
    NSMutableArray *sectionfourArr;
    NSMutableArray *sectionfiveArr;
    NSMutableArray *sectionsixArr;
    
    int currentScrollviewpage;
    
    int refreshTime;
    
}
@end

@implementation HomePageTableViewController
#pragma mark - ----------------------------------------------------------
#pragma mark - ---------------------视图载入完成-------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    refreshTime=0;
    
    screenWidth=[UIScreen mainScreen].bounds.size.width;
    screenHeight=[UIScreen mainScreen].bounds.size.height;
    
    self.tabBarController.tabBar.tintColor=[UIColor orangeColor];
    self.navigationController.navigationBar.barTintColor=[UIColor blackColor];
    self.navigationItem.title=@"App助手";
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.view.backgroundColor=[UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    appdelegate=[UIApplication sharedApplication].delegate;
    db=appdelegate.db;
    queue=[AppDelegate getSharedDatabaseQueue];
    
    scrollviewArr=[[NSMutableArray alloc]init];
    sectionArr=[[NSMutableArray alloc]init];
    sectiononeArr=[[NSMutableArray alloc]init];
    sectiontwoArr=[[NSMutableArray alloc]init];
    sectionthreeArr=[[NSMutableArray alloc]init];
    sectionfourArr=[[NSMutableArray alloc]init];
    sectionfiveArr=[[NSMutableArray alloc]init];
    sectionsixArr=[[NSMutableArray alloc]init];
    
    
    
    [self createScrollview];
    
    //判断是否为第一次打开
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"one"]==nil)
    {
        if([appdelegate isHasNetwork]==NO)
        {
            return;
        }
        NSString *str=@"one";
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"one"];
        [self getAlldatafromnet];
    }
    else
    {
        [self getAlldatafromsql];
        if([appdelegate isHasNetwork]==NO)
        {
            return;
        }
        else
        {
            [self getAlldatafromnet];
        }
    }
    self.tableView.header=[MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    

}
#pragma mark - 下拉刷新
-(void)refresh
{
    scrollviewArr=[[NSMutableArray alloc]init];
    sectionArr=[[NSMutableArray alloc]init];
    sectiononeArr=[[NSMutableArray alloc]init];
    sectiontwoArr=[[NSMutableArray alloc]init];
    sectionthreeArr=[[NSMutableArray alloc]init];
    sectionfourArr=[[NSMutableArray alloc]init];
    sectionfiveArr=[[NSMutableArray alloc]init];
    sectionsixArr=[[NSMutableArray alloc]init];
    NSLog(@"1");
    [self getAlldatafromnet];
}
#pragma mark - ----------------------------------------------------------
#pragma mark - -------------------从网络刷新全部数据---------------------
-(void)getAlldatafromnet
{
    [self getSectiondatafromnetWithPage:@"1"];
    [self getScrollviewdatafromnet];
    [self getAppdatafromnetWithUrlPath:@"http://applebbx.sj.91.com/api/?act=246&cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&spid=2&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&osv=9.1&dm=iPhone7,1&sv=3.1.3&top=15&mt=1&nt=10&pid=2" andWithAppArr:sectiononeArr andWithPage:@"1" andWithSection:@"0"];
    [self getAppdatafromnetWithUrlPath:@"http://applebbx.sj.91.com/soft/phone/list.aspx?cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&act=244&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&spid=2&osv=9.1&dm=iPhone7,1&sv=3.1.3&top=20&mt=1&nt=10&pid=2" andWithAppArr:sectiontwoArr andWithPage:@"1" andWithSection:@"1"];
    [self getAppdatafromnetWithUrlPath:@"http://applebbx.sj.91.com/api/?act=236&cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&spid=2&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&osv=9.1&dm=iPhone7,1&sv=3.1.3&top=15&mt=1&nt=10&pid=2" andWithAppArr:sectionthreeArr andWithPage:@"1" andWithSection:@"2"];
    [self getAppspecialfromnet];
    [self getAppdatafromnetWithUrlPath:@"http://applebbx.sj.91.com/soft/phone/list.aspx?cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&act=245&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&spid=2&osv=9.1&dm=iPhone7,1&sv=3.1.3&top=10&mt=1&nt=10&pid=2" andWithAppArr:sectionfiveArr andWithPage:@"1" andWithSection:@"4"];
    [self getAppdatafromnetWithUrlPath:@"http://applebbx.sj.91.com/soft/phone/list.aspx?skip=10&mt=1&spid=2&osv=9.1&cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&dm=iPhone7,1&sv=3.1.3&act=244&nt=10&pid=2&top=10" andWithAppArr:sectionsixArr andWithPage:@"1" andWithSection:@"5"];
}
#pragma mark - -------------------从数据库读取全部数据---------------------
-(void)getAlldatafromsql
{
    [self getSectiondatafromsqlWithPage:@"1"];
    [self getScrollviewdatafromsql];
    [self getAppdatafromsqlWithAppArr:sectiononeArr andWithPage:@"1" andWithSection:@"0"];
    [self getAppdatafromsqlWithAppArr:sectiontwoArr andWithPage:@"1" andWithSection:@"1"];
    [self getAppdatafromsqlWithAppArr:sectionthreeArr andWithPage:@"1" andWithSection:@"2"];
    [self getAppspecialfromsql];
    [self getAppdatafromsqlWithAppArr:sectionfiveArr andWithPage:@"1" andWithSection:@"4"];
    [self getAppdatafromsqlWithAppArr:sectionsixArr andWithPage:@"1" andWithSection:@"5"];
}
#pragma mark - -------------------创建主页头滚动视图---------------------
#pragma mark - 创建主页顶部滚动视图
-(void)createScrollview
{
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight/4)];
    scrollView.contentSize=CGSizeMake(screenWidth*3, screenHeight/4);
    scrollView.pagingEnabled=YES;
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.showsVerticalScrollIndicator=NO;
    scrollView.delegate=self;
    self.tableView.tableHeaderView=scrollView;
    
    pageController=[[UIPageControl alloc]init];
    pageController.frame=CGRectMake(screenWidth/2-15, scrollView.frame.size.height-15, 30, 5);
    pageController.currentPageIndicatorTintColor=[UIColor orangeColor];
    pageController.numberOfPages=3;
    
}
#pragma mark - 滚动视图通过滚动从而控制页面控制器
-(void)scrollViewDidScroll:(UIScrollView *)sV
{
    int i=(scrollView.contentOffset.x+scrollView.frame.size.width/2)/scrollView.frame.size.width;
    pageController.currentPage=i%3;
}
#pragma mark - 滚动视图利用定时器自动滚动
-(void)scroll
{
    if (scrollviewArr.count==0)
    {
        return;
    }
    int i=currentScrollviewpage%scrollviewArr.count;
    scrollView.contentOffset = CGPointMake(i*screenWidth, 0);
    currentScrollviewpage++;
    if (currentScrollviewpage==3)
    {
        currentScrollviewpage=0;
    }
}
#pragma mark - 滚动视图的点击事件
-(void)scrollviewTap:(UIButton *)bTn
{
    NSString *urlPath=[[scrollviewArr objectAtIndex:bTn.tag-1] objectForKey:@"TargetUrl"];
    AppListTableViewController *applist=[[AppListTableViewController alloc]initWithStyle:UITableViewStylePlain];
    applist.targeturl=urlPath;
    applist.navigationtitle=[[scrollviewArr objectAtIndex:bTn.tag-1] objectForKey:@"Desc"];
    UIBarButtonItem *backBarbutton=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backBarbutton;
    [self.navigationController pushViewController:applist animated:YES];
}
#pragma mark - ----------------------------------------------------------
#pragma mark - -----------------------获取数据---------------------------
#pragma mark - 从服务器获取主页头滚动视图数据
-(void)getScrollviewdatafromnet
{
    NSString *urlPath=@"http://applebbx.sj.91.com/softs.ashx?spid=2&osv=9.1&cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&adlt=1&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&dm=iPhone7,1&sv=3.1.3&act=222&places=1&nt=10&pid=2&mt=1";
    NSURL *url=[NSURL URLWithString:urlPath];
    NSURLSessionConfiguration *config=[NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data==nil)
        {
            return;
        }
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray *arr=[dic objectForKey:@"Result"];
        NSDictionary *dic1=[arr objectAtIndex:0];
        NSArray *arr1=[dic1 objectForKey:@"Value"];
        [scrollviewArr removeAllObjects];
        for (int i=0; i<arr1.count; i++)
        {
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            dic=[NSMutableDictionary dictionaryWithDictionary:[arr1 objectAtIndex:i]];
            NSURL *imageurl=[NSURL URLWithString:[dic objectForKey:@"LogoUrl"]];
            NSData *imagedata=[NSData dataWithContentsOfURL:imageurl];
            if (imagedata==nil)
            {
                NSString *path=[[NSBundle mainBundle] pathForResource:@"detail_image_default@2x.png" ofType:nil];
                imagedata=[NSData dataWithContentsOfFile:path];
                [dic setObject:imagedata forKey:@"imagedata"];
            }
            else
            {
                [dic setObject:imagedata forKey:@"imagedata"];
            }
            [dic setObject:imagedata forKey:@"imagedata"];
            [scrollviewArr addObject:dic];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i=0; i<scrollviewArr.count; i++)
            {
                NSData *data=[[scrollviewArr objectAtIndex:i] objectForKey:@"imagedata"];
                UIImage *image=[UIImage imageWithData:data];
                UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(i*screenWidth, 0, screenWidth, screenHeight/4)];
                [button setImage:image forState:UIControlStateNormal];
                button.tag=i+1;
                [button addTarget:self action:@selector(scrollviewTap:) forControlEvents:UIControlEventTouchUpInside];
                
                [scrollView addSubview:button];
            }
            
            [self.tableView reloadInputViews];
            [self.view addSubview:pageController];
            currentScrollviewpage=0;
            
            [timer invalidate];
            timer=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
            [timer fire];
            refreshTime++;
            if (refreshTime==8)
            {
                [self.tableView.header endRefreshing];
                refreshTime=0;
            }
        });
        [queue inDatabase:^(FMDatabase *database) {
            [database executeUpdate:@"delete from homepagescrollview"];
            for (NSDictionary *dic in scrollviewArr)
            {
                [database executeUpdate:@"insert into homepagescrollview (desc,logourl,targeturl,imagedata) values (?,?,?,?)",[dic objectForKey:@"Desc"],[dic objectForKey:@"LogoUrl"],[dic objectForKey:@"TargetUrl"],[dic objectForKey:@"imagedata"]];
            }
        }];
    }];
    [task resume];
}

#pragma mark - 从本地数据库获取主页头滚动视图数据
-(void)getScrollviewdatafromsql
{
    FMResultSet *result=[db executeQuery:@"select * from homepagescrollview"];
    
    while ([result next])
    {
        NSString *desc=[result stringForColumn:@"desc"];
        NSString *logourl=[result stringForColumn:@"logourl"];
        NSString *targeturl=[result stringForColumn:@"targeturl"];
        NSData *data=[result dataForColumn:@"imagedata"];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        [dic setObject:desc forKey:@"desc"];
        [dic setObject:logourl forKey:@"logourl"];
        [dic setObject:targeturl forKey:@"targeturl"];
        [dic setObject:data forKey:@"imagedata"];
        [scrollviewArr addObject:dic];
    }
    for (int i=0; i<3; i++)
    {
        NSData *data=[[scrollviewArr objectAtIndex:i] objectForKey:@"imagedata"];
        UIImage *image=[UIImage imageWithData:data];
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(i*screenWidth, 0, screenWidth, screenHeight/4)];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(scrollviewTap:) forControlEvents:UIControlEventTouchUpInside];
        button.tag=i+1;
        [scrollView addSubview:button];
    }
    [self.view addSubview:pageController];
    [self.tableView reloadInputViews];
    currentScrollviewpage=0;
    
    [timer invalidate];
    timer=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
    [timer fire];
}
#pragma mark - 从服务器获得SECTION标题
-(void)getSectiondatafromnetWithPage:(NSString *)page
{
    
    NSString *urlPath=@"http://applebbx.sj.91.com/api/?cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&act=1&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&spid=2&osv=9.1&dm=iPhone7,1&sv=3.1.3&nt=10&mt=1&pid=2";
    NSURL *url=[NSURL URLWithString:urlPath];
    NSURLSessionConfiguration *config=[NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data==nil)
        {
            return;
        }
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray *arr=[dic objectForKey:@"Result"];
        NSDictionary *dic1=[arr objectAtIndex:0];
        [sectionArr removeAllObjects];
        sectionArr=[dic1 objectForKey:@"parts"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            refreshTime++;
            if (refreshTime==8)
            {
                [self.tableView.header endRefreshing];
                refreshTime=0;
            }
        });
        [queue inDatabase:^(FMDatabase *database) {
            
            [database executeUpdate:@"delete from homepagesection where page=?",page];
            for (int i=0; i<sectionArr.count; i++)
            {
                [database executeUpdate:@"insert into homepagesection (name,act,page) values (?,?,?)",[[sectionArr objectAtIndex:i] objectForKey:@"name"],[[sectionArr objectAtIndex:i] objectForKey:@"act"],page];
            }
        }];
        
        
    }];
    [task resume];
}
#pragma mark - 从本地数据库获得SECTION标题
-(void)getSectiondatafromsqlWithPage:(NSString *)page
{
    FMResultSet *result=[db executeQuery:@"select * from homepagesection where page=?",page];
    while ([result next])
    {
        NSMutableDictionary *dicmodel=[[NSMutableDictionary alloc]init];
        for (int i=0; i<[result columnCount]; i++)
        {
            [dicmodel setObject:[result stringForColumnIndex:i] forKey:[result columnNameForIndex:i]];
        }
        [sectionArr addObject:dicmodel];
    }
    [self.tableView reloadData];
}
#pragma mark - 从服务器获得指定页面上的指定SECTION上的推荐APP的数据
-(void)getAppdatafromnetWithUrlPath:(NSString *)urlpath andWithAppArr:(NSMutableArray *)apparr andWithPage:(NSString *)page andWithSection:(NSString *)section
{
    NSURL *url=[NSURL URLWithString:urlpath];
    NSURLSessionConfiguration *config=[NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data==nil)
        {
            return;
        }
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *dic1=[dic objectForKey:@"Result"];
        NSArray *arr=[dic1 objectForKey:@"items"];
        NSMutableArray *dataarr=[[NSMutableArray alloc]init];
        for (int i=0; i<arr.count; i++)
        {
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            dic=[NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:i]];
            NSString *size;
            if ([[dic objectForKey:@"size"] longLongValue]>1024*1024*1024)
            {
                size=[NSString stringWithFormat:@"%.2fGB",[[dic objectForKey:@"size"] longLongValue]/1024/1024/1024.0];
            }
            else
            {
                size=[NSString stringWithFormat:@"%.2fMB",[[dic objectForKey:@"size"] longLongValue]/1024/1024.0];
            }
            NSURL *url=[NSURL URLWithString:[dic objectForKey:@"icon"]];
            NSData *data=[NSData dataWithContentsOfURL:url];
            
            if (data==nil)
            {
                NSString *path=[[NSBundle mainBundle] pathForResource:@"pic_fresh_s@2x.png" ofType:nil];
                data=[NSData dataWithContentsOfFile:path];
                [dic setObject:data forKey:@"imagedata"];
            }
            else
            {
                [dic setObject:data forKey:@"imagedata"];
            }
            App *app=[[App alloc]init];
            [app setValuesForKeysWithDictionary:dic];
            app.size=size;
            app.imagedata=[dic objectForKey:@"imagedata"];
            [dataarr addObject:app];
        }
        [apparr removeAllObjects];
        [apparr addObjectsFromArray:dataarr];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([section isEqualToString:@"0"] && [page isEqualToString:@"1"])
            {
                [self createSectiononeCellScrollView];
            }
            else if ([section isEqualToString:@"2"] && [page isEqualToString:@"1"])
            {
                [self createSectionthreeCellScrollView];
            }
            NSIndexSet *index=[NSIndexSet indexSetWithIndex:section.intValue];
            [self.tableView reloadSections:index withRowAnimation:NO];
            refreshTime++;
            if (refreshTime==8)
            {
                [self.tableView.header endRefreshing];
                refreshTime=0;
            }
        });
        [queue inDatabase:^(FMDatabase *database) {
            [database executeUpdate:@"delete from apps where page=? and section=?",page,section];
            for (int i=0; i<apparr.count; i++)
            {
                App *app=[apparr objectAtIndex:i];
                [database executeUpdate:@"insert into apps (page,section,appType,author,cateName,detailUrl,downAct,downTimes,icon,name,originalPrice,price,resId,size,star,state,summary,imageData) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",page,section,app.appType,app.author,app.cateName,app.detailUrl,app.downAct,app.downTimes,app.icon,app.name,app.originalPrice,app.price,app.resId,app.size,app.star,app.state,app.summary,app.imagedata];
            }
        }];
    }];
    [task resume];
}
#pragma mark - 从本地数据库获得指定页面上的指定SECTION上的推荐APP的数据
-(void)getAppdatafromsqlWithAppArr:(NSMutableArray *)apparr andWithPage:(NSString *)page andWithSection:(NSString *)section
{
    FMResultSet *result=[db executeQuery:@"select * from apps where page=? and section=?",page,section];
    NSMutableArray *dataarr=[[NSMutableArray alloc]init];
    while ([result next])
    {
        NSMutableDictionary *dicmodel=[[NSMutableDictionary alloc]init];
        for (int i=0; i<[result columnCount]; i++)
        {
            if ([[result columnNameForIndex:i] isEqualToString:@"imagedata"])
            {
                [dicmodel setObject:[result dataForColumnIndex:i] forKey:@"imagedata"];//[result columnNameForIndex:i]
            }
            else
            {
                [dicmodel setObject:[result stringForColumnIndex:i] forKey:[result columnNameForIndex:i]];
            }
        }
        App *app=[[App alloc]init];
        [app setValuesForKeysWithDictionary:dicmodel];
        [dataarr addObject:app];
    }
    [apparr addObjectsFromArray:dataarr];
    if ([section isEqualToString:@"0"] && [page isEqualToString:@"1"])
    {
        [self createSectiononeCellScrollView];
    }
    else if ([section isEqualToString:@"2"] && [page isEqualToString:@"1"])
    {
        [self createSectionthreeCellScrollView];
    }
    NSIndexSet *index=[NSIndexSet indexSetWithIndex:section.intValue];
    [self.tableView reloadSections:index withRowAnimation:NO];
}
#pragma mark - 从网络获取第四个SECTION的数据
-(void)getAppspecialfromnet
{
    
    NSString *urlPath=@"http://applebbx.sj.91.com/soft/phone/tag.aspx?cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&act=212&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&spid=2&osv=9.1&dm=iPhone7,1&sv=3.1.3&nt=10&mt=1&pid=2";
    NSURL *url=[NSURL URLWithString:urlPath];
    NSURLSessionConfiguration *config=[NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data==nil)
        {
            return;
        }
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray *arr=[dic objectForKey:@"Result"];
        
        [sectionfourArr removeAllObjects];
        
        for (int i=0; i<arr.count; i++)
        {
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            dic=[NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:i]];
            NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic objectForKey:@"icon"]]];
            if (data==nil)
            {
                NSString *path=[[NSBundle mainBundle] pathForResource:@"pic_fresh_s@2x.png" ofType:nil];
                data=[NSData dataWithContentsOfFile:path];
                [dic setObject:data forKey:@"imagedata"];
            }
            else
            {
                [dic setObject:data forKey:@"imagedata"];
            }
            
            [sectionfourArr addObject:dic];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createSectionfourCellView];
            NSIndexSet *index=[NSIndexSet indexSetWithIndex:3];
            [self.tableView reloadSections:index withRowAnimation:NO];
            refreshTime++;
            if (refreshTime==8)
            {
                [self.tableView.header endRefreshing];
                refreshTime=0;
            }
        });
        [queue inDatabase:^(FMDatabase *database) {
            [database executeUpdate:@"delete from homepageappspecial"];
            for (NSDictionary *dic in sectionfourArr )
            {
                [database executeUpdate:@"insert into homepageappspecial (name,icon,url,imagedata) values (?,?,?,?)",[dic objectForKey:@"name"],[dic objectForKey:@"icon"],[dic objectForKey:@"url"],[dic objectForKey:@"imagedata"]];
            }
            
        }];
    }];
    [task resume];
}
#pragma mark - 从本地获取第四个SECTION的数据
-(void)getAppspecialfromsql
{
    FMResultSet *result=[db executeQuery:@"select * from homepageappspecial"];
    while ([result next])
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        [dic setObject:[result stringForColumn:@"name"] forKey:@"name"];
        [dic setObject:[result stringForColumn:@"icon"] forKey:@"icon"];
        [dic setObject:[result stringForColumn:@"url"] forKey:@"url"];
        [dic setObject:[result dataForColumn:@"imagedata"] forKey:@"imagedata"];
        [sectionfourArr addObject:dic];
    }
    [self createSectionfourCellView];
    NSIndexSet *index=[NSIndexSet indexSetWithIndex:3];
    [self.tableView reloadSections:index withRowAnimation:NO];
}
#pragma mark - ----------------------------------------------------------
#pragma mark - -----------------创建CELL视图----------------------------

#pragma mark - 创建第一个SECTION里的滚动视图
-(void)createSectiononeCellScrollView
{
    sectiononecellScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 10, screenWidth, 57+14)];
    sectiononecellScrollView.backgroundColor=[UIColor whiteColor];
    sectiononecellScrollView.showsHorizontalScrollIndicator=NO;
    sectiononecellScrollView.showsVerticalScrollIndicator=NO;
    sectiononecellScrollView.contentSize=CGSizeMake(sectiononeArr.count*(57+10+10), 0);
    for (int i=0; i<sectiononeArr.count; i++)
    {
        App *app=[sectiononeArr objectAtIndex:i];
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(i*(57+10+10), 0, 57+10+10, 57+10)];
        
        button.backgroundColor=[UIColor whiteColor];
        button.tag=i+1;
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 60, 57, 10)];
        label.text=app.name;
        label.backgroundColor=[UIColor whiteColor];
        label.font=[UIFont systemFontOfSize:13];
        [button addSubview:label];
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 57, 57)];
        
        imageView.backgroundColor=[UIColor whiteColor];
        [imageView setImage:[UIImage imageWithData:app.imagedata]];
        [imageView setBackgroundColor:[UIColor whiteColor]];
        imageView.layer.masksToBounds=YES;
        imageView.layer.cornerRadius=10;
        [button addSubview:imageView];
        
        button.tag=i+1;
        [button addTarget:self action:@selector(sectionOnetap:) forControlEvents:UIControlEventTouchUpInside];
        
        [sectiononecellScrollView addSubview:button];
        
    }
}
#pragma mark - 第一个SECTION中的点击事件
-(void)sectionOnetap:(UIButton *)sender
{
    AppDetailViewController *appdetail=[[AppDetailViewController alloc]init];
    appdetail.navigationItem.hidesBackButton=YES;
    appdetail.hidesBottomBarWhenPushed=YES;
    App *app=[sectiononeArr objectAtIndex:sender.tag-1];
    appdetail.detailUrlpath=app.detailUrl;
    
    [self.navigationController pushViewController:appdetail animated:YES];
    
}
#pragma mark - 创建第三个SECTION里的滚动视图
-(void)createSectionthreeCellScrollView
{
    sectionthreecellScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 57+20+10)];
    sectionthreecellScrollView.backgroundColor=[UIColor whiteColor];
    sectionthreecellScrollView.showsHorizontalScrollIndicator=NO;
    sectionthreecellScrollView.showsVerticalScrollIndicator=NO;
    sectionthreecellScrollView.contentSize=CGSizeMake(sectionthreeArr.count*(57+10+10), 57+20+10);
    for (int i=0; i<sectionthreeArr.count; i++)
    {
        App *app=[sectionthreeArr objectAtIndex:i];
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(i*(57+10+10), 0, 57+10+10, 57+20+10)];
        
        button.backgroundColor=[UIColor whiteColor];
        button.tag=i+1;
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 62, 57, 10)];
        label.text=app.name;
        label.backgroundColor=[UIColor whiteColor];
        label.font=[UIFont systemFontOfSize:13];
        [button addSubview:label];
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 57, 57)];
        
        imageView.backgroundColor=[UIColor whiteColor];
        [imageView setImage:[UIImage imageWithData:app.imagedata]];
        [imageView setBackgroundColor:[UIColor whiteColor]];
        imageView.layer.masksToBounds=YES;
        imageView.layer.cornerRadius=10;
        [button addSubview:imageView];
        button.tag=i+1;
        [button addTarget:self action:@selector(sectionThreetap:) forControlEvents:UIControlEventTouchUpInside];
        [sectionthreecellScrollView addSubview:button];
    }
}
-(void)sectionThreetap:(UIButton *)sender
{
    AppDetailViewController *appdetail=[[AppDetailViewController alloc]init];
    appdetail.navigationItem.hidesBackButton=YES;
    appdetail.hidesBottomBarWhenPushed=YES;
    App *app=[sectionthreeArr objectAtIndex:sender.tag-1];
    appdetail.detailUrlpath=app.detailUrl;
    
    [self.navigationController pushViewController:appdetail animated:YES];
}
#pragma mark - 创建第四个SECTION里的多图片视图
-(void)createSectionfourCellView
{
    sectionfourView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight/3)];
    sectionfourView.backgroundColor=[UIColor whiteColor];
    CGFloat buttonWeight=screenWidth/2;
    CGFloat buttonHeight=screenHeight/6;
    int imagecount;
    if (sectionfourArr.count>4)
    {
        imagecount=4;
    }
    else
    {
        imagecount=(int)sectionfourArr.count;
    }
    for (int i=0; i<imagecount; i++)
    {
        UIButton *button=[[UIButton alloc]init];
        if (i>1)
        {
            button.frame=CGRectMake((i-2)*buttonWeight,buttonHeight, buttonWeight, buttonHeight);
        }
        else
        {
            button.frame=CGRectMake(i*buttonWeight, 0, buttonWeight, buttonHeight);
        }
        NSData *data=[[sectionfourArr objectAtIndex:i] objectForKey:@"imagedata"];
        UIImage *image=[UIImage imageWithData:data];
        [button setImage:image forState:UIControlStateNormal];
        button.tag=i+1;
        [button addTarget:self action:@selector(sectionfourTap:) forControlEvents:UIControlEventTouchUpInside];
        [sectionfourView addSubview:button];
    }
}
-(void)sectionfourTap:(UIButton *)sender
{
    NSString *urlPath=[[sectionfourArr objectAtIndex:sender.tag-1] objectForKey:@"url"];
    AppListTableViewController *applist=[[AppListTableViewController alloc]initWithStyle:UITableViewStylePlain];
    applist.targeturl=urlPath;
    applist.navigationtitle=[[sectionfourArr objectAtIndex:sender.tag-1] objectForKey:@"name"];
    UIBarButtonItem *backBarbutton=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backBarbutton;
    [self.navigationController pushViewController:applist animated:YES];
}
#pragma mark - ----------------------------------------------------------
#pragma mark - -----------------TABLEVIEW相关设置---------------------

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 28)];
    view.backgroundColor=[UIColor whiteColor];
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 57+10, 28)];
    label.textColor=[UIColor blackColor];
    label.font=[UIFont boldSystemFontOfSize:15];
    label.textAlignment=NSTextAlignmentLeft;
    
    [view addSubview:label];
    
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(view.frame.size.width-40-10, 0, 40, 28)];
    [button setTitle:@"更多" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.backgroundColor=[UIColor whiteColor];
    button.titleLabel.font=[UIFont systemFontOfSize:13];
    button.tag=section+1;
    [button addTarget:self action:@selector(sectionMoretap:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    if (sectionArr.count==6)
    {
        label.text=[[sectionArr objectAtIndex:section] objectForKey:@"name"];
    }
    return view;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rowNumber=0;
    if (section==0)
    {
        rowNumber=1;
    }
    else if (section==1)
    {
        rowNumber=10;
    }
    else if (section==2)
    {
        rowNumber=1;
    }
    else if (section==3)
    {
        rowNumber=1;
    }
    else if (section==4)
    {
        rowNumber=10;
    }
    else if (section==5)
    {
        rowNumber=10;
    }
    return rowNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.backgroundColor=[UIColor whiteColor];
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 57, 57)];
    imageView.backgroundColor=[UIColor whiteColor];
    imageView.layer.masksToBounds=YES;
    imageView.layer.cornerRadius=10;
    [cell addSubview:imageView];
    UILabel *nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(57+10+10, 10, screenWidth/2, 20)];
    nameLabel.backgroundColor=[UIColor whiteColor];
    [cell addSubview:nameLabel];
    UILabel *downLabel=[[UILabel alloc]initWithFrame:CGRectMake(57+10+10, 50, screenWidth/4, 15)];
    downLabel.backgroundColor=[UIColor whiteColor];
    downLabel.textColor=[UIColor grayColor];
    downLabel.font=[UIFont systemFontOfSize:13];
    [cell addSubview:downLabel];
    UILabel *sizeLabel=[[UILabel alloc]initWithFrame:CGRectMake(57+10+10+screenWidth/4+5, 50, screenWidth/5, 15)];
    sizeLabel.backgroundColor=[UIColor whiteColor];
    sizeLabel.font=[UIFont systemFontOfSize:13];
    [cell addSubview:sizeLabel];
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(57+10+10+screenWidth/4+5+screenWidth/6+((screenWidth-(57+10+10+screenWidth/4+5+screenWidth/6))/2-screenWidth/16), (57+20+10)/2-15, screenWidth/7, 30)];
    button.backgroundColor=[UIColor whiteColor];
    button.titleLabel.font=[UIFont systemFontOfSize:11];
    button.layer.cornerRadius=3;
    
    
    [cell addSubview:button];
    
    if (indexPath.section==0)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"scroll"];
        cell.backgroundColor=[UIColor whiteColor];
        [cell addSubview:sectiononecellScrollView];
        UIView *underView=[[UIView alloc]initWithFrame:CGRectMake(0, 57+20+10-1, screenWidth, 1)];
        underView.backgroundColor=[UIColor lightGrayColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.selected=NO;
        [cell addSubview:underView];
        
        return cell;
    }
    else if (indexPath.section==1)
    {
        if (sectiontwoArr.count>=10)
        {
            App *app=[sectiontwoArr objectAtIndex:indexPath.row];
            UIImage *image=[UIImage imageWithData:app.imagedata];
            imageView.image=image;
            nameLabel.text=app.name;
            int starNumber=[app.star intValue];
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
            downLabel.text=[NSString stringWithFormat:@"%@次下载",app.downTimes];
            if ([app.price isEqualToString:@"0.00"])
            {
                [button setTitle:@"免费" forState:UIControlStateNormal];
            }
            else
            {
                [button setTitle:[NSString stringWithFormat:@"%@",app.price] forState:UIControlStateNormal];
            }
            button.tag=indexPath.row+1;
            [button addTarget:self action:@selector(appstoreButtonS2:) forControlEvents:UIControlEventTouchUpInside];
            
            button.backgroundColor=[UIColor orangeColor];
            sizeLabel.text=app.size;
        }
        
        UIView *underView=[[UIView alloc]initWithFrame:CGRectMake(0, 57+20+10-1, screenWidth, 1)];
        underView.backgroundColor=[UIColor lightGrayColor];
        [cell addSubview:underView];
        return cell;
    }
    else if (indexPath.section==2)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"scroll"];
        cell.backgroundColor=[UIColor whiteColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.selected=NO;
        [cell addSubview:sectionthreecellScrollView];
        UIView *underView=[[UIView alloc]initWithFrame:CGRectMake(0, 57+20+10-1, screenWidth, 1)];
        underView.backgroundColor=[UIColor lightGrayColor];
        [cell addSubview:underView];
        return cell;
    }
    else if (indexPath.section==3)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image"];
        cell.backgroundColor=[UIColor whiteColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.selected=NO;
        [cell addSubview:sectionfourView];
        UIView *underView=[[UIView alloc]initWithFrame:CGRectMake(0, screenHeight/3+10, screenWidth, 1)];
        underView.backgroundColor=[UIColor lightGrayColor];
        [cell addSubview:underView];
        return cell;
    }
    else if (indexPath.section==4)
    {
        
        if (sectionfiveArr.count>=10)
        {
            App *app=[sectionfiveArr objectAtIndex:indexPath.row];
            UIImage *image=[UIImage imageWithData:app.imagedata];
            imageView.image=image;
            nameLabel.text=app.name;
            int starNumber=[app.star intValue];
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
                    UIImageView *startImageView=[[UIImageView alloc]initWithFrame:CGRectMake((57+10+10)+(starNumber+k)*((screenWidth/2)/9), 30, (screenWidth/2)/9, ((screenWidth/2)/9))];
                    [startImageView setImage:[UIImage imageNamed:@"detail_unstar@2x.png"]];
                    [cell addSubview:startImageView];
                }
            }
            downLabel.text=[NSString stringWithFormat:@"%@次下载",app.downTimes];
            if ([app.price isEqualToString:@"0.00"])
            {
                [button setTitle:@"免费" forState:UIControlStateNormal];
            }
            else
            {
                [button setTitle:[NSString stringWithFormat:@"%@",app.price] forState:UIControlStateNormal];
            }
            button.tag=indexPath.row+1;
            [button addTarget:self action:@selector(appstoreButtonS5:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor=[UIColor orangeColor];
            sizeLabel.text=app.size;
        }
        UIView *underView=[[UIView alloc]initWithFrame:CGRectMake(0, 57+20+10-1, screenWidth, 1)];
        underView.backgroundColor=[UIColor lightGrayColor];
        [cell addSubview:underView];
        return cell;
    }
    else if (indexPath.section==5)
    {
        if (sectionsixArr.count>=10)
        {
            App *app=[sectionsixArr objectAtIndex:indexPath.row];
            UIImage *image=[UIImage imageWithData:app.imagedata];
            imageView.image=image;
            nameLabel.text=app.name;
            int starNumber=[app.star intValue];
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
            downLabel.text=[NSString stringWithFormat:@"%@次下载",app.downTimes];
            if ([app.price isEqualToString:@"0.00"])
            {
                [button setTitle:@"免费" forState:UIControlStateNormal];
            }
            else
            {
                [button setTitle:[NSString stringWithFormat:@"%@",app.price] forState:UIControlStateNormal];
            }
            button.tag=indexPath.row+1;
            [button addTarget:self action:@selector(appstoreButtonS6:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor=[UIColor orangeColor];
            sizeLabel.text=app.size;
        }
        
        UIView *underView=[[UIView alloc]initWithFrame:CGRectMake(0, 57+20+10-1, screenWidth, 1)];
        underView.backgroundColor=[UIColor lightGrayColor];
        [cell addSubview:underView];
        return cell;
        
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==3)
    {
        return screenHeight/3+10;
    }
    else
    {
        return 57+20+10;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1)
    {
        AppDetailViewController *appdetail=[[AppDetailViewController alloc]init];
        appdetail.navigationItem.hidesBackButton=YES;
        appdetail.hidesBottomBarWhenPushed=YES;
        App *app=[sectiontwoArr objectAtIndex:indexPath.row];
        appdetail.detailUrlpath=app.detailUrl;
        
        [self.navigationController pushViewController:appdetail animated:YES];
    }
    else if (indexPath.section==4)
    {
        AppDetailViewController *appdetail=[[AppDetailViewController alloc]init];
        appdetail.navigationItem.hidesBackButton=YES;
        appdetail.hidesBottomBarWhenPushed=YES;
        App *app=[sectionfiveArr objectAtIndex:indexPath.row];
        appdetail.detailUrlpath=app.detailUrl;
        
        [self.navigationController pushViewController:appdetail animated:YES];
    }
    else if (indexPath.section==5)
    {
        AppDetailViewController *appdetail=[[AppDetailViewController alloc]init];
        appdetail.navigationItem.hidesBackButton=YES;
        appdetail.hidesBottomBarWhenPushed=YES;
        App *app=[sectionsixArr objectAtIndex:indexPath.row];
        appdetail.detailUrlpath=app.detailUrl;
        
        [self.navigationController pushViewController:appdetail animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - 跳转到APPSTORE
-(void)appstoreButtonS2:(UIButton *)sender
{
    
    App *app=[sectiontwoArr objectAtIndex:sender.tag-1];
    [self openAppWithResId:app.resId andWithViewController:self];
    
}
-(void)appstoreButtonS5:(UIButton *)sender
{
    App *app=[sectionfiveArr objectAtIndex:sender.tag-1];
    [self openAppWithResId:app.resId andWithViewController:self];
    
}
-(void)appstoreButtonS6:(UIButton *)sender
{
    App *app=[sectionsixArr objectAtIndex:sender.tag-1];
    
    [self openAppWithResId:app.resId andWithViewController:self];
    
}
-(void)openAppWithResId:(NSString *)resid andWithViewController:(UIViewController *)view
{
    //SKStoreProductViewController *storeProductVC;
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showWithStatus:@"正在载入.."];
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:resid forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error)
     {
         if (result)
         {
             [view presentViewController:storeProductVC animated:YES completion:nil];
             [SVProgressHUD dismiss];
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
#pragma mark - SECTION上更多按钮点击事件
-(void)sectionMoretap:(UIButton *)sender
{
    NSString *urlPath=[[sectionArr objectAtIndex:sender.tag-1] objectForKey:@"act"];
    NSLog(@"%@",urlPath);
    AppListTableViewController *applist=[[AppListTableViewController alloc]initWithStyle:UITableViewStylePlain];
    applist.targeturl=urlPath;
    applist.navigationtitle=[[sectionArr objectAtIndex:sender.tag-1] objectForKey:@"name"];
    UIBarButtonItem *backBarbutton=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backBarbutton;
    [self.navigationController pushViewController:applist animated:YES];
}
@end
