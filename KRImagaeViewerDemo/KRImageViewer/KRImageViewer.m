//
//  KRImageViewer.m
//  V1.0.2
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 2012/11/07.
//  Copyright (c) 2012 - 2014 年 Kuo-Ming Lin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KRImageViewer.h"
#import "KRImageOperation.h"
#import "KRImageScrollView.h"


static CGFloat _backgroundViewBlackColor = 0.0f;
static NSInteger _krImageViewerActivityBackgroundViewTag = 1799;
static NSInteger _krImageViewerCancelButtonTag           = 1800;
static NSInteger _krImageViewerBrowsingButtonTag         = 1801;
static NSInteger _krImageViewerActivityIndicatorTag      = 1802;

@interface KRImageViewer ()
{
    UIPanGestureRecognizer *_panGestureRecognizer;
    NSOperationQueue *_operationQueues;
    UIView *_backgroundView;
    UIView *_dragView;
    UIScrollView *_scrollView;
    //要顯示的圖片 [imageID] = imageURL;
    NSMutableDictionary *_caches;
    NSMutableArray *_sortedKeys;
    NSMutableDictionary *_imageInfos;
}

@property (nonatomic, assign) CGPoint _orignalPoints;
@property (nonatomic, assign) CGPoint _matchPoints;
@property (nonatomic, strong) UIPanGestureRecognizer *_panGestureRecognizer;
@property (nonatomic, strong) UIView *_gestureView;
@property (nonatomic, strong) NSOperationQueue *_operationQueues;
@property (nonatomic, strong) UIView *_backgroundView;
@property (nonatomic, strong) UIView *_dragView;
@property (nonatomic, strong) UIScrollView *_scrollView;
@property (nonatomic, strong) NSMutableDictionary *_caches;
@property (nonatomic, strong) NSMutableArray *_sortedKeys;
@property (nonatomic, strong) NSMutableDictionary *_imageInfos;
@property (nonatomic, assign) BOOL _isCancelled;
//是否執行一張一張 Load 圖的模式
@property (nonatomic, assign) BOOL _isOncePageToLoading;
@property (nonatomic, assign) BOOL _firstTimeSetting;
@property (nonatomic, assign) UIInterfaceOrientation _initialInterfaceOrientation;


@end

@interface KRImageViewer (fixDrages)

-(void)_initWithVars;
-(void)_renewBackgroundViewColorAndAlpha;
-(void)_renewDragViewColorAndAlpha;
-(void)_resetGestureView;
-(void)_resetViewVars;
-(void)_setupBackgroundView;
-(void)_setupDragView;
-(void)_allocPanGesture;
-(void)_addViewDragGesture;
-(void)_removeViewDragGesture;
-(void)_moveView:(UIView *)_targetView toX:(CGFloat)_toX toY:(CGFloat)_toY;
-(CGFloat)_dragDisapperInstance;
-(void)_hideDoneButton;
-(void)_displayDoneButton;
-(void)_handleDrag:(UIPanGestureRecognizer*)_panGesture;
//
-(void)_addCacheImage:(UIImage *)_doneImage forKey:(NSString *)_imageKey;
-(void)_removeAllCaches;
-(void)_resortKeys;
-(void)_cancelAllOperations;
-(void)_downloadImageURLs:(NSDictionary *)_urls;
-(void)_resetBackgroundViewAlpha;
//
-(void)_scrollViewRemoveAllSubviews;
-(void)_setupScrollView;
-(void)_setupImagesInScrollView;
//
-(void)_browseImages;
-(void)_removeBrowser:(id)sender;
-(void)_removeAllViews;
//
-(CGFloat)_statusBarHeight;
-(void)_resetIndicator:(UIActivityIndicatorView *)_indicator withFrame:(CGRect)_frame;
-(void)_startLoadingWithView:(UIView *)_targetView needCancelButton:(BOOL)_needCancelButton;
-(void)_startLoadingWithView:(UIView *)_targetView;
-(void)_stopLoadingWithView:(UIView *)_targetView;
-(void)_startLoadingOnMainView;
-(void)_stopLoadingOnMainView;
-(void)_startLoadingOnKRImageScrollView:(KRImageScrollView *)_targetView;
-(void)_appearStatus:(BOOL)_isAppear;
//
-(NSInteger)_currentPage;
-(NSInteger)_currentIndex;
-(void)_scrollToPage:(NSInteger)_toPage;
//
-(NSDictionary *)_sortDictionary:(NSDictionary *)_formatedDatas ascending:(BOOL)_isAsc;
-(BOOL)_isInt:(NSString*)_string;
-(void)_refreshCaches;
-(void)_disapperAsSuckEffect;
//
-(NSInteger)_findOperationCacheMode;
-(void)_cancelAndClose:(id)sender;
-(UIButton *)_doneBrowserButton;
-(UIButton *)_cancelDownloadingButtonWithSuperFrame:(CGRect)_superFrame;
//
-(UIImage *)_imageNameNoCache:(NSString *)_imageName;
-(NSString *)_findImageIndexWithId:(NSString *)_imageId;
-(void)_loadImageWithPage:(NSInteger)_loadPage;
-(void)_addDefaultImagesOnScrollView;
-(void)_firedBrowsingDelegate;
-(void)_firedScrollingDelegate;
-(void)_resizeScrollViewWithFrame:(CGRect)_frame;
-(void)_resizeBackgroundViewWithFrame:(CGRect)_frame andTransform:(CGAffineTransform)_transform;
-(void)_resizeDragViewWithFrame:(CGRect)_frame;
-(void)_resizeDoneButton:(UIButton *)_button;
-(void)_resizeCancelButton:(UIButton *)_button withSuperFrame:(CGRect)_superFrame;
-(void)_resetIndicatorWithSuperFrame:(CGRect)_superFrame;
-(void)_deviceDidRotate;

@end

@implementation KRImageViewer (fixDrages)

-(void)_initWithVars
{
    if( self.maxConcurrentOperationCount <= 0 )
    {
        //一次只處理 n 個 Operation
        self.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    self.sideInstance = 0.0f;
    self.durations    = 0.2f;
    _operationQueues  = [[NSOperationQueue alloc] init];
    _caches           = [[NSMutableDictionary alloc] initWithCapacity:0];
    _sortedKeys       = [[NSMutableArray alloc] initWithCapacity:0];
    _imageInfos       = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.dragDisapperMode      = krImageViewerDisapperAfterMiddle;
    self.allowOperationCaching = YES;
    self.statusBarHidden       = YES;
    self.scrollToPage          = 0;
    self.maximumZoomScale      = 2.0f;
    self.minimumZoomScale      = 1.0f;
    self.zoomScale             = 2.0f;
    self.clipsToBounds         = YES;
    self.timeout               = 60.0f;
    self.interfaceOrientation  = UIInterfaceOrientationPortrait;
    self.doneButtonTitle       = @"完成";
    self.overCacheCountRelease = 0;
    //Private
    self._isCancelled          = NO;
    self._isOncePageToLoading  = NO;
    //Do Setters
    supportsRotations          = NO;
    self._firstTimeSetting     = YES;
    self._initialInterfaceOrientation = UIInterfaceOrientationPortrait;
    self.sortAsc               = NO;
    self.forceDisplays         = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.browsingHandler  = nil;
    self.scrollingHandler = nil;
}

-(void)_renewBackgroundViewColorAndAlpha
{
    [self._backgroundView setBackgroundColor:[UIColor clearColor]];
    [self._backgroundView setBackgroundColor:[UIColor colorWithRed:_backgroundViewBlackColor
                                                             green:_backgroundViewBlackColor
                                                              blue:_backgroundViewBlackColor
                                                             alpha:0.9f]];
}

-(void)_renewDragViewColorAndAlpha
{
    //[self._dragView setBackgroundColor:[UIColor blackColor]];
    [self._dragView setBackgroundColor:[UIColor clearColor]];
}

-(void)_resetGestureView
{
    if( self._dragView )
    {
        self._gestureView   = self._dragView;
        self._orignalPoints = self._gestureView.center;
        [self _resetMatchPoints];
    }
}

-(void)_resetViewVars
{
    [self _setupBackgroundView];
    [self _setupDragView];
    [self _setupScrollView];
    [self _resetGestureView];
}

/*
 * @ 半透明背景 UIView 會隨著 self.view 的 frame 同步調整
 */
-(void)_setupBackgroundView
{
    if( !_backgroundView )
    {
        _backgroundView = [[UIView alloc] init];
    }
    if( self.view )
    {
        [self._backgroundView setFrame:self.view.frame];
    }
    [self _renewBackgroundViewColorAndAlpha];
}

-(void)_setupDragView
{
    if( !_dragView )
    {
        _dragView = [[UIView alloc] init];
    }
    
    if( self.view )
    {
        [self._dragView setFrame:self.view.frame];
    }
    /*
     * @ Noted By 2013.03.16 PM 20:03
     *   - 就是這裡的 [UIColor clearColor] 會造成圖片在縮放時破板 ... 還不知道原因 >_< 2013.03.16 PM 23:58
     *     而且點圖片的 Loading 圖示也會破板，但只要畫面不是在「中間的地址額外資訊的 Block」上，就不會破版 ....
     *     self._dragView 的背景設成沒有透明度的「純色系」，就不會出現破版問題 ...
     *     猜測，有可能是「中間的地址 Block」有用到 Quatz 畫圓角的關係 ... 可能重疊到了特效之類 ??
     *
     * @ Noted By 2013.03.17 PM 16:52
     *   - 證實後，確實是圓角特效的關係，再加上被設置成了 masksToBounds 屬性為 YES，這就會讓被蓋在上層的 UIView 的透明背景失效 :XD ~ ( 因為層級較低 )，
     *     解決方法就是去將 masksToBounds 設成 NO 即可，或不要使用 QuartzCore 的圓角特效 XD，或將背景色設為不使用透明度的「純色系」即可。
     */
    [self _renewDragViewColorAndAlpha];
}

-(void)_resetMatchPoints
{
    /*
     * 因為不允許左右移動，所以 X 軸幾乎不會動
     * 如果現在的 X 軸與原始的 X 軸不相等，代表畫面上的 View 有變動
     */
    //修正誤差
    CGFloat _xOffset = 0.0f;
    if( self._gestureView.center.x != self._orignalPoints.x )
    {
        _xOffset = self._gestureView.center.x - self._orignalPoints.x;
    }
    self._matchPoints = CGPointMake(self._orignalPoints.x + _xOffset, self._orignalPoints.y);
}

-(void)_allocPanGesture
{
    if( _panGestureRecognizer ) return;
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(_handleDrag:)];
}

-(void)_addViewDragGesture
{
    [self._gestureView addGestureRecognizer:self._panGestureRecognizer];
}

-(void)_removeViewDragGesture
{
    [self._gestureView removeGestureRecognizer:self._panGestureRecognizer];
}

-(void)_moveView:(UIView *)_targetView
             toX:(CGFloat)_toX
             toY:(CGFloat)_toY
{
    [UIView animateWithDuration:self.durations delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _targetView.frame = CGRectMake(_toX,
                                       _toY,
                                       _targetView.frame.size.width,
                                       _targetView.frame.size.height);
    } completion:^(BOOL finished) {
        //...
    }];
}

-(CGFloat)_dragDisapperInstance
{
    CGFloat _screenHeight     = self._gestureView.frame.size.height;
    CGFloat _disapperInstance = 0.0f;
    switch ( self.dragDisapperMode )
    {
        case krImageViewerDisapperAfterMiddle:
            _disapperInstance = _screenHeight / 2;
            break;
        case krImageViewerDisapperAfter25Percent:
            _disapperInstance = _screenHeight * 0.25;
            break;
        case krImageViewerDisapperAfter10Percent:
            _disapperInstance = _screenHeight * 0.1;
            break;
        case krImageViewerDisapperNothing:
            // ...
            break;
        default:
            break;
    }
    //NSLog(@"_screenHeight : %f", _screenHeight);
    return _disapperInstance;
}

-(void)_hideDoneButton
{
    [(UIButton *)[self._dragView viewWithTag:_krImageViewerBrowsingButtonTag] setHidden:YES];
}

-(void)_displayDoneButton
{
    [(UIButton *)[self._dragView viewWithTag:_krImageViewerBrowsingButtonTag] setHidden:NO];
}

/*
 * 拖拉的動作
 * - 待優化
 */
-(void)_handleDrag:(UIPanGestureRecognizer *)_panGesture
{
    //目前手勢 View 的中心位置
    CGPoint center      = _panGesture.view.center;
    //手勢在目前 View 上的觸碰點
    CGPoint translation = [_panGesture translationInView:_panGesture.view];
    //當前作用 View 的位置
    CGPoint viewCenter  = self._gestureView.frame.origin;
    //判斷是否需重設原比對用的 X 座標值
    [self _resetMatchPoints];
    
    //  NSLog(@"o.x : %f", self._matchPoints.x);
    //  NSLog(@"v.x : %f", viewCenter.x);
    //  NSLog(@"center.y : %f", center.y);
    //  NSLog(@"o.y : %f", self._matchPoints.y);
    //  NSLog(@"center.x : %f", center.x);
    //  NSLog(@"trans.x : %f\n\n", translation.x);
    
    switch (self.dragMode)
    {
        case krImageViewerModeOfTopToBottom:
            /*
             * 只允許往下移動
             */
            if( translation.y < 0 && viewCenter.y <= 0 ) return;
            //拖拉移動
            if (_panGesture.state == UIGestureRecognizerStateChanged)
            {
                if( center.x == self._matchPoints.x )
                {
                    center = CGPointMake(self._matchPoints.x, center.y + translation.y);
                    _panGesture.view.center = center;
                    [_panGesture setTranslation:CGPointZero inView:_panGesture.view];
                    [self _hideDoneButton];
                    //代表沒移動
                    if( center.y == self._matchPoints.y )
                    {
                        [self _appearStatus:NO];
                    }
                    else
                    {
                        [self _appearStatus:YES];
                    }
                    [self _resetBackgroundViewAlpha];
                }
            }
            
            //結束觸碰
            if(_panGesture.state == UIGestureRecognizerStateEnded)
            {
                CGFloat _screenHeight = self._gestureView.frame.size.height;
                CGFloat _moveDistance = _screenHeight - self.sideInstance;
                [self _appearStatus:NO];
                [self _displayDoneButton];
                //檢查 X 是否已過中線
                if( viewCenter.y > [self _dragDisapperInstance] )
                {
                    //打開
                    [self _moveView:self._gestureView toX:0.0f toY:_moveDistance];
                    //關閉 Viewer
                    [self stop];
                }
                else
                {
                    //回到原點
                    [self _moveView:self._gestureView toX:0.0f toY:0.0f];
                }
            }
            break;
        case krImageViewerModeOfBottomToTop:
            /*
             * 只允許往上移動
             */
            if( translation.y > 0 && viewCenter.y >= 0 ) return;
            //拖拉移動
            if (_panGesture.state == UIGestureRecognizerStateChanged)
            {
                if( center.x == self._matchPoints.x )
                {
                    center = CGPointMake(self._matchPoints.x, center.y + translation.y);
                    _panGesture.view.center = center;
                    [_panGesture setTranslation:CGPointZero inView:_panGesture.view];
                    [self _hideDoneButton];
                    //代表沒移動
                    if( center.y == self._matchPoints.y )
                    {
                        [self _appearStatus:NO];
                    }
                    else
                    {
                        [self _appearStatus:YES];
                    }
                    [self _resetBackgroundViewAlpha];
                }
            }
            
            //結束觸碰
            if(_panGesture.state == UIGestureRecognizerStateEnded)
            {
                CGFloat _screenHeight = self._gestureView.frame.size.height;
                CGFloat _moveDistance = -(_screenHeight - self.sideInstance);
                [self _appearStatus:NO];
                [self _displayDoneButton];
                //過中線就 Open
                if( viewCenter.y < -( [self _dragDisapperInstance] ) )
                {
                    [self _moveView:self._gestureView toX:0.0f toY:_moveDistance];
                    [self stop];
                }
                else
                {
                    //Close
                    [self _moveView:self._gestureView toX:0.0f toY:0.0f];
                }
            }
            break;
        case krImageViewerModeOfBoth:
            //上下都能拖拉
            if (_panGesture.state == UIGestureRecognizerStateChanged)
            {
                center = CGPointMake(self._matchPoints.x, center.y + translation.y);
                _panGesture.view.center = center;
                [_panGesture setTranslation:CGPointZero inView:_panGesture.view];
                [self _hideDoneButton];
                if( center.y == self._matchPoints.y )
                {
                    [self _appearStatus:NO];
                }
                else if( viewCenter.y > [self _dragDisapperInstance] )
                {
                    //檢查 X 是否已過中線
                    CGFloat _screenHeight = self._gestureView.frame.size.height;
                    CGFloat _moveDistance = _screenHeight - self.sideInstance;
                    //打開
                    [self _moveView:self._gestureView toX:0.0f toY:_moveDistance];
                    //關閉 Viewer
                    [self stop];
                }
                else
                {
                    [self _appearStatus:YES];
                }
                [self _resetBackgroundViewAlpha];
            }
            
            if(_panGesture.state == UIGestureRecognizerStateEnded)
            {
                CGFloat _screenHeight = self._gestureView.frame.size.height;
                CGFloat _moveDistance = -(_screenHeight - self.sideInstance);
                [self _appearStatus:NO];
                [self _displayDoneButton];
                if( viewCenter.y < -( [self _dragDisapperInstance] ) )
                {
                    [self _moveView:self._gestureView toX:0.0f toY:_moveDistance];
                    [self stop];
                }
                else
                {
                    [self _moveView:self._gestureView toX:0.0f toY:0.0f];
                }
            }
            break;
        default:
            //...
            break;
    }
}

-(void)_addCacheImage:(UIImage *)_doneImage forKey:(NSString *)_imageKey
{
    if( self.overCacheCountRelease > 0 )
    {
        if( [self._caches count] > self.overCacheCountRelease )
        {
            [self _removeAllCaches];
        }
    }
    [self._caches setObject:_doneImage forKey:_imageKey];
}

-(void)_removeAllCaches
{
    [self._caches removeAllObjects];
}

-(void)_resortKeys
{
    if( [self._caches count] > 0 )
    {
        NSDictionary *_sortedCaches = [self _sortDictionary:self._caches ascending:YES];
        [self._sortedKeys removeAllObjects];
        [self._sortedKeys addObjectsFromArray:[_sortedCaches objectForKey:@"keys"]];
    }
}

-(void)_cancelAllOperations
{
    if( self._operationQueues.operationCount > 0 )
    {
        //self._isCancelled = YES;
        [self._operationQueues cancelAllOperations];
    }
}

/*
 * 下載來自 URL 的圖片
 */
-(void)_downloadImageURLs:(NSDictionary *)_urlInfos
{
    [self _cancelAllOperations];
    [self _startLoadingOnMainView];
    //[self _removeAllCaches];
    NSInteger _total = [_urlInfos count];
    if( _total > 0 )
    {
        NSInteger _count = 0;
        for( NSString *_imageKey in _urlInfos )
        {
            ++_count;
            //如果有快取就不理會
            if( [self._caches objectForKey:_imageKey] )
            {
                if( _total == _count )
                {
                    [self _resortKeys];
                    [self start];
                    [self _stopLoadingOnMainView];
                    break;
                }
                continue;
            }
            NSString *_url = [_urlInfos objectForKey:_imageKey];
            //設定 NSOperation
            KRImageOperation *_op = [[KRImageOperation alloc] initWithImageURL:_url];
            __weak KRImageOperation *_operation = _op;
            _operation.timeout   = self.timeout;
            _operation.cacheMode = [self _findOperationCacheMode];
            //使用 ^Block (設定完成時候的動作)
            [_operation setCompletionBlock:^{
                //寫入快取
                if( _operation.doneImage )
                {
                    [self _addCacheImage:_operation.doneImage forKey:_imageKey];
                    _operation.doneImage = nil;
                }
                //全處理完了 + 是最後一筆
                if( _operationQueues.operationCount == 0 && _total == _count )
                {
                    //NSLog(@"isCancelled : %i", self._isCancelled);
                    //NSLog(@"wow : operationCount, total, count : %i, %i, %i", self._operationQueues.operationCount, _total, _count);
                    if( !self._isCancelled )
                    {
                        [self _resortKeys];
                        [self start];
                        [self _stopLoadingOnMainView];
                    }
                }
            }];
            //寫入排程
            [_operationQueues addOperation:_operation];
        }
    }
    else
    {
        [self _stopLoadingOnMainView];
    }
}

-(void)_resetBackgroundViewAlpha
{
    //計算比例
    CGFloat _offsetAlpha  = -0.2f;
    CGFloat _screenHeight = self._gestureView.frame.size.height;
    CGFloat _dragHeight   = self._dragView.frame.origin.y;
    CGFloat _diffInstance = fabsf( _dragHeight - _screenHeight );
    CGFloat _maxHeight    = MAX(_diffInstance, _screenHeight);
    CGFloat _minHeight    = MIN(_diffInstance, _screenHeight);
    CGFloat _alpha        = (_minHeight / _maxHeight);
    [self._backgroundView setBackgroundColor:[UIColor colorWithRed:_backgroundViewBlackColor
                                                             green:_backgroundViewBlackColor
                                                              blue:_backgroundViewBlackColor
                                                             alpha:_alpha + _offsetAlpha]];
}

/*
 * ScrollView
 */
-(void)_scrollViewRemoveAllSubviews
{
    if( self._scrollView )
    {
        for(UIView *subview in [self._scrollView subviews])
        {
            [subview removeFromSuperview];
        }
    }
}

-(void)_setupScrollView
{
    CGRect _frame = self.view.frame;
    if( !_scrollView )
    {
        //_frame.size.height = 400.0f;
        _scrollView = [[UIScrollView alloc] init];
    }
    [self._scrollView setFrame:_frame];
    //設定是否啟動分頁機制 : 如不啟動，則會一直滑動不停 ; 如啟動，會一格一格的分頁顯示
    [self._scrollView setPagingEnabled:YES];
    self._scrollView.showsHorizontalScrollIndicator = NO;
    self._scrollView.showsVerticalScrollIndicator   = NO;
    //Scale
    //CGFloat _maxScaleSize = 2.0f;
    self._scrollView.contentMode      = UIViewContentModeCenter;
    //self._scrollView.maximumZoomScale = 2.0f;
    //self._scrollView.minimumZoomScale = 1.0f;
    //self._scrollView.zoomScale        = _maxScaleSize;
    //self._scrollView.clipsToBounds    = YES;
    self._scrollView.delegate         = self;
    self._scrollView.backgroundColor  = [UIColor clearColor];
}

/*
 * 檢查這一支函式 ... ?? Checking for What ?
 */
-(void)_setupImagesInScrollView
{
    [self _scrollViewRemoveAllSubviews];
    CGRect _innerFrame = CGRectMake(0.0f,
                                    0.0f,
                                    self._scrollView.frame.size.width,
                                    self._scrollView.frame.size.height);
    for( NSString *_imageKey in self._sortedKeys )
    {
        UIImage *_image = [self._caches objectForKey:_imageKey];
        KRImageScrollView *_krImageScrollView = [[KRImageScrollView alloc] initWithFrame:_innerFrame];
        _krImageScrollView.maximumZoomScale = self.maximumZoomScale;
        _krImageScrollView.minimumZoomScale = self.minimumZoomScale;
        _krImageScrollView.zoomScale        = self.zoomScale;
        _krImageScrollView.clipsToBounds    = self.clipsToBounds;
        [_krImageScrollView displayImage:_image];
        [self._scrollView addSubview:_krImageScrollView];
        _innerFrame.origin.x += _innerFrame.size.width;
    }
    [self._scrollView setContentSize:CGSizeMake(_innerFrame.origin.x, _innerFrame.size.height)];
}

-(void)_browseImages
{
    if( [self._caches count] > 0 )
    {
        [self _setupImagesInScrollView];
        [self _scrollToPage:self.scrollToPage];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self._dragView addSubview:self._scrollView];
            [self._dragView addSubview:[self _doneBrowserButton]];
            [self._backgroundView addSubview:self._dragView];
            [self.view addSubview:self._backgroundView];
        });
    }
}

-(void)_removeBrowser:(id)sender
{
    //[[(UIButton *)sender superview] removeFromSuperview];
    //[self _appearStatus:YES];
    //[self _removeAllViews];
    [self stop];
}

-(void)_removeAllViews
{
    //Remove ImageView's images to release memories.
    for( UIView *_subview in self._backgroundView.subviews )
    {
        if( [_subview isKindOfClass:[UIImageView class]] )
        {
            UIImageView *_imageView = (UIImageView *)_subview;
            _imageView.image = nil;
            [_imageView removeFromSuperview];
        }
    }
    if( [self._dragView viewWithTag:_krImageViewerBrowsingButtonTag] )
    {
        [[self._dragView viewWithTag:_krImageViewerBrowsingButtonTag] removeFromSuperview];
    }
    if( [self._dragView viewWithTag:_krImageViewerCancelButtonTag] )
    {
        [[self._dragView viewWithTag:_krImageViewerCancelButtonTag] removeFromSuperview];
    }
    [self._backgroundView removeFromSuperview];
    [self._dragView removeFromSuperview];
    //[self.view removeFromSuperview];
}

-(CGFloat)_statusBarHeight
{
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

-(void)_resetIndicator:(UIActivityIndicatorView *)_indicator withFrame:(CGRect)_frame
{
    _indicator.center = CGPointMake(_frame.size.width / 2.0f,
                                    _frame.size.height / 2.0f);
}

-(void)_startLoadingWithView:(UIView *)_targetView needCancelButton:(BOOL)_needCancelButton
{
    /*
     *  @ 非 PageByPage Loading 模式
     *    - 使用 _krImageViewerActivityBackgroundViewTag 當成 ActivityIndicator 底下的背景 View Tag，
     *      之後就能使用該 Tag 取出要移除的 ActivityIndicator。
     */
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if( [_targetView viewWithTag:_krImageViewerActivityBackgroundViewTag] )
        {
           return;
        }
        //UIView *_targetView = self.view;
        CGRect _frame = CGRectMake(0.0f, 0.0f, _targetView.frame.size.width, _targetView.frame.size.height);
        //
        UIView *_loadingBackgroundView = [[UIView alloc] initWithFrame:_frame];
        [_loadingBackgroundView setTag:_krImageViewerActivityBackgroundViewTag];
        [_loadingBackgroundView setBackgroundColor:[UIColor blackColor]];
        [_loadingBackgroundView setAlpha:0.5];
        [_targetView addSubview:_loadingBackgroundView];
        //
        if( _needCancelButton )
        {
           [_targetView addSubview:[self _cancelDownloadingButtonWithSuperFrame:_frame]];
        }
        //
        UIActivityIndicatorView *_loadingIndicator = [[UIActivityIndicatorView alloc]
                                                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_loadingIndicator setTag:_krImageViewerActivityIndicatorTag];
        //_loadingIndicator.center = CGPointMake(_targetView.bounds.size.width / 2.0f, _targetView.bounds.size.height / 2.0f);
        [self _resetIndicator:_loadingIndicator withFrame:_targetView.bounds];
        [_loadingIndicator setColor:[UIColor whiteColor]];
        [_loadingIndicator startAnimating];
        [_targetView addSubview:_loadingIndicator];
    });
}

-(void)_startLoadingWithView:(UIView *)_targetView
{
    [self _startLoadingWithView:_targetView needCancelButton:YES];
}

-(void)_stopLoadingWithView:(UIView *)_targetView
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //UIView *_targetView = self.view;
        if( _targetView )
        {
            for(UIView *subview in [_targetView subviews])
            {
                if([subview isKindOfClass:[UIActivityIndicatorView class]])
                {
                    [(UIActivityIndicatorView *)subview stopAnimating];
                    [subview removeFromSuperview];
                    break;
                }
            }
        }
        //移除 Cancel Button
        [[_targetView viewWithTag:_krImageViewerCancelButtonTag] removeFromSuperview];
        //移除 ActivityIndicator 相關的 View
        [[_targetView viewWithTag:_krImageViewerActivityBackgroundViewTag] removeFromSuperview];
    });
}

-(void)_startLoadingOnMainView
{
    [self _startLoadingWithView:self.view];
}

-(void)_stopLoadingOnMainView
{
    [self _stopLoadingWithView:self.view];
}

-(void)_startLoadingOnKRImageScrollView:(KRImageScrollView *)_targetView
{
    /*
     *  @ 是 PageByPage Loading 的模式
     *    - 就會直接針對 ActivityIndicator 設定 Tag，
     *      之後再直接針對 KRImageScrollView 取出該 Tag 後移除 ActivityIndicator。
     */
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if( [_targetView viewWithTag:_krImageViewerActivityBackgroundViewTag] )
        {
            return;
        }
        UIActivityIndicatorView *_loadingIndicator = [[UIActivityIndicatorView alloc]
                                                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_loadingIndicator setTag:_krImageViewerActivityBackgroundViewTag];
        //_loadingIndicator.center = CGPointMake(_targetView.bounds.size.width / 2.0f, _targetView.bounds.size.height / 2.0f);
        [self _resetIndicator:_loadingIndicator withFrame:_targetView.bounds];
        [_loadingIndicator setColor:[UIColor whiteColor]];
        [_loadingIndicator startAnimating];
        [_targetView addSubview:_loadingIndicator];
    });
}

//隱藏或顯示狀態列
-(void)_appearStatus:(BOOL)_isAppear
{
    //if( !self.statusBarHidden ) return;
    UIWindow *_mainWindow = [[UIApplication sharedApplication] keyWindow];
    if( !_isAppear )
    {
        if( _mainWindow )
        {
            UIView *_statusView =[[UIView alloc] initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
            [_statusView setBackgroundColor:[UIColor clearColor]];
            [_statusView setBackgroundColor:[UIColor blackColor]];
            [_statusView setTag:KR_STATUS_BAR_VIEW_TAG];
            [_mainWindow addSubview:_statusView];
            [_mainWindow sendSubviewToBack:_statusView];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    else
    {
        if( [_mainWindow viewWithTag:KR_STATUS_BAR_VIEW_TAG] )
        {
            [[_mainWindow viewWithTag:KR_STATUS_BAR_VIEW_TAG] removeFromSuperview];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    //self.statusBarHidden = !self.statusBarHidden;
}

-(NSInteger)_currentPage
{
    CGFloat pageWidth = self._scrollView.frame.size.width;
    return floor(self._scrollView.contentOffset.x / pageWidth) + 1;
}

-(NSInteger)_currentIndex
{
    CGFloat pageWidth = self._scrollView.frame.size.width;
    return floor((self._scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

-(void)_scrollToPage:(NSInteger)_toPage
{
    NSInteger _scrollToIndex = _toPage > 0 ? _toPage - 1 : 0;
    if( [self._scrollView.subviews count] > 0 )
    {
        //取出 subviews
        CGRect _scrollToFrame  = [[self._scrollView.subviews objectAtIndex:_scrollToIndex] frame];
        [self._scrollView scrollRectToVisible:_scrollToFrame animated:NO];
    }
}

/*
 *
 * @排序字典陣列，可設定是 ASC 或 DESC 排序
 *   _formatedDatas 的資料必須要將用作排序的值當成資料陣列的 Key 才行 : _formatedDatas[sortKey] = datas，
 *   也就是會預設以字典陣列裡的鍵值作為排序的準則。
 *   回傳的字典陣列裡，會有 2 個陣列值 :
 *   _temps["keys"]   = 所有排序過後的原始 Key 陣列集合
 *   _temps["values"] = 所有排序過後的原始 資料 陣列集合
 *
 */
-(NSDictionary *)_sortDictionary:(NSDictionary *)_formatedDatas ascending:(BOOL)_isAsc
{
    NSString *_keyName   = @"keys";
    NSString *_valueName = @"values";
    NSMutableDictionary *_temps = [NSMutableDictionary dictionaryWithCapacity:0];
    if( [_formatedDatas count] > 0 )
    {
        NSMutableArray *_keys   = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *_values = [[NSMutableArray alloc] initWithCapacity:0];
        //針對 Key 先做 ASC 排序
        NSMutableArray *_tempSorts = [NSMutableArray arrayWithCapacity:0];
        //要排序比對的儲存 Key
        NSString *_sortKey = @"id";
        for( NSString *_key in _formatedDatas )
        {
            //字串轉 Integer，非數字會回傳 0
            //NSInteger _keyOfInt = [_key integerValue];
            NSMutableDictionary *_sorts = [[NSMutableDictionary alloc] initWithCapacity:0];
            //如果 _key 是數字型態，就轉化成 NSNumber 物件儲存
            if( [self _isInt:_key] )
            {
                [_sorts setObject:[NSNumber numberWithInteger:[_key integerValue]] forKey:_sortKey];
            }
            else
            {
                [_sorts setObject:_key forKey:_sortKey];
            }
            [_tempSorts addObject:_sorts];
        }
        //設定排序規則，要以什麼「Key」為排序依據( 這裡設定取出陣列裡 Key 命名為 "id" 的值做排序 ), ascending ( ASC )
        NSSortDescriptor *_sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:_sortKey ascending:_isAsc];
        //依排序排則針對 _tempSorts 做排序的動作
        NSArray *_sorteds = [_tempSorts sortedArrayUsingDescriptors:[NSArray arrayWithObject:_sortDescriptor]];
        //依序取出內容值，放入 Keys 主鍵集合裡
        for( NSDictionary *_dicts in _sorteds )
        {
            [_keys addObject:[NSString stringWithFormat:@"%@", [_dicts objectForKey:_sortKey]]];
        }
        //依照排序好的 Keys 主鍵集合再依序取出所屬資料即完成整個排序動作
        for( NSString *_key in _keys )
        {
            //製作 UIPickerView 的資料
            [_values addObject:[_formatedDatas objectForKey:_key]];
        }
        [_temps setObject:_keys forKey:_keyName];
        [_temps setObject:_values forKey:_valueName];
    }
    return _temps;
}

//判斷是否為純整數
-(BOOL)_isInt:(NSString*)_string
{
    int _number;
    NSScanner *_scanner = [NSScanner scannerWithString:_string];
    return [_scanner scanInt:&_number] && [_scanner isAtEnd];
}

-(void)_refreshCaches
{
    [self _cancelAllOperations];
    [self _removeAllCaches];
}

//精靈消失效果
-(void)_disapperAsSuckEffect
{
	CATransition *transition = [CATransition animation];
	transition.delegate = self;
	transition.duration = self.durations;
	transition.type     = @"suckEffect";
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[[self.view layer] addAnimation:transition forKey:@"suckAnim"];
    [[self.view layer] display];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)_findOperationCacheMode
{
    return self.allowOperationCaching ? KRImageOperationAllowCache : KRImageOperationIgnoreCache;
}

-(void)_cancelAndClose:(id)sender
{
    self._isCancelled = YES;
    [self _cancelAllOperations];
    [self _stopLoadingOnMainView];
    [self _appearStatus:YES];
    [self _removeViewDragGesture];
    [self _removeAllViews];
    [self _moveView:self._gestureView toX:0.0f toY:0.0f];
    //[self _removeBrowser:sender];
}

-(UIButton *)_doneBrowserButton
{
    UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
    //[_button setFrame:CGRectMake(self._dragView.frame.size.width - 60.0f, 20.0f, 60.0f, 28.0f)];
    [self _resizeDoneButton:_button];
    [_button setTag:_krImageViewerBrowsingButtonTag];
    [_button setBackgroundColor:[UIColor clearColor]];
    [_button setBackgroundImage:[self _imageNameNoCache:@"btn_done.png"] forState:UIControlStateNormal];
    [_button setTitle:self.doneButtonTitle forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_button.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [_button addTarget:self action:@selector(_removeBrowser:) forControlEvents:UIControlEventTouchUpInside];
    return _button;
}

-(UIButton *)_cancelDownloadingButtonWithSuperFrame:(CGRect)_superFrame
{
    UIButton *_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[_closeButton setFrame:CGRectMake(_superFrame.size.width - 60.0f, [self _statusBarHeight], 60.0f, 28.0f)];
    [self _resizeCancelButton:_closeButton withSuperFrame:_superFrame];
    [_closeButton setTag:_krImageViewerCancelButtonTag];
    [_closeButton setBackgroundColor:[UIColor clearColor]];
    [_closeButton setBackgroundImage:[self _imageNameNoCache:@"btn_done.png"] forState:UIControlStateNormal];
    [_closeButton setTitle:@"取消" forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [_closeButton addTarget:self action:@selector(_cancelAndClose:) forControlEvents:UIControlEventTouchUpInside];
    return _closeButton;
}

-(UIImage *)_imageNameNoCache:(NSString *)_imageName
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], _imageName]];
}

/*
 * @ 從 image_id 找出 Scroll to Page Index
 */
-(NSString *)_findImageIndexWithId:(NSString *)_imageId
{
    NSInteger _index = 0;
    if( _imageId )
    {
        for( NSString *_key in self._sortedKeys )
        {
            if( [_key isEqualToString:_imageId] )
            {
                break;
            }
            ++_index;
        }
    }
    return [NSString stringWithFormat:@"%i", _index];
}

-(void)_loadImageWithPage:(NSInteger)_loadPage
{
    dispatch_queue_t queue = dispatch_queue_create("_loadImageWithPageQueue", NULL);
    dispatch_async(queue, ^(void) {
        NSInteger _loadIndex = _loadPage > 1 ? _loadPage - 1 : 0;
        //Fixed a Crash Bug by 2013.12.03 PM 23:36
        if( [self._sortedKeys count] < [self._imageInfos count] )
        {
            if( self.forceDisplays )
            {
                if( [self.forceDisplays count] > 0 )
                {
                    self._sortedKeys = self.forceDisplays;
                }
            }
            else
            {
                NSDictionary *_sortedURLs = [self _sortDictionary:self._imageInfos ascending:self.sortAsc];
                self._sortedKeys          = [NSMutableArray arrayWithArray:[_sortedURLs objectForKey:@"keys"]];
            }
        }
        if( _loadIndex > ( self._sortedKeys.count - 1 ) )
        {
            return;
        }
        //[self _firedBrowsingDelegate];
        [self _firedScrollingDelegate];
        //下載圖片
        NSString *_imageKey = [self._sortedKeys objectAtIndex:_loadIndex];
        NSString *_imageURL = [self._imageInfos objectForKey:_imageKey];
        self._operationQueues.maxConcurrentOperationCount = self.maxConcurrentOperationCount;
        NSArray *_subviews = [self._scrollView subviews];
        KRImageScrollView *_krImageScrollView = (KRImageScrollView *)[_subviews objectAtIndex:_loadIndex];
        //如果有快取就不理會
        if( [self._caches objectForKey:_imageKey] )
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                //NSLog(@"Had Cache %@", _imageKey);
                [_krImageScrollView resetImage:[self._caches objectForKey:_imageKey]];
            });
        }
        else
        {
            //NSLog(@"_imageURL : %@", _imageURL);
            //[self _startLoadingWithView:_krImageScrollView needCancelButton:NO];
            [self _startLoadingOnKRImageScrollView:_krImageScrollView];
            KRImageOperation *_op = [[KRImageOperation alloc] initWithImageURL:_imageURL];
            __weak KRImageOperation *_operation = _op;
            _operation.timeout   = self.timeout;
            _operation.cacheMode = [self _findOperationCacheMode];
            [_operation setCompletionBlock:^{
                //寫入快取
                if( _operation.doneImage )
                {
                    [self _addCacheImage:_operation.doneImage forKey:_imageKey];;
                    if( !self._isCancelled )
                    {
                        //顯示在該頁的 Subview 上
                        //NSLog(@"載好 %@ 的圖", _imageKey);
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [_krImageScrollView resetImage:[self._caches objectForKey:_imageKey]];
                        });
                        [self _stopLoadingWithView:_krImageScrollView];
                    }
                    _operation.doneImage = nil;
                }
            }];
            [_operationQueues addOperation:_operation];
        }
    });
    
}

-(void)_addDefaultImagesOnScrollView
{
    if( !_scrollView )
    {
        [self _setupScrollView];
    }
    [self _scrollViewRemoveAllSubviews];
    CGRect _innerFrame = CGRectMake(0.0f,
                                    0.0f,
                                    self._scrollView.frame.size.width,
                                    self._scrollView.frame.size.height);
    for( NSString *_imageKey in self._sortedKeys )
    {
        UIImage *_image = nil;
        //如果已有下載過的圖
        if( [self._caches objectForKey:_imageKey] )
        {
            _image = [self._caches objectForKey:_imageKey];
        }
        else
        {
            _image = [self _imageNameNoCache:@"ele_default_waiting_load.png"];
        }
        KRImageScrollView *_krImageScrollView = [[KRImageScrollView alloc] initWithFrame:_innerFrame];
        _krImageScrollView.maximumZoomScale = self.maximumZoomScale;
        _krImageScrollView.minimumZoomScale = self.minimumZoomScale;
        _krImageScrollView.zoomScale        = self.zoomScale;
        _krImageScrollView.clipsToBounds    = self.clipsToBounds;
        [_krImageScrollView displayImage:_image];
        [self._scrollView addSubview:_krImageScrollView];
        _innerFrame.origin.x += _innerFrame.size.width;
    }
    [self._scrollView setContentSize:CGSizeMake(_innerFrame.origin.x, _innerFrame.size.height)];
}

-(void)_firedBrowsingDelegate
{
    if( self.delegate )
    {
        if( [self.delegate respondsToSelector:@selector(krImageViewerIsBrowsingPage:)] )
        {
            [self.delegate krImageViewerIsBrowsingPage:self.scrollToPage];
        }
    }
    
    if( self.browsingHandler )
    {
        self.browsingHandler(self.scrollToPage);
    }
}

-(void)_firedScrollingDelegate
{
    if( self.delegate )
    {
        if( [self.delegate respondsToSelector:@selector(krImageViewerIsScrollingToPage:)] )
        {
            [self.delegate krImageViewerIsScrollingToPage:self.scrollToPage];
        }
    }
    
    if( self.scrollingHandler )
    {
        self.scrollingHandler(self.scrollToPage);
    }
}

#pragma --mark Resize
-(void)_resizeScrollViewWithFrame:(CGRect)_frame
{
    [self._scrollView setFrame:_frame];
    CGRect _innerFrame = CGRectMake(0.0f,
                                    0.0f,
                                    self._scrollView.frame.size.width,
                                    self._scrollView.frame.size.height);
    for( KRImageScrollView *_krImageScrollView in self._scrollView.subviews )
    {
        [_krImageScrollView resize:_innerFrame];
        _innerFrame.origin.x += _innerFrame.size.width;
    }
    [self._scrollView setContentSize:CGSizeMake(_innerFrame.origin.x, _innerFrame.size.height)];
    [self _scrollToPage:self.scrollToPage];
}

-(void)_resizeBackgroundViewWithFrame:(CGRect)_frame andTransform:(CGAffineTransform)_transform
{
    self._backgroundView.transform = _transform;
    self._backgroundView.bounds    = _frame;
}

-(void)_resizeDragViewWithFrame:(CGRect)_frame
{
    [self._dragView setFrame:_frame];
}

-(void)_resizeDoneButton:(UIButton *)_button
{
    [_button setFrame:CGRectMake(self._dragView.frame.size.width - 60.0f, 20.0f, 60.0f, 28.0f)];
}

-(void)_resizeCancelButton:(UIButton *)_button withSuperFrame:(CGRect)_superFrame
{
    [_button setFrame:CGRectMake(_superFrame.size.width - 60.0f, [self _statusBarHeight], 60.0f, 28.0f)];
}

-(void)_resetIndicatorWithSuperFrame:(CGRect)_superFrame
{
    //To Search UIActivityIndicator.
    //It is using PageByPage method.
    if( self._isOncePageToLoading )
    {
        for( KRImageScrollView *_krImageScrollView in self._scrollView.subviews )
        {
            UIActivityIndicatorView *_activityIndicator = (UIActivityIndicatorView *)[_krImageScrollView viewWithTag:_krImageViewerActivityBackgroundViewTag];
            if( _activityIndicator )
            {
                [self _resetIndicator:_activityIndicator withFrame:_superFrame];
            }
        }
    }
    else
    {
        //It is not using PageByPage method.
        UIActivityIndicatorView *_activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:_krImageViewerActivityIndicatorTag];
        if( _activityIndicator )
        {
            [self _resetIndicator:_activityIndicator withFrame:_superFrame];
        }
    }
}

-(void)_deviceDidRotate
{
    //NSLog(@"_deviceDidRotate");
    UIDeviceOrientation _deviceOrientation = [[UIDevice currentDevice] orientation];
    if( self._firstTimeSetting )
    {
        self._firstTimeSetting            = NO;
        self._initialInterfaceOrientation = _deviceOrientation;
        return;
    }
    [self reloadImagesWhenRotate:(UIInterfaceOrientation)_deviceOrientation];
}

@end


@implementation KRImageViewer

@synthesize _orignalPoints;
@synthesize _matchPoints;
@synthesize _panGestureRecognizer;
@synthesize _gestureView;
@synthesize _operationQueues;
@synthesize _backgroundView;
@synthesize _dragView;
@synthesize _scrollView;
@synthesize _caches;
@synthesize _sortedKeys;
@synthesize _imageInfos;
@synthesize _isCancelled;
@synthesize _isOncePageToLoading;
@synthesize _firstTimeSetting;
@synthesize _initialInterfaceOrientation;
//
@synthesize delegate = _delegate;
@synthesize view;
@synthesize dragMode;
@synthesize dragDisapperMode;
@synthesize allowOperationCaching;
@synthesize sideInstance;
@synthesize durations;
@synthesize maxConcurrentOperationCount;
@synthesize statusBarHidden;
@synthesize scrollToPage;
@synthesize maximumZoomScale;
@synthesize minimumZoomScale;
@synthesize zoomScale;
@synthesize clipsToBounds;
@synthesize timeout;
@synthesize interfaceOrientation;
@synthesize doneButtonTitle;
@synthesize supportsRotations = _supportsRotations;
@synthesize overCacheCountRelease;
@synthesize sortAsc;
@synthesize forceDisplays = _forceDisplays;

@synthesize browsingHandler  = _browsingHandler;
@synthesize scrollingHandler = _scrollingHandler;

+(instancetype)sharedManager
{
    static dispatch_once_t pred;
    static KRImageViewer *sharedManager = nil;
    dispatch_once(&pred, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(id)init
{
    self = [super init];
    if( self )
    {
        self.view     = nil;
        self.dragMode = krImageViewerModeOfTopToBottom;
        [self _initWithVars];
        [self _resetViewVars];
    }
    return self;
}

-(id)initWithParentView:(UIView *)_parentView dragMode:(krImageViewerModes)_dragMode
{
    self = [super init];
    if( self )
    {
        self.view     = _parentView;
        self.dragMode = _dragMode;
        [self _initWithVars];
        [self _resetViewVars];
        [self _allocPanGesture];
    }
    return self;
}

-(id)initWithDragMode:(krImageViewerModes)_dragMode
{
    self = [super init];
    if( self )
    {
        self.view     = nil;
        self.dragMode = _dragMode;
        [self _initWithVars];
        [self _resetViewVars];
        [self _allocPanGesture];
    }
    return self;
}

-(void)dealloc
{
    [self _removeAllCaches];
    [self _scrollViewRemoveAllSubviews];
}

#pragma My Methods
-(void)cancel
{
    [self _refreshCaches];
}

-(void)start
{
    self._isCancelled = NO;
    [self _appearStatus:NO];
    [self _addViewDragGesture];
    [self _browseImages];
}

-(void)stop
{
    [self _appearStatus:YES];
    [self _removeViewDragGesture];
    //[self _disapperAsSuckEffect];
    [self _removeAllViews];
    //回原點
    [self _moveView:self._gestureView toX:0.0f toY:0.0f];
    //回復黑色背景
    [self _renewBackgroundViewColorAndAlpha];
    [self _renewDragViewColorAndAlpha];
}

-(void)resetView:(UIView *)_parentView withDragMode:(krImageViewerModes)_dragMode
{
    self.view     = _parentView;
    self.dragMode = _dragMode;
    [self _resetViewVars];
}

-(void)resetView:(UIView *)_parentView
{
    [self resetView:_parentView withDragMode:self.dragMode];
}

-(void)useKeyWindow
{
    [self resetView:[UIApplication sharedApplication].keyWindow];
}

-(void)refresh
{
    [self _appearStatus:YES];
    [self _removeViewDragGesture];
    [self _removeAllViews];
    [self _initWithVars];
    [self _allocPanGesture];
    [self _refreshCaches];
}

-(void)pause
{
    self._isCancelled = YES;
    [self _appearStatus:YES];
    //暫停佇列處理
    [self._operationQueues setSuspended:YES];
}

-(void)restart
{
    self._isCancelled = NO;
    [self _appearStatus:NO];
    //繼續佇列處理
    [self._operationQueues setSuspended:NO];
}

-(void)preloadImageURLs:(NSDictionary *)_preloadImages
{
    self._isOncePageToLoading = NO;
    self._isCancelled         = NO;
    self._operationQueues.maxConcurrentOperationCount = 1;
    for( NSString *_imageKey in _preloadImages )
    {
        if( ![self._caches objectForKey:_imageKey] )
        {
            NSString *_url = [_preloadImages objectForKey:_imageKey];
            KRImageOperation *_op = [[KRImageOperation alloc] initWithImageURL:_url];
            __weak KRImageOperation *_operation = _op;
            _operation.timeout   = self.timeout;
            _operation.cacheMode = [self _findOperationCacheMode];
            [_operation setCompletionBlock:^{
                if( _operation.doneImage )
                {
                    [self _addCacheImage:_operation.doneImage forKey:_imageKey];;
                    _operation.doneImage = nil;
                }
                if( _operationQueues.operationCount == 0 )
                {
                    [self _resortKeys];
                }
            }];
            [_operationQueues addOperation:_operation];
        }
    }
}

-(void)browseAnImageURL:(NSString *)_imageURL
{
    self._isOncePageToLoading = NO;
    self._isCancelled         = NO;
    [self _downloadImageURLs:[NSDictionary dictionaryWithObject:_imageURL forKey:@"0"]];
}

-(void)browseImageURLs:(NSDictionary *)_browseURLs
{
    self._isOncePageToLoading = NO;
    self._isCancelled         = NO;
    self._operationQueues.maxConcurrentOperationCount = self.maxConcurrentOperationCount;
    [self _downloadImageURLs:_browseURLs];
}

-(void)browseImages:(NSArray *)_images
{
    self._isOncePageToLoading = NO;
    self._isCancelled         = NO;
    [self _removeAllCaches];
    NSInteger _index = 0;
    for( UIImage *_image in _images )
    {
        [self._caches setObject:_image forKey:[NSString stringWithFormat:@"%i", _index]];
        ++_index;
    }
    [self _resortKeys];
    [self start];
    [self _removeAllCaches];
}

-(void)browseImages:(NSArray *)_images startIndex:(NSInteger)_startIndex
{
    if( !_startIndex ) _startIndex = 0;
    self.scrollToPage = _startIndex;
    [self browseImages:_images];
}

-(void)findImageIndexWithId:(NSString *)_imageId
{
    self.scrollToPage = [[self _findImageIndexWithId:_imageId] integerValue];
}

-(void)findImageScrollPageWithId:(NSString *)_imageId
{
    self.scrollToPage = [[self _findImageIndexWithId:_imageId] integerValue] + 1;
}

/*
 * @ 瀏覽圖片，並設定要優先下載的圖片 ( 也就「一張一張 Load」的模式 )
 *   - 優先下載的圖片完成後，即可進行圖片瀏覽的動作。
 *   - 每次捲動至另一頁時，就下載該頁的圖。
 *   - 可考慮進行「當前頁面下載完成後，同時進行下載下一張圖與上一張圖片」之預載行為。
 *
 * @ 備註
 *   - 要注意，如在外部有使用過一次 forceDisplays，則後續又想新增圖片後並 Reload ImageViewer 的顯示圖片，
 *     就必須再重新設定一次 forceDisplays 才行，否則該新增的圖片會顯示失敗。
 */
-(void)browsePageByPageImageURLs:(NSDictionary *)_browseURLs firstShowImageId:(NSString *)_fireImageId
{
    [self _removeAllViews];
    self._isOncePageToLoading = YES;
    self._imageInfos  = [NSMutableDictionary dictionaryWithDictionary:_browseURLs];
    NSDictionary *_sortedURLs = [self _sortDictionary:_browseURLs ascending:YES];
    if( [self.forceDisplays count] > 0 )
    {
        self._sortedKeys  = [NSMutableArray arrayWithArray:self.forceDisplays];
    }
    else
    {
        self._sortedKeys  = [NSMutableArray arrayWithArray:[_sortedURLs objectForKey:@"keys"]];
    }
    [self findImageScrollPageWithId:_fireImageId];
    //NSArray *_values = [_sortedURLs objectForKey:@"values"];
    /*
     * @ 先一次性寫入所有的「預設圖片」
     */
    [self _addDefaultImagesOnScrollView];
    /*
     * @ 展示所有的「預設圖片」
     */
    self._isCancelled = NO;
    [self _appearStatus:NO];
    [self _addViewDragGesture];
    [self _scrollToPage:self.scrollToPage];
    [self._dragView addSubview:self._scrollView];
    //[self._dragView addSubview:[self _doneBrowserButton]];
    [self._backgroundView addSubview:self._dragView];
    [self.view addSubview:self._backgroundView];
    /*
     * @ 開始載入當前圖片
     */
    [self _cancelAllOperations];
    [self _loadImageWithPage:self.scrollToPage];
}

-(void)reloadImagesWhenRotate:(UIInterfaceOrientation)_toInterfaceOrientation
{
    self.interfaceOrientation = _toInterfaceOrientation;
    /*
     * @ 設計想法
     *   - 要旋轉的是除了 self.view 以外的所有 View ( UIView, UIScrollView, UIImageView, UIButton )，
     *     並且所有的 View frame 都要重新計算( resize )與排定座標( repoints )位置。
     */
    CGRect _frame   = self.view.frame;
    CGFloat _width  = _frame.size.width;
    CGFloat _height = _frame.size.height;
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
    switch ( _toInterfaceOrientation )
    {
        case UIInterfaceOrientationPortrait:
            //NSLog(@"轉成直立");
            //轉成直立
            _frame.size.width  = _width;
            _frame.size.height = _height;
            transform = CGAffineTransformMakeRotation(M_PI * 2);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            //NSLog(@"轉成倒立");
            //轉成倒立
            _frame.size.width  = _width;
            _frame.size.height = _height;
            transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            //NSLog(@"轉成左橫向");
            //轉成左橫向 ( Home 鍵在左 )
            _frame.size.width  = _height;
            _frame.size.height = _width;
            transform = CGAffineTransformMakeRotation(3.0 * M_PI / 2.0);
            break;
        case UIInterfaceOrientationLandscapeRight:
            //NSLog(@"轉右橫向");
            //轉成右橫向 ( Home 鍵在右 )
            _frame.size.width  = _height;
            _frame.size.height = _width;
            transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        default:
            //NSLog(@"預設轉成直立");
            //預設是轉成直立 ( 0 )
            _frame.size.width  = _width;
            _frame.size.height = _height;
            transform = CGAffineTransformMakeRotation(M_PI * 2);
            break;
    }
    [self _resizeBackgroundViewWithFrame:_frame andTransform:transform];
    [self _resetIndicatorWithSuperFrame:_frame];
    [self _resizeDragViewWithFrame:_frame];
    [self _resizeScrollViewWithFrame:_frame];
    [self _resetGestureView];
    [self _resizeDoneButton:(UIButton *)[self._dragView viewWithTag:_krImageViewerBrowsingButtonTag]];
    //[self _resizeCancelButton:(UIButton *)[self.view viewWithTag:_krImageViewerCancelButtonTag] withSuperFrame:_frame];
}

-(void)startWatchRotations
{
    self._firstTimeSetting = NO;
    self.supportsRotations = YES;
}

-(void)stopWatchRotations
{
    self._firstTimeSetting = NO;
    self.supportsRotations = NO;
}

-(void)stopWatchRotationsAndBackToInitialRotation
{
    [self stopWatchRotations];
    [self reloadImagesWhenRotate:self._initialInterfaceOrientation];
}

#pragma --mark Setters
-(void)setSupportsRotations:(BOOL)_toSupportsRotations
{
    _supportsRotations = _toSupportsRotations;
    if( _supportsRotations )
    {
        if( !self._firstTimeSetting )
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIDeviceOrientationDidChangeNotification
                                                          object:nil];
        }
        //NSLog(@"setSupportsRotations YES");
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_deviceDidRotate)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    else
    {
        //NSLog(@"setSupportsRotations NO");
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil];
    }
}

-(void)setBrowsingHandler:(KRImageViewerBrowsingHandler)_theBrowsingHandler
{
    _browsingHandler = _theBrowsingHandler;
}

-(void)setScrollingHandler:(KRImageViewerScrollingHandler)_theScrollingHandler
{
    _scrollingHandler = _theScrollingHandler;
}

#pragma UIScrollView Delegate
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

/*
 * @ 滾動完全停止
 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( self._isOncePageToLoading )
    {
        NSInteger _currentPage = [self _currentPage];
        if( self.scrollToPage == _currentPage )
        {
            return;
        }
        self.scrollToPage = _currentPage;
        //讀本張圖片
        //NSLog(@"_currentPage : %i", _currentPage);
        [self _loadImageWithPage:_currentPage];
    }
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)_subview
{
    
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

//縮放結束
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)_subview atScale:(float)scale
{
    
}



@end
