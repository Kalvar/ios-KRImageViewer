//
//  KRImageOperation.h
//  MC
//
//  Created by Kalvar on 12/10/15.
//  Copyright (c) 2012年 Flashaim Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 連線快取模式
 */
typedef enum{
    KRImageOperationAllowCache = 0,
    KRImageOperationIgnoreCache
}KRImageOperationConnectionCacheModes;

@interface KRImageOperation : NSOperation{
    CGFloat _progress;
    KRImageOperationConnectionCacheModes _cacheMode;
}

@property (nonatomic, retain) UIImage *doneImage;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) KRImageOperationConnectionCacheModes cacheMode;

-(id)initWithImageURL:(NSString *)_imageURL;

@end
