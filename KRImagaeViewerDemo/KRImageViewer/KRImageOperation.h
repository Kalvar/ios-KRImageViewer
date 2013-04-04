//
//  KRImageOperation.h
//
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 2012/11/07.
//  Copyright (c) 2012年 Kuo-Ming Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * NSURLConnection 快取模式
 */
typedef enum{
    KRImageOperationAllowCache = 0,
    KRImageOperationIgnoreCache
}KRImageOperationConnectionCacheModes;

@interface KRImageOperation : NSOperation{
    CGFloat _progress;
    KRImageOperationConnectionCacheModes _cacheMode;
    CGFloat timeout;
}

@property (nonatomic, strong) UIImage *doneImage;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) KRImageOperationConnectionCacheModes cacheMode;
@property (nonatomic, assign) CGFloat timeout;

-(id)initWithImageURL:(NSString *)_imageURL;

@end
