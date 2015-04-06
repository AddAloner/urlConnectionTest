//
//  instagramItem.m
//  urlConnectionTest
//
//  Created by Alexey Yachmenov on 29.03.15.
//  Copyright (c) 2015 Alexey Yachmenov. All rights reserved.
//

#import "instagramItem.h"

@implementation instagramItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"thumbnail": @"images.thumbnail.url",
             @"caption": @"caption.text",
             @"createdTime": @"created_time",
             };
}

+ (NSValueTransformer *)createdTimeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.integerValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%@", @(date.timeIntervalSince1970)];
    }];
}

+ (NSValueTransformer *)thumbnailJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSURL URLWithString:str];
    } reverseBlock:^(NSURL *url) {
        return url.absoluteString;
    }];
}

@end
