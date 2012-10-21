//
//  KRImageScrollView.h
//  Kuo-Ming Lin
//
//  Created by Kuo-Ming Lin ( Kalvar, ilovekalvar@gmail.com ) on 12/10/2.
//  Copyright (c) 2012年 Kuo-Ming Lin All rights reserved.
//

#import <UIKit/UIKit.h>
#define KR_ZOOM_TAP            1.5f
#define KR_STATUS_BAR_VIEW_TAG 8799

@interface KRImageScrollView : UIScrollView<UIScrollViewDelegate>{
    CGFloat _tapScale;
}

@property (nonatomic, assign) CGFloat tapScale;

-(void)displayImage:(UIImage *)_subImage;

@end
