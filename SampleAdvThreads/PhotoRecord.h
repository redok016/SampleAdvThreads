//
//  PhotoRecord.h
//  SampleAdvThreads
//
//  Created by JungHoyon on 13. 5. 27..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoRecord : NSObject
{
    NSString* _name;
    UIImage* _image;
    NSString* _url;
    BOOL _hasImage;
    BOOL _filtered;
    BOOL _failed;
}

@property (nonatomic, retain)NSString* name;
@property (nonatomic, retain)UIImage* image;
@property (nonatomic, retain)NSString* url;
@property (nonatomic, readonly)BOOL hasImage;
@property (nonatomic, getter = isFiltered)BOOL filtered;
@property (nonatomic, getter = isFailed)BOOL failed;

@end
