//
//  MusicLoader.m
//  02
//
//  Created by admin on 17/4/19.
//  Copyright © 2017年 北京奥泰瑞格科技有限公司. All rights reserved.
//

#import "MusicLoader.h"

@interface MusicLoader()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@property (copy,nonatomic)NSString *localfileName;
@property (copy,nonatomic)NSString *URLFileName;

@end

@implementation MusicLoader

#pragma mark - 实例化
+ (instancetype)shareToolLoader{
    return [[self alloc] init];
}

#pragma mark - 获取沙盒目录
- (NSArray<NSString*> *)documentsPath{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}


#pragma mark - 返回缓存路径
- (NSString *)URLFileNameIsExsitesInLocalDocument:(NSString *)URLFileName{
    
    //这个可以查找Documents路径下的所有文件
    self.URLFileName = [URLFileName copy];
    NSArray<NSString*> *documents = [self documentsPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray * tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:[documents lastObject] error:nil]];
    
    //下载,并缓存到本地
    if (tempFileList.count==0) {
        [self excuteLoadMusic:URLFileName];
        return self.localfileName;
    }
    
    NSString *URLFileNameLast = [URLFileName componentsSeparatedByString:@"/"].lastObject;
    [tempFileList enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        //判断音乐是否在本地
        if (![URLFileNameLast isEqualToString:fileName] && idx==tempFileList.count-1) {
            //下载,并缓存到本地
            [self excuteLoadMusic:URLFileName];
        }else{
            self.localfileName = [[documents lastObject] stringByAppendingPathComponent:URLFileNameLast];
            *stop = YES;
        }
    }];
    
    return self.localfileName;
}


#pragma mark - 执行下载操作
- (void)excuteLoadMusic:(NSString *)URLFileName{
    
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    //创建URL
    NSURL *url = [NSURL URLWithString:URLFileName];
    
    //创建下载任务
    NSURLSessionDownloadTask *downTask = [session downloadTaskWithURL:url];
    
    //启动任务
    [downTask resume];
}


#pragma mark - 下载代理方法
//下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    self.progressRate = 1.0 * totalBytesWritten/totalBytesExpectedToWrite;
    
    NSLog(@"%f", self.progressRate);
    if ([self.delegate respondsToSelector:@selector(getCurProgress:)]) {
        [self.delegate getCurProgress:self.progressRate];
    }
}


//写入数据到本地
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
    NSArray<NSString*> *documents = [self documentsPath];
    self.localfileName = [[documents lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.localfileName] error:&error];
    if (error) {
        self.localfileName = nil;
    }else{
        //发送缓存路径通知
        if ([self.delegate respondsToSelector:@selector(endOfLoaderAction:)]) {
            [self.delegate endOfLoaderAction:self.localfileName];
        }
    }
}











@end
