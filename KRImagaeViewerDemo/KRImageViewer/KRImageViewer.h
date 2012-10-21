//
//  KRViewDrags.h
//  Kuo-Ming Lin
//
//  Created by Kuo-Ming Lin ( Kalvar, ilovekalvar@gmail.com ) on 12/10/2.
//  Copyright (c) 2012年 Kuo-Ming Lin All rights reserved.
//

#import <UIKit/UIKit.h>

#define KRIV_ZOOM_SCALE 2.5

//圖片的拖拉消失模式
typedef enum _krImageViewerModes {
    //兩邊都行( 預設 )
    krImageViewerModeOfBoth = 0,
    //由上至下滑
    krImageViewerModeOfTopToBottom,
    //由下至上滑
    krImageViewerModeOfBottomToTop
} krImageViewerModes;

//圖片自動消失的距離
typedef enum _krImageViewerDisapper{
    //過中線才消失
    krImageViewerDisapperAfterMiddle = 0,
    //離開螢幕 25% 才消失
    krImageViewerDisapperAfter25Percent,
    //離開螢幕 10% 才消失
    krImageViewerDisapperAfter10Percent,
    //不消失
    krImageViewerDisapperNothing
} krImageViewerDisapper;

@interface KRImageViewer : NSObject<UIScrollViewDelegate>{
    //作用的 View
    UIView *view;
    //拖拉模式
    krImageViewerModes dragMode;
    //圖片自動消失的距離
    krImageViewerDisapper dragDisapperMode;
    //距離螢幕邊緣多遠就定位
    CGFloat sideInstance;
    //最後定位的動畫時間
    CGFloat durations;
    //佇列 Queue 在每次會處理幾張圖片
    NSInteger maxConcurrentOperationCount;
    //是否隱藏狀態列
    BOOL statusBarHidden;
    //預設要執行第幾張圖
    NSInteger scrollToPage;
    //KRImageScrollView 的參數
    CGFloat maximumZoomScale;
    CGFloat minimumZoomScale;
    CGFloat zoomScale;
    BOOL clipsToBounds;
}

@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) krImageViewerModes dragMode;
@property (nonatomic, assign) krImageViewerDisapper dragDisapperMode;
@property (nonatomic, assign) CGFloat sideInstance;
@property (nonatomic, assign) CGFloat durations;
@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) NSInteger scrollToPage;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, assign) CGFloat minimumZoomScale;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) BOOL clipsToBounds;


/*
 * Init
 */
-(id)initWithParentView:(UIView *)_parentView dragMode:(krImageViewerModes)_dragMode;
-(id)initWithDragMode:(krImageViewerModes)_dragMode;
/*
 *
 */
-(void)cancel;
-(void)start;
-(void)stop;
-(void)resetView:(UIView *)_parentView withDragMode:(krImageViewerModes)_dragMode;
-(void)resetView:(UIView *)_parentView;
-(void)refresh;
-(void)pause;
-(void)restart;
/*
 * 預載圖片，但不瀏覽
 */
-(void)preloadImageURLs:(NSDictionary *)_preloadImages;
/*
 * 輸入 URL 進行下載、快取並瀏覽
 */
-(void)browseAnImageURL:(NSString *)_imageURL;
-(void)browseImageURLs:(NSDictionary *)_browseURLs;
/*
 * 直接輸入圖片進行瀏覽
 */
-(void)browseImages:(NSArray *)_images;


@end
