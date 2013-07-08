## Screen Shot

<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-1.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-2.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-3.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-4.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" />

## Supports

KRImageViewer supports ARC.

## How To Get Started

KRImageViewer which you can browsing photos from the URLs, UIImages. That you can scroll it to change pages, pinching for zooming, and you can close the viewer with touch and drag move it or swipe it to. 

``` objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];
    krImageViewer = [[KRImageViewer alloc] initWithDragMode:krImageViewerModeOfBotn];
    self.krImageViewer.maxConcurrentOperationCount = 1;
    self.krImageViewer.dragDisapperMode            = krImageViewerDisapperAfterMiddle;
    self.krImageViewer.allowOperationCaching       = NO;
    self.krImageViewer.timeout                     = 30.0f;
    self.krImageViewer.doneButtonTitle             = @"DONE";
    [self preloads];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //To use the keyWindow to show. ( It always be front. )
    [self.krImageViewer useKeyWindow];
    //To set the superview at show.
    //[self.krImageViewer resetView:self.view.window];
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
    //Here to reload the KRImageViewer rotation.
    [self.krImageViewer reloadImagesWhenRotate:toInterfaceOrientation];
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
```

## Version

KRImageViewer now is V0.9.5 beta.

## License

KRImageViewer is available under the MIT license ( or Whatever you wanna do ). See the LICENSE file for more info.

## Updated Logs

V0.9 added a function to fit rotations. <br />
V0.9.1 fixed bugs.
V0.9.5 fixed bugs.

## Others

KRImageViewer to offer a browser of images, It'll be liking the iOS Facebook Image Viewer in the future one day.