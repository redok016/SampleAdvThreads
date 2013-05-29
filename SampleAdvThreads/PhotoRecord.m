//
//  PhotoRecord.m
//  SampleAdvThreads
//
//  Created by JungHoyon on 13. 5. 27..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//

#import "PhotoRecord.h"

@implementation PhotoRecord
@synthesize name = _name;
@synthesize image = _image;
@synthesize url = _url;
@synthesize hasImage = _hasImage;
@synthesize filtered = _filtered;
@synthesize failed = _failed;

- (void)dealloc {
    
    [_name release];
    [_image release];
    [_url release];
    
    _name = nil;
    _image = nil;
    _url = nil;
    
    [super dealloc];
}

- (BOOL)hasImage {
    return _image != nil;
}


- (BOOL)isFailed {
    return _failed;
}


- (BOOL)isFiltered {
    return _filtered;
}

@end
