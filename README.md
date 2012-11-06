## Screen Shot

<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-1.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" />
。
<img src="https://dl.dropbox.com/u/83663874/GitHubs/KRImageViewer-2.png" alt="KRImageViewer" title="KRImageViewer" style="margin: 20px;" class="center" />

## Supports

KRImageViewer supports MRC ( Manual Reference Counting ), if you did want it support to ARC, that just use Xode tool to auto convert to ARC. ( Xcode > Edit > Refactor > Convert to Objective-C ARC )

## How To Get Started

KRImageViewer which you can browsing photos from the URLs, UIImages. That you can scroll it to change pages, pinching for zooming, and you can close the viewer with touch and drag move it or swipe it to. 

``` objective-c
- (void)viewDidLoad
{
    krImageViewer = [[KRImageViewer alloc] initWithDragMode:krImageViewerModeOfTopToBottom];
    krImageViewer.allowOperationCaching = YES;
    [self preloads];    
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.krImageViewer resetView:self.view.window];
    [super viewDidAppear:animated];
}

#pragma Method Samples
-(void)preloads{
    //To setup the Keys and URLs.
    NSDictionary *_downloads = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://farm9.staticflickr.com/8459/7945134514_e5a779ee5f_s.jpg", @"1",
                                @"http://farm9.staticflickr.com/8435/7944303392_a856d79802_s.jpg", @"2",
                                @"http://farm9.staticflickr.com/8449/7943919662_67f7345f8b_s.jpg", @"3",
                                nil];
    //We suggest the to preload the Images.
    [self.krImageViewer preloadImageURLs:_downloads];
}

-(IBAction)browsingPreloads:(id)sender{
    self.krImageViewer.maxConcurrentOperationCount = 1;
    self.krImageViewer.dragDisapperMode = krImageViewerDisapperAfterMiddle;
    self.krImageViewer.scrollToPage     = 2;
    [self.krImageViewer start];
}

-(IBAction)browsingURLs:(id)sender{
    NSDictionary *_downloads = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://farm9.staticflickr.com/8459/7945134514_e5a779ee5f_s.jpg", @"1",
                                @"http://farm9.staticflickr.com/8435/7944303392_a856d79802_s.jpg", @"2",
                                @"http://farm9.staticflickr.com/8449/7943919662_67f7345f8b_s.jpg", @"3",
                                nil];
    
    //Another browsing method of the images.
    [self.krImageViewer browseImageURLs:_downloads];
    
    //Or you can browse an image as you wanna watch.
    [self.krImageViewer browseAnImageURL:@"http://farm9.staticflickr.com/8449/7943919662_67f7345f8b_s.jpg"];
}

-(IBAction)browsingImages:(id)sender{
    //Or you can browse UIImages.
    NSArray *_directWatchs = [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"image1.jpg"],
                              [UIImage imageNamed:@"image2.jpg"],
                              [UIImage imageNamed:@"image3.jpg"],
                              [UIImage imageNamed:@"image4.jpg"],
                              [UIImage imageNamed:@"image5.jpg"],
                              nil];
    [self.krImageViewer browseImages:_directWatchs];
}
```

## Version

KRImageViewer now is V0.6 beta.

## License

KRImageViewer is available under the MIT license ( or Whatever you wanna do ). See the LICENSE file for more info.

## Others

KRImageViewer to offer a browser of images, It'll be liking the iOS Facebook Image Viewer in the future one day.