//
//  ViewController.m
//  KRImagaeViewerDemo
//
//  Created by Kalvar on 12/10/21.
//  Copyright (c) 2012年 Kuo-Ming Lin. All rights reserved.
//

#import "ViewController.h"
#import "KRImageViewer.h"

@interface ViewController ()<KRImageViewerDelegate>

@end

@implementation ViewController

@synthesize krImageViewer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    krImageViewer = [[KRImageViewer alloc] initWithDragMode:krImageViewerModeOfBoth];
    self.krImageViewer.delegate                    = self;
    self.krImageViewer.maxConcurrentOperationCount = 1;
    self.krImageViewer.dragDisapperMode            = krImageViewerDisapperAfterMiddle;
    self.krImageViewer.allowOperationCaching       = NO;
    self.krImageViewer.timeout                     = 30.0f;
    self.krImageViewer.doneButtonTitle             = @"DONE";
    //Auto supports the rotations.
    self.krImageViewer.supportsRotations           = YES;
    //It'll release caches when caches of image over than X photos, but it'll be holding current image to display on the viewer.
    self.krImageViewer.overCacheCountRelease       = 200;
    [self preloads];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //To use the keyWindow to show. ( It always be front. )
    [self.krImageViewer useKeyWindow];
    //To set the superview at show ( You can setup this method with your custom view to be parent view to show ).
    //[self.krImageViewer resetView:self.myCustomCellView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

/*
 * @ 允許旋轉
 */
-(BOOL)shouldAutorotate
{
    return YES;
}

/*
 * @ 允許的旋轉方向
 */
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

/*
 * @ 將要旋轉成什麼方向
 */
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    /*
     * @ If you didn't set the " self.krImageViewer.supportsRotation = YES " to auto supporting the rotations, 
     *   then you can using this method to do the rotation by yourself.
     */
    //Here to reload the KRImageViewer rotation.
    //[self.krImageViewer reloadImagesWhenRotate:toInterfaceOrientation];
}

/*
 * @ 從哪個方向旋轉成現在的樣子
 */
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //NSLog(@"fromInterfaceOrientation : %i", fromInterfaceOrientation);
}

#pragma Method Samples
-(void)preloads
{
    //To setup the Keys and URLs.
    NSDictionary *_downloads = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://farm9.staticflickr.com/8459/7945134514_e5a779ee5f_s.jpg", @"1",
                                @"http://farm9.staticflickr.com/8435/7944303392_a856d79802_s.jpg", @"2",
                                @"http://farm9.staticflickr.com/8449/7943919662_67f7345f8b_s.jpg", @"3",
                                nil];
    //We suggest the to preload the Images.
    [self.krImageViewer preloadImageURLs:_downloads];
}

-(void)followImageIdToFindScrollPage
{
    //To find the id '3' to setup default show up.
    [self.krImageViewer findImageScrollPageWithId:@"3"];
}

-(IBAction)browsingPreloads:(id)sender
{
    self.krImageViewer.scrollToPage = 2;
    [self.krImageViewer start];
}

-(IBAction)browsingURLs:(id)sender
{
    NSDictionary *_downloads = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://farm9.staticflickr.com/8459/7945134514_e5a779ee5f_s.jpg", @"1",
                                @"http://farm9.staticflickr.com/8435/7944303392_a856d79802_s.jpg", @"2",
                                @"http://farm9.staticflickr.com/8449/7943919662_67f7345f8b_s.jpg", @"3",
                                nil];
    
    //Another browsing method of the images.
    [self.krImageViewer browseImageURLs:_downloads];
    
    //Or you can browse an image as you wanna watch.
    //[self.krImageViewer browseAnImageURL:@"http://farm9.staticflickr.com/8449/7943919662_67f7345f8b_s.jpg"];
}

-(IBAction)browsingImages:(id)sender
{
    //Or you can browse UIImages.
    NSArray *_directWatchs = [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"image1.png"],
                              [UIImage imageNamed:@"image2.png"],
                              [UIImage imageNamed:@"image3.png"],
                              nil];
    [self.krImageViewer browseImages:_directWatchs];
}

-(IBAction)browsingImagesPageByPage:(id)sender
{
    //When you gonna scroll the ImageViewer, it will Page by Page to download the image and show it.
    NSDictionary *_downloads = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://farm9.staticflickr.com/8459/7945134514_e5a779ee5f_s.jpg", @"1",
                                @"http://farm9.staticflickr.com/8435/7944303392_a856d79802_s.jpg", @"2",
                                @"http://farm9.staticflickr.com/8449/7943919662_67f7345f8b_s.jpg", @"3",
                                nil];
    [self.krImageViewer browsePageByPageImageURLs:_downloads firstShowImageId:@"2"];
}

-(IBAction)startWatchingRotationsByYourself:(id)sender
{
    [self.krImageViewer startWatchRotations];
}

-(IBAction)stopWatchingRotations:(id)sender
{
    [self.krImageViewer stopWatchRotations];
}

-(IBAction)stopWatchingRotationsAndBackToInitialOrientation:(id)sender
{
    [self.krImageViewer stopWatchRotationsAndBackToInitialRotation];
}

#pragma KRImageViewerDelegate
-(void)krImageViewerIsScrollingToPage:(NSInteger)_scrollingPage
{
    //The ImageViewer is Scrolling to which page and trigger here.
    //...
}

@end
