//
//  KRImageViewer.h
//  V1.0.2
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 2012/11/07.
//  Copyright (c) 2012 - 2014 年 Kuo-Ming Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KRIV_ZOOM_SCALE 2.5f

@protocol KRImageViewerDelegate;

//圖片的拖拉消失模式
typedef enum krImageViewerModes
{
    //兩邊都行( 預設 )
    krImageViewerModeOfBoth = 0,
    //由上至下滑
    krImageViewerModeOfTopToBottom,
    //由下至上滑
    krImageViewerModeOfBottomToTop
} krImageViewerModes;

//圖片自動消失的距離
typedef enum krImageViewerDisapper
{
    //過中線才消失
    krImageViewerDisapperAfterMiddle = 0,
    //離開螢幕 25% 才消失
    krImageViewerDisapperAfter25Percent,
    //離開螢幕 10% 才消失
    krImageViewerDisapperAfter10Percent,
    //不消失
    krImageViewerDisapperNothing
} krImageViewerDisapper;

//現在正瀏覽到哪一頁
typedef void(^KRImageViewerBrowsingHandler)(NSInteger browsingPage);
//現在正捲動到哪一頁
typedef void(^KRImageViewerScrollingHandler)(NSInteger scrollingPage);

@interface KRImageViewer : NSObject<UIScrollViewDelegate>
{
    __weak id<KRImageViewerDelegate> delegate;
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
    //Current Device Rotation
    UIInterfaceOrientation interfaceOrientation;
    //Done Button Title
    NSString *doneButtonTitle;
    //Supports rotations
    BOOL supportsRotations;
    //Auto clear the memory caches.
    NSInteger overCacheCountRelease;
    //Sorting Rule.
    BOOL sortAsc;
    //外部決定的圖片顯示順序
    NSMutableArray *forceDisplays;
}

@property (nonatomic, weak) id<KRImageViewerDelegate> delegate;
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
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, strong) NSString *doneButtonTitle;
@property (nonatomic, assign) BOOL supportsRotations;
@property (nonatomic, assign) NSInteger overCacheCountRelease;
@property (nonatomic, assign) BOOL sortAsc;
@property (nonatomic, strong) NSMutableArray *forceDisplays;

@property (nonatomic, copy) KRImageViewerBrowsingHandler browsingHandler;
@property (nonatomic, copy) KRImageViewerScrollingHandler scrollingHandler;

-(void)setBrowsingHandler:(KRImageViewerBrowsingHandler)_theBrowsingHandler;
-(void)setScrollingHandler:(KRImageViewerScrollingHandler)_theScrollingHandler;

+(instancetype)sharedManager;

/*
 * Initialize
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
-(void)useKeyWindow;
-(void)refresh;
-(void)pause;
-(void)restart;
-(void)findImageIndexWithId:(NSString *)_imageId;
-(void)findImageScrollPageWithId:(NSString *)_imageId;

/*
 * @ 預載圖片，但不瀏覽
 *   - To preload the images, but it won't be start in browsing immediately.
 */
-(void)preloadImageURLs:(NSDictionary *)_preloadImages;
/*
 * @ 輸入 URL 進行下載、快取並瀏覽
 *   - Direct downloading images from URLs, caching and browsing. 
 */
-(void)browseAnImageURL:(NSString *)_imageURL;
-(void)browseImageURLs:(NSDictionary *)_browseURLs;
/*
 * @ 直接輸入圖片進行瀏覽
 *   - Direct browsing the image files. ( UIImages )
 */
-(void)browseImages:(NSArray *)_images;
/*
 * @ 直接瀏覽圖片，並且可指定要先移動到哪一張「圖片」開始瀏覽。
 *   - Direct browsing the image files and setting the start in page is which one.
 */
-(void)browseImages:(NSArray *)_images startIndex:(NSInteger)_startIndex;
/*
 * @ 逐頁瀏覽圖片，並設定要優先下載的圖片 ( 也就「一張一張 Load」的模式 )
 *   - Page by Page to browse images, and you can input ID of image to set which image is the first show.
 */
-(void)browsePageByPageImageURLs:(NSDictionary *)_browseURLs firstShowImageId:(NSString *)_fireImageId;
/*
 * @ 旋轉時重載入
 *   - Reset the image-viewer's rotation. 
 */
-(void)reloadImagesWhenRotate:(UIInterfaceOrientation)_toInterfaceOrientation;
/*
 * @ 監聽 Device 旋轉事件
 *   - Watch the rotations
 */
-(void)startWatchRotations;
-(void)stopWatchRotations;
-(void)stopWatchRotationsAndBackToInitialRotation;


@end

@protocol KRImageViewerDelegate <NSObject>

@optional
//現在正瀏覽到哪一頁
-(void)krImageViewerIsBrowsingPage:(NSInteger)_browsingPage;
//現在正捲動到哪一頁
-(void)krImageViewerIsScrollingToPage:(NSInteger)_scrollingPage;


@end
