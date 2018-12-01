//
//  HBUtil.h
//  聊天室
//
//  Created by Raizo on 15/10/25.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HBUtil : NSObject
+(NSString *)domain;
+(NSString *)trimming:(NSString *)str;
+(void)alertWithTittle:(NSString *)tittle andWithMessage:(NSString *)message andWithViewController:(id)viewcontroller;
@end
