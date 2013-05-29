//
//  ListViewController.h
//  SampleAdvThreads
//
//  Created by artist on 13. 5. 27..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoRecord.h"
#import "ImageDownloader.h"

@interface ListViewController : UITableViewController
@property (nonatomic, retain) NSMutableArray* photos;
@property (nonatomic, assign) NSMutableDictionary* operationList;
@end
