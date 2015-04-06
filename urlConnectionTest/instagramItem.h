//
//  instagramItem.h
//  urlConnectionTest
//
//  Created by Alexey Yachmenov on 29.03.15.
//  Copyright (c) 2015 Alexey Yachmenov. All rights reserved.
//

#import <Mantle.h>

@interface instagramItem : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSURL *thumbnail;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSDate *createdTime;

@end
