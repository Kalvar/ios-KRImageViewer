//
//  KRImageScrollView.m
//
//  ilovekalvar@gmail.com
//
//  Created by Kuo-Ming Lin on 2012/11/07.
//  Copyright (c) 2012年 Kuo-Ming Lin. All rights reserved.
//

#import "KRImageScrollView.h"

@interface KRImageScrollView(){
    UIImageView *_imageView;
}

@property (nonatomic, strong) UIImageView *_imageView;
@property (nonatomic, assign) BOOL _didZoom;
@property (nonatomic, assign) BOOL _hideStatusBar;

@end

@interface KRImageScrollView (fixPrivate)

-(void)_initWithSettings;
-(void)_addGestures;
-(CGRect)_zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

@implementation KRImageScrollView (fixPrivate)

-(void)_initWithSettings{
    //Default Settings
    self.delegate         = self;
    self.backgroundColor  = [UIColor clearColor];
    self.contentMode      = UIViewContentModeCenter;
    self.maximumZoomScale = 2.0f;
    self.minimumZoomScale = 1.0f;
    self.zoomScale        = 2.2f;
    self.clipsToBounds    = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator   = NO;
    self._didZoom = NO;
    self.tapScale = KR_ZOOM_TAP;
    self._hideStatusBar = ![UIApplication sharedApplication].statusBarHidden;
}

-(void)_addGestures
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    //UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    //[twoFingerTap setNumberOfTouchesRequired:2];
    
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:doubleTap];
    //單擊跟雙擊共存的關鍵在這一行，如果雙擊確定偵測失敗才會觸發單擊
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    //[self._imageView addGestureRecognizer:twoFingerTap];
}

-(CGRect)_zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

@end

@implementation KRImageScrollView
@synthesize _imageView;
@synthesize _didZoom;
@synthesize _hideStatusBar;
@synthesize tapScale;

-(id)init{
    self = [super init];
    if( self ){
        [self _initWithSettings];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initWithSettings];
        [self _addGestures];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)dealloc{
    //NSLog(@"KRImageScrollView Dealloc");
    self._imageView.image = nil;
}

#pragma My Methods
-(void)displayImage:(UIImage *)_subImage
{
    if( _imageView ){
        [_imageView removeFromSuperview];
        self._imageView.image = nil;
        self._imageView       = nil;
    }
    _imageView = [[UIImageView alloc] initWithImage:_subImage];
    self._imageView.contentMode = UIViewContentModeScaleAspectFit; //UIViewContentModeScaleToFill;
    [self._imageView setFrame:CGRectMake(0.0f,
                                         0.0f,
                                         self.frame.size.width,
                                         self.frame.size.height)];
    [self addSubview:self._imageView];
}


//#error 這裡會一直被 reset ... 要想個方法增進效能
-(void)resetImage:(UIImage *)_subImage
{
    self._imageView.image = nil;
    [self._imageView setImage:_subImage];
}

#pragma mark TapDetectingImageViewDelegate methods
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if( gestureRecognizer.state == UIGestureRecognizerStateEnded )
    {
        UIWindow *_mainWindow = [[UIApplication sharedApplication] keyWindow];
        if( self._hideStatusBar ){
            if( _mainWindow ){
                UIView *_statusView =[[UIView alloc] initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
                [_statusView setBackgroundColor:[UIColor clearColor]];
                [_statusView setBackgroundColor:[UIColor redColor]];
                [_statusView setTag:KR_STATUS_BAR_VIEW_TAG];
                [_mainWindow addSubview:_statusView];
                [_mainWindow sendSubviewToBack:_statusView];
            }
        }else{
            if( [_mainWindow viewWithTag:KR_STATUS_BAR_VIEW_TAG] ){
                [[_mainWindow viewWithTag:KR_STATUS_BAR_VIEW_TAG] removeFromSuperview];
            }
        }
        [[UIApplication sharedApplication] setStatusBarHidden:self._hideStatusBar withAnimation:UIStatusBarAnimationSlide];
        self._hideStatusBar = !self._hideStatusBar;
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    //Double tap zooms in
    CGFloat _newScale = 1.0f;
    if( !self._didZoom ){
        _newScale = [self zoomScale] * self.tapScale;
    }
    self._didZoom = !self._didZoom;
    CGRect _zoomRect = [self _zoomRectForScale:_newScale
                                    withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self zoomToRect:_zoomRect animated:YES];
}

//-(void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer{
//    // two-finger tap zooms out
//    CGRect zoomRect = [self _zoomRectForScale:[self zoomScale] / ZOOM_TAP
//                                   withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
//    [self zoomToRect:zoomRect animated:YES];
//}

#pragma UIScrollView Delegate
-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)_subview{
    self.pagingEnabled = NO;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self._imageView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)_subview atScale:(float)scale{
    [scrollView setZoomScale:scale+0.01f animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

@end
