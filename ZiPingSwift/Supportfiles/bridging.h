//
//  bridging.h
//  SwiftDemo
//
//  Created by 杨凯 on 2017/4/12.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

#ifndef bridging_h
#define bridging_h

//空数据显示
#import <DZNEmptyDataSet/DZNEmptyDataSet-umbrella.h>

//腾讯
#import "VideoRecordViewController.h"
#import "VideoEditViewController.h"

#import "PlayViewController.h"
#import <TXLiteAVSDK_UGC/TXUGCPublishListener.h>
#import <TXLiteAVSDK_UGC/TXUGCPublish.h>
//#import <TXLiteAVSDK_UGC/TXUGCPublishTypeDef.h>
//讯飞
#import "iflyMSC/IFlyMSC.h"

//极光
#import "JPUSHService.h"

//腾讯云存储
#import "COSClient.h"



    // iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#endif /* bridging_h */
