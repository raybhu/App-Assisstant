//
//  App.m
//  91助手-1.0
//
//  Created by Raizo on 15/10/27.
//  Copyright © 2015年 Raizo. All rights reserved.
//

#import "App.h"

@implementation App
@synthesize page,section,appType,author,cateName,detailUrl,downAct,downTimes,icon,name,originalPrice,price,resId,size,star,state,summary,imagedata;
-(NSString *)description
{
   return [NSString stringWithFormat:@"page=%@,section=%@,appType=%@,author=%@,cateName=%@,detailUrl=%@,downAct=%@,downTimes=%@,icon=%@,name=%@,originalPrice=%@,price=%@,resId=%@,size=%@,star=%@,state=%@,summary=%@,imagedata=%@",page,section,appType,author,cateName,detailUrl,downAct,downTimes,icon,name,originalPrice,price,resId,size,star,state,summary,imagedata];
}
@end
