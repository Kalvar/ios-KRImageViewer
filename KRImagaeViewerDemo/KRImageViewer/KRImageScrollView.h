//
//  KRImageScrollView.h
//
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 2012/11/07.
//  Copyright (c) 2012年 Kuo-Ming Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#define KR_ZOOM_TAP            1.5f
#define KR_STATUS_BAR_VIEW_TAG 8799

@interface KRImageScrollView : UIScrollView<UIScrollViewDelegate>
{
    CGFloat _tapScale;
}

@property (nonatomic, assign) CGFloat tapScale;

-(void)displayImage:(UIImage *)_subImage;
-(void)resetImage:(UIImage *)_subImage;

@end