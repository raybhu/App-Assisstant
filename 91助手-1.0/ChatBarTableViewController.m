//
//  ChatBarTableViewController.m
//  91助手-1.0
//
//  Created by Raizo on 15/10/29.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "ChatBarTableViewController.h"

@interface ChatBarTableViewController ()
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    AppDelegate *appdelegate;
    FMDatabase *db;
    FMDatabaseQueue *queue;
    
    NSMutableArray *cellArr;
}
@end

@implementation ChatBarTableViewController

#pragma mark - ----------------------------------------------------------
#pragma mark - ---------------------视图载入完成-------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    screenWidth=[UIScreen mainScreen].bounds.size.width;
    screenHeight=[UIScreen mainScreen].bounds.size.height;
    
    
    self.tabBarController.tabBar.tintColor=[UIColor orangeColor];
    self.navigationController.navigationBar.barTintColor=[UIColor blackColor];
    self.navigationItem.title=@"聊吧";
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.view.backgroundColor=[UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    appdelegate=[UIApplication sharedApplication].delegate;
    db=appdelegate.db;
    queue=[AppDelegate getSharedDatabaseQueue];
    
    cellArr=[[NSMutableArray alloc]init];
    
    
    
    //判断是否为第一次打开
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"two"]==nil)
    {
        if([appdelegate isHasNetwork]==NO)
        {
            return;
        }
        NSString *str=@"two";
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"two"];
        [self getCelldatafromnet];
    }
    else
    {
        [self getCelldatafromsql];
        if([appdelegate isHasNetwork]==NO)
        {
            return;
        }
        else
        {
            [self getCelldatafromnet];
        }
    }
}
#pragma mark - ----------------------------------------------------------
#pragma mark - 从服务器获取CELL数据
-(void)getCelldatafromnet
{
    
    NSString *urlPath=@"http://applebbx.sj.91.com/api/?act=702&cuid=d7d506c74f5aa85a0fd164b971787d84baf69df5&spid=2&imei=6B167AB2-5745-4479-B60A-EECA8E58EAF0&osv=9.1&dm=iPhone7,1&sv=3.1.3&nt=10&mt=1&pid=2";
    NSURL *url=[NSURL URLWithString:urlPath];
    NSURLSessionConfiguration *config=[NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *datadic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray *dataarr=[datadic objectForKey:@"Result"];
            NSMutableArray *modelArr=[[NSMutableArray alloc]init];
            for (int i=0; i<dataarr.count; i++)
            {
                NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
                dic=[NSMutableDictionary dictionaryWithDictionary:[dataarr objectAtIndex:i]];
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
                [modelArr addObject:dic];
            }
            [cellArr removeAllObjects];
            [cellArr addObjectsFromArray:modelArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [queue inDatabase:^(FMDatabase *database) {
            [database executeUpdate:@"delete from chatbarcell"];
        for(NSDictionary *dic in cellArr)
        {
            [database executeUpdate:@"insert into chatbarcell (name,act,icon,imagedata) values (?,?,?,?)",[dic objectForKey:@"name"],[dic objectForKey:@"act"],[dic objectForKey:@"icon"],[dic objectForKey:@"imagedata"]];
        }
        }];
    }];
    [task resume];
}
#pragma mark - 从本地数据库获取CELL数据
-(void)getCelldatafromsql
{
    FMResultSet *result=[db executeQuery:@"select * from chatbarcell"];
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
        [cellArr addObject:dic];
    }
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cellArr.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title=@"感兴趣的贴吧";
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];;
    cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
    imageview.backgroundColor=[UIColor whiteColor];
    NSData *data=[[cellArr objectAtIndex:indexPath.row] objectForKey:@"imagedata"];
    UIImage *image=[UIImage imageWithData:data];
    imageview.image=image;
    [cell addSubview:imageview];
    UILabel *namelabel=[[UILabel alloc]initWithFrame:CGRectMake(10+50+10, 70/2-15, 80, 30)];
    namelabel.backgroundColor=[UIColor whiteColor];
    namelabel.textAlignment=NSTextAlignmentLeft;
    namelabel.text=[[cellArr objectAtIndex:indexPath.row] objectForKey:@"name"];
    [cell addSubview:namelabel];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50+20;
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
