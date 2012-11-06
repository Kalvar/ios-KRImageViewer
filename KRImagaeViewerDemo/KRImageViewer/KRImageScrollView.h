//
//  KRImageScrollView.h
//  MC
//
//  Created by Kalvar on 12/10/18.
//  Copyright (c) 2012年 Flashaim Inc. All rights reserved.
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
