//
//  ImageDownloader.h
//  SampleAdvThreads
//
//  Created by JungHoyon on 13. 5. 27..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoRecord.h"

#include <pthread.h>
#include "curl/curl.h"

@protocol ImageDownloaderDelegate;
@interface ImageDownloader : NSObject

@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;
@property (nonatomic, readonly, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, retain) PhotoRecord *photoRecord;

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>) theDelegate;
- (id)initWithPhotoRecord:(PhotoRecord *)record delegate:(id<ImageDownloaderDelegate>) theDelegate;

- (void)requestImage;
- (void)dispatchData;
@end

@protocol ImageDownloaderDelegate <NSObject>
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;
@end