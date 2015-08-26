## Screen Shot

<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-1.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-2.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-3.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" /> &nbsp;
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-4.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" />

## How To Get Started

KRImageViewer could let you easy browse photos from the URLs, storage or folders. You can scroll to change page, pinching zooming, dragging and swiping to close, this viewer supports automatic rotation.

``` objective-c
#import "KRImageViewer.h"

@interface ViewController ()<KRImageViewerDelegate>

@property (nonatomic, strong) KRImageViewer *krImageViewer;

@end

@implementation ViewController

@synthesize krImageViewer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _krImageViewer = [[KRImageViewer alloc] initWithDragMode:krImageViewerModeOfBoth];
    _krImageViewer.delegate                    = self;
    _krImageViewer.maxConcurrentOperationCount = 1;
    _krImageViewer.dragDisapperMode            = krImageViewerDisapperAfterMiddle;
    _krImageViewer.allowOperationCaching       = NO;
    _krImageViewer.timeout                     = 30.0f;
    _krImageViewer.doneWording                 = @"DONE";
    _krImageViewer.cancelWording               = @"CANCEL";
    //Auto supports the rotations.
    _krImageViewer.supportsRotations           = YES;
    //It'll release caches when caches of image over than X photos, but it'll be holding current image to display on the viewer.
    _krImageViewer.overCacheCountRelease       = 200;
    //Sorting Rule, Default ASC is YES, DESC is NO.
    _krImageViewer.sortAsc                     = YES;
    
    //Since we need to download from URLs, hence maybe you will see "nothing" in some methods.
    [self preloads];
    
    [_krImageViewer setBrowsingHandler:^(NSInteger browsingPage)
    {
        //Current Browsing Page.
        //...Do Something.
    }];
    
    [_krImageViewer setScrollingHandler:^(NSInteger scrollingPage)
    {
        //Current Scrolling Page.
        //...Do Something.
    }];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //Recommends to use the keyWindow to show. ( It always be front. )
    [_krImageViewer useKeyWindow];
    
    //To set the superview at show ( You can setup this method with your custom view to be parent view to show ).
    //[_krImageViewer resetView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma Method Samples
-(void)preloads
{
    //To setup the Keys and URLs.
    NSDictionary *_downloads = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://farm9.staticflickr.com/8459/7945134514_e5a779ee5f_s.jpg", @"1",
                                @"http://farm9.staticflickr.com/8435/7944303392_a856d79802_s.jpg", @"2",
                                nil];
    //We suggest the to preload the Images.
    [_krImageViewer preloadImageURLs:_downloads];
}

-(void)followImageIdToFindScrollPage
{
    //To find the id '3' to setup default show up.
    [_krImageViewer findImageScrollPageWithId:@"2"];
}

-(IBAction)browsingPreloads:(id)sender
{
    _krImageViewer.scrollToPage = 2;
    [_krImageViewer start];
}

-(IBAction)browsingURLs:(id)sender
{
    NSDictionary *_downloads = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://farm9.staticflickr.com/8459/7945134514_e5a779ee5f_s.jpg", @"1",
                                @"http://farm9.staticflickr.com/8435/7944303392_a856d79802_s.jpg", @"2",
                                nil];
    
    //Another browsing method of the images.
    [_krImageViewer browseImageURLs:_downloads];
    
    //Or you can browse an image as you wanna watch.
    //[_krImageViewer browseOneImageURL:@"http://farm9.staticflickr.com/8449/7943919662_67f7345f8b_s.jpg"];
}

-(IBAction)browsingImages:(id)sender
{
    //Or you can browse UIImages.
    NSArray *_directWatchs = [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"image1.png"],
                              [UIImage imageNamed:@"image2.png"],
                              [UIImage imageNamed:@"image3.png"],
                              nil];
    [_krImageViewer browseImages:_directWatchs];
}

//Recommends to use this method.
-(IBAction)browsingImagesPageByPage:(id)sender
{
    //When you gonna scroll the ImageViewer, it will Page by Page to download the image and show it.
    NSDictionary *_downloads = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://farm9.staticflickr.com/8459/7945134514_e5a779ee5f_s.jpg", @"1",
                                @"http://farm9.staticflickr.com/8435/7944303392_a856d79802_s.jpg", @"2",
                                @"http://farm9.staticflickr.com/8449/7943919662_67f7345f8b_s.jpg", @"3",
                                nil];
    //Presents pictures in follow your displaying rules.
    _krImageViewer.forceDisplays = [NSMutableArray arrayWithObjects:@"3", @"1", @"2", nil];
    //Now, the firstShowImageId:@"2" will sort in last one and display it first.
    [_krImageViewer browsePageByPageImageURLs:_downloads startIn:@"2"];
}

-(IBAction)startWatchingRotationsByYourself:(id)sender
{
    [_krImageViewer startWatchRotations];
}

-(IBAction)stopWatchingRotations:(id)sender
{
    [_krImageViewer stopWatchRotations];
}

-(IBAction)stopWatchingRotationsAndBackToInitialOrientation:(id)sender
{
    [_krImageViewer toInitialRotation];
}

#pragma KRImageViewerDelegate
-(void)krImageViewerIsScrollingToPage:(NSInteger)_scrollingPage
{
    //The ImageViewer is Scrolling to which page and trigger here.
    //...
}

@end
```

## Version

V1.0.3.

## License

MIT.

## Updated Logs

V0.9.0 added a function to fit rotations. <br />
V0.9.1 fixed bugs. <br />
V0.9.5 fixed bugs. <br />
V0.9.6 fixed an issue and added a variable named " doneButtonTitle ". <br />
V0.9.7 fixed an issue and supported auto rotations. <br />
V1.0.0 fixed a bug and added a new variable named " overCacheCountRelease " to control the cache-memory. <br />
V1.0.1 fixed an iOS 7 memory bug and added 2 new variables named " sortAsc " and " forceDisplays ". <br />
V1.0.2 added 2 bloks function. <br />
V1.0.3 supported iOS 7+ and fixed bugs.
