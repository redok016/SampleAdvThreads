//
//  ListViewWithMultiCurlController.h
//  SampleAdvThreads
//
//  Created by JungHoyon on 13. 5. 30..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoRecord.h"
#import "ImageDownloader.h"

@interface ListViewWithMultiCurlController : UITableViewController
@property (nonatomic, retain) NSMutableArray* photos;
@property (nonatomic, assign) NSMutableDictionary* operationList;
@end
