//
//  KRImageOperation.h
//  Kuo-Ming Lin
//
//  Created by Kuo-Ming Lin ( Kalvar, ilovekalvar@gmail.com ) on 12/10/2.
//  Copyright (c) 2012年 Kuo-Ming Lin All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRImageOperation : NSOperation

@property (nonatomic, retain) UIImage *doneImage;

-(id)initWithImageURL:(NSString *)_imageURL;

@end
