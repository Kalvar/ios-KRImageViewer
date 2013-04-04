//
//  KRImageViewer.h
//
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 2012/11/07.
//  Copyright (c) 2012年 Kuo-Ming Lin. All rights reserved.
//

/*
 * 模仿 Facebook App 的看圖方式 ( 寫一支 KRImagePreviewer Class )
 *  - 一個全透明 UIView (A)
 *  - 一個半透明黑色背景 UIView (B)
 *  - 修改 KRDragView 上下拖拉 ImageView 移除圖片
 *  - 設定 (B) 有 KRDragView 的上下拖拉手勢 view
 *  - 寫入 (B) ScrollView  進行左右看大圖
 *  - 可設定預設 ScrollView 的顯示圖
 */

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
    //是否允許圖片在下載處理時進行快取
    BOOL allowOperationCaching;
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
    //讀取逾時
    CGFloat timeout;
    
}

@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) krImageViewerModes dragMode;
@property (nonatomic, assign) krImageViewerDisapper dragDisapperMode;
@property (nonatomic, assign) BOOL allowOperationCaching;
@property (nonatomic, assign) CGFloat sideInstance;
@property (nonatomic, assign) CGFloat durations;
@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) NSInteger scrollToPage;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, assign) CGFloat minimumZoomScale;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) BOOL clipsToBounds;
@property (nonatomic, assign) CGFloat timeout;

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
-(void)findImageIndexWithId:(NSString *)_imageId;
-(void)findImageScrollPageWithId:(NSString *)_imageId;

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
/*
 * 直接瀏覽圖片，並且可指定要先移動到哪一張「圖片」開始瀏覽。
 */
-(void)browseImages:(NSArray *)_images startIndex:(NSInteger)_startIndex;
/*
 * 逐頁瀏覽圖片，並設定要優先下載的圖片 ( 也就「一張一張 Load」的模式 )
 */
-(void)browsePageByPageImageURLs:(NSDictionary *)_browseURLs firstShowImageId:(NSString *)_fireImageId;

@end
