//
//  ViewController.m
//  urlConnectionTest
//
//  Created by Alexey Yachmenov on 29.03.15.
//  Copyright (c) 2015 Alexey Yachmenov. All rights reserved.
//

// https://instagram.com/developer/api-console/
// https://instagram.com/developer/clients/manage/

#import "ViewController.h"
#import "instagramItem.h"
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>

static NSString *baseUrl = @"https://api.instagram.com/v1/";
static NSString *apiClientId = @"07d96924714c49729f310a7f01b3815f";

@interface ViewController () <UITableViewDataSource>

@property (nonatomic, copy) NSArray *instagrams;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    // NSURLSession load data
//    NSURLSession *session = [NSURLSession sharedSession];
//    
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:[self instagramItemsForUser:@"7013409"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"Network error: %@", error);
//            return;
//        }
//        
//        if (data.length == 0) {
//            NSLog(@"Data is empty");
//            return;
//        }
//        
//        NSError *parsingError;
//        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
//        
//        if (parsingError) {
//            NSLog(@"Parsing error: %@", parsingError);
//            return;
//        }
//        
//        if (![responseObject isKindOfClass:[NSDictionary class]]) {
//            NSAssert(NO, @"Resppons object isn't NSDictionary");
//        }
//        
//        if (!responseObject[@"data"] ||
//            ![responseObject[@"data"] isKindOfClass:[NSArray class]]) {
//            NSAssert(NO, @"=(");
//        }
//        
//        NSArray *objectsArray = responseObject[@"data"];
//        
//        self.instagrams = [MTLJSONAdapter modelsOfClass:[instagramItem class] fromJSONArray:objectsArray error:&parsingError];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
//    }];
//    [task resume];
    
    // AFNetworking load data
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];

    NSDictionary *parameters = @{@"client_id" : apiClientId};
    
    [manager GET:[NSString stringWithFormat:@"users/%@/media/recent", @"7013409"] parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        NSError *error = nil;
        NSAssert([responseObject[@"data"] isKindOfClass:[NSArray class]], @"Data field is not array");
        NSArray *items = [MTLJSONAdapter modelsOfClass:[instagramItem class] fromJSONArray:responseObject[@"data"] error:&error];
        if (error) {
            NSLog(@"Maping error: %@", error);
            return;
        }
        self.instagrams = items;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//- (NSURLRequest *)instagramItemsForUser:(NSString *)userId
//{
//    NSString *requestString = [NSString stringWithFormat:@"users/%@/media/recent?client_id=%@", userId, apiClientId];
//    NSURL *url = [NSURL URLWithString:requestString relativeToURL:[self baseApiUrl]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    return request;
//}
//
//- (NSURL *)baseApiUrl
//{
//    return [NSURL URLWithString:baseUrl];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.instagrams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    instagramItem *item = self.instagrams[indexPath.row];
    
    cell.imageView.image = nil;
    cell.textLabel.text = item.caption;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"dd MM YYYY";
    cell.detailTextLabel.text = [dateFormatter stringFromDate:item.createdTime];

//    // Easy update cell image
//    __weak typeof(tableView)weakTableView = tableView;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSData *data = [NSData dataWithContentsOfURL:item.thumbnail];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (!weakTableView) return;
//            UITableViewCell *myCell = [weakTableView cellForRowAtIndexPath:indexPath];
//            if (!myCell) return;
//            myCell.imageView.image = [UIImage imageWithData:data];
//            [myCell setNeedsLayout];
//            [myCell layoutIfNeeded];
//        });
//    });
    

    // AFNetworking update cell image
    __weak typeof(cell)weakCell = cell;
    __weak typeof(tableView)weakTableView = tableView;
    [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:item.thumbnail]
                          placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                              UITableViewCell *updateCell = [weakTableView cellForRowAtIndexPath:indexPath] ?: weakCell;
                              if (updateCell) {
                                  updateCell.imageView.image = image;
                                  [updateCell setNeedsLayout];
                                  [updateCell layoutIfNeeded];
                              }
                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                              NSLog(@"Can't load image with error %@", error);
                          }];
    
    return cell;
}

@end
