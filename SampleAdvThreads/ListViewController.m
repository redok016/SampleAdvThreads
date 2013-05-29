//
//  ListViewController.m
//  SampleAdvThreads
//
//  Created by artist on 13. 5. 27..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//
#include "request_queue.h"
#include "curl/curl.h"

#import "ListViewController.h"


static queue_t global_queue;
id refthis;

struct MemoryStruct {
    char *memory;
    size_t size;
};

// handle on load function
static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    struct MemoryStruct* mem = (struct MemoryStruct* )userp;
    mem->memory = (char*)realloc( mem->memory, mem->size + realsize + 1);
    if (mem->memory == NULL) {
        /* out of memory! */
        printf("not enough memory (realloc returned NULL)");
        exit(EXIT_FAILURE);
    }
    memcpy(&(mem->memory[mem->size]), contents, realsize);
    mem->size += realsize;
    mem->memory[mem->size] = 0;
    return realsize;
}





static void* worker( void* param ){
    
    ImageDownloader* _downloader = (ImageDownloader*)param;
    
    CURL* curl;
    CURLcode result;
    
    curl = curl_easy_init();
    if(curl){
        struct MemoryStruct chunk;
        chunk.memory = (char*)malloc(1); /* will be grown as needed by the realloc above no data at this point */
        chunk.size = 0;
        
        //>> area of obj-c
        PhotoRecord* photoItem = [_downloader photoRecord];
        //<< area of obj-c
        const char* url = [[photoItem url] UTF8String];
        printf("URL => %s\n", url);
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void*)&chunk);
        
        result = curl_easy_perform(curl);
//        //>> get result Image
		if (result != CURLE_OK) {
			printf("Error!");
		}
        NSData* image = [[NSData alloc]initWithBytes:chunk.memory length:chunk.size];
        UIImage* realImage = [UIImage imageWithData:image];
        NSLog(@"result image: => %@ ", realImage);
        if (realImage) {
            photoItem.image = realImage;
            [_downloader dispatchData];
            printf("complete!\n");
        }
        //<< get result Image.
        
        curl_easy_cleanup(curl);
    }
	
    return NULL;
}

@interface ListViewController ()

@end

@implementation ListViewController

@synthesize photos = _photos;
@synthesize operationList = _operationList;

- (NSMutableArray*)photos{
	if (!_photos) {
		NSMutableDictionary* datasource_dictionary = [[NSMutableDictionary alloc]init];
        [datasource_dictionary setObject:@"http://www.tvian.com/TVianUpload/TVian//image/2010/06/07/H4tzncPHRwpG634115040140022147.jpg" forKey:@"id1"];
        [datasource_dictionary setObject:@"http://static.news.zum.com/images/20/2013/01/23/20130123_1358918451..jpg" forKey:@"id2"];
        [datasource_dictionary setObject:@"http://nimg.nate.com/orgImg/bn/2011/09/06/1570f40755fa1ad06bcc067c60842af6.jpg" forKey:@"id3"];
        [datasource_dictionary setObject:@"http://nimg.nate.com/orgImg/tv/2011/03/11/11_139041.jpg" forKey:@"id4"];
        [datasource_dictionary setObject:@"http://www.nemopan.com/files/attach/images/421/368/603/006/%ED%95%9C%EA%B0%80%EC%9D%B8.jpg" forKey:@"id5"];
        [datasource_dictionary setObject:@"http://pds.joinsmsn.com/news/component/moneytoday/201103/30/2011033015061550913_1.jpg" forKey:@"id6"];
        [datasource_dictionary setObject:@"http://img.sportsseoul.com/article/home/2013/04/17/130417_516de04842021.jpg" forKey:@"id7"];
        [datasource_dictionary setObject:@"http://www.betanews.net/imagedb/orig/2009/1112/28ce757b.jpg" forKey:@"id8"];
        [datasource_dictionary setObject:@"http://postfiles15.naver.net/20120402_158/blue8400_1333326667658lwRb3_JPEG/%C1%F6%C5%B3%BE%D8%C7%CF%C0%CC%B5%E51_02_03_04_05_06_07_08_09_010_011.jpg?type=w2" forKey:@"id9"];
        [datasource_dictionary setObject:@"http://postfiles11.naver.net/20121128_10/peakhill_1354085036115yL1GD_GIF/1.gif?type=w2" forKey:@"id10"];
        [datasource_dictionary setObject:@"http://postfiles11.naver.net/20120731_250/peakhill_1343698992769R3j5i_GIF/_MG_4849.gif?type=w2" forKey:@"id11"];
        [datasource_dictionary setObject:@"http://eto.co.kr/Data/2013/03/01/N2013030119103155001.jpg" forKey:@"id12"];
        [datasource_dictionary setObject:@"http://cafeptthumb2.phinf.naver.net/20110822_181/jubal144_1313985197271xE8Ni_jpg/naver_com_20110822_113335_jubal144.jpg?type=w740" forKey:@"id13"];
        [datasource_dictionary setObject:@"http://postfiles10.naver.net/20120716_185/minnatree_1342394934813E8bc8_JPEG/asd.jpg?type=w2" forKey:@"id14"];
        [datasource_dictionary setObject:@"http://www.segye.com/content/image/2012/10/30/20121030022366_0.jpg" forKey:@"id15"];
        [datasource_dictionary setObject:@"http://www.kbsn.co.kr/data/photo/20120918112218_list_caster.jpg" forKey:@"id16"];
        
        NSMutableArray *records = [NSMutableArray array];
        
        for (NSString *key in datasource_dictionary) {
            PhotoRecord *record = [[PhotoRecord alloc] init];
            record.url = [datasource_dictionary objectForKey:key];
            record.name = key;
            [records addObject:record];
        }
        
        self.photos = records;
        
        [self.tableView reloadData];
	}
	return _photos;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_operationList = [[NSMutableDictionary alloc]init];
	initialize_queue(&global_queue, 8);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.photos.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"____Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
    }
    
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];
    if (aRecord.hasImage) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
		UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        imgView.backgroundColor=[UIColor clearColor];
        [imgView setImage:aRecord.image];
        [cell.contentView addSubview:imgView];
    }
    // 5
    else {
        
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
		[self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    
    if (!record.hasImage) {
		
		[self startImageDownloadingForRecord:record atIndexPath:indexPath];
        
    }
}

- (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    // 1
	if (![self.operationList.allKeys containsObject:indexPath]) {
		ImageDownloader* _imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
		[self.operationList setObject:_imageDownloader forKey:indexPath];
		
		add_queue(&global_queue, worker, _imageDownloader);
		
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self.operationList removeObjectForKey:indexPath];
}

@end
