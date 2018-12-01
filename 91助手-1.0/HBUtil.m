//
//  HBUtil.m
//  聊天室
//
//  Created by Raizo on 15/10/25.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "HBUtil.h"
static NSString *domain=@"115.159.1.248";
@implementation HBUtil
+(NSString *)domain
{
    return domain;
}
+(NSString *)trimming:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
+(void)alertWithTittle:(NSString *)tittle andWithMessage:(NSString *)message andWithViewController:(id)viewcontroller
{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:tittle message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [viewcontroller presentViewController:alert animated:YES completion:nil];
}
@end
