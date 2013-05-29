//
//  ImageDownloader.m
//  SampleAdvThreads
//
//  Created by JungHoyon on 13. 5. 27..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()
@property (nonatomic, readwrite, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, retain) PhotoRecord *photoRecord;
@end

@implementation ImageDownloader
@synthesize delegate = _delegate;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize photoRecord = _photoRecord;

- (void)dealloc
{
    [_indexPathInTableView release];
    [_photoRecord release];
    
    _photoRecord = nil;
    _indexPathInTableView = nil;
    
    _delegate = nil;
    
    [super dealloc];
}
- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate {
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    return self;
}
- (id)initWithPhotoRecord:(PhotoRecord *)record delegate:(id<ImageDownloaderDelegate>) theDelegate{
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.indexPathInTableView = nil;
        self.photoRecord = record;
    }
    return self;
}

- (void)dispatchData{
    NSLog(@"Dispatch Result data...");
    //[(NSObject *)self.delegate performSelector:@selector(imageDownloaderDidFinish:) withObject:self ];
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
    
}
@end
