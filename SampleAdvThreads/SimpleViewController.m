//
//  SimpleViewController.m
//  SampleAdvThreads
//
//  Created by JungHoyon on 13. 5. 27..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//

#include "request_queue.h"
#include "curl/curl.h"

#import "SimpleViewController.h"
#import "ImageDownloader.h"

static queue_t global_queue;
id refthis;

struct data_t {
    char *bytes;
    size_t size;
};

// handle on load function
static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    struct data_t* data = (struct data_t* )userp;
    data->bytes = (char*)realloc( data->bytes, data->size + realsize + 1);
    if (data->bytes == NULL) {
        printf("realloc fails!");
        exit(EXIT_FAILURE);
    }
    memcpy(&(data->bytes[data->size]), contents, realsize);
    data->size += realsize;
    data->bytes[data->size] = 0;
    return realsize;
}

static void* worker( void* param ){
    
    ImageDownloader* _downloader = (ImageDownloader*)param;
    
    CURL* curl;
    CURLcode result;
    
    curl = curl_easy_init();
    if(curl){
        struct data_t chunk;
        chunk.bytes = (char*)malloc(1);
        chunk.size = 0;
        
        //>> area of obj-c
        PhotoRecord* photoItem = [_downloader photoRecord];
        //<< area of obj-c
        const char* url = [[photoItem url] UTF8String];
        printf("URL => %s", url);
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void*)&chunk);
        
        result = curl_easy_perform(curl);
        //>> get result Image
        NSData* image = [[NSData alloc]initWithBytes:chunk.bytes length:chunk.size];
        UIImage* realImage = [UIImage imageWithData:image];
        if (realImage) {
            photoItem.image = realImage;
            [_downloader dispatchData];
			[image release];
        }
        //<< get result Image.
        
        curl_easy_cleanup(curl);
    }

    return NULL;
}

@interface SimpleViewController ()

@end

@implementation SimpleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // create photo item.
    NSLog(@"init!");
    initialize_queue(&global_queue, 8);

    NSLog(@">>>> init queue");
    
    PhotoRecord* _photoItem = [[PhotoRecord alloc]init];
    _photoItem.name = @"id1";
    _photoItem.url = @"http://www.tvian.com/TVianUpload/TVian//image/2010/06/07/H4tzncPHRwpG634115040140022147.jpg";
    
    ImageDownloader* _imageDownload = [[ImageDownloader alloc]initWithPhotoRecord:_photoItem delegate:self];
    
    
    PhotoRecord* _photoItem2 = [[PhotoRecord alloc]init];
    _photoItem2.name = @"id2";
    _photoItem2.url = @"http://www.tvian.com/TVianUpload/TVian//image/2010/06/07/H4tzncPHRwpG634115040140022147.jpg";
    
    ImageDownloader* _imageDownload2 = [[ImageDownloader alloc]initWithPhotoRecord:_photoItem2 delegate:self];

    NSLog(@">>>> add queue");
    add_queue(&global_queue, worker, (void*)_imageDownload);
    add_queue(&global_queue, worker, (void*)_imageDownload2);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    NSLog(@">>> Get Data!");
    
    UIImageView* imageView = [[[UIImageView alloc]initWithImage:downloader.photoRecord.image]autorelease];
    [self.view addSubview:imageView];
}

@end
