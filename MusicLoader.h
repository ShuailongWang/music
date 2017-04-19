//
//  MusicLoader.h
//  02
//
//  Created by admin on 17/4/19.
//  Copyright © 2017年 北京奥泰瑞格科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MusicLoaderDelegate <NSObject>

//下载进度
-(void)getCurProgress:(CGFloat)progress;

/**下载完成*/
-(void)endOfLoaderAction:(NSString*)localfileName;

@end

@interface MusicLoader : NSObject

/**
 进度率
 */
@property (assign,nonatomic) CGFloat progressRate;
@property (weak,nonatomic) id<MusicLoaderDelegate> delegate;

/**
 类方法创建实例
 */
+ (instancetype)shareToolLoader;

/**
 判断该网络文件是否在本地存在，如果存在直接返回本地文件，否则存到本地后再返回
 @return 返回本地文件路径
 */
- (NSString *)URLFileNameIsExsitesInLocalDocument:(NSString *)URLFileName;

/**
 执行下载任务
 @param URLFileName 文件URL
 */
- (void)excuteLoadMusic:(NSString *)URLFileName;

@end
