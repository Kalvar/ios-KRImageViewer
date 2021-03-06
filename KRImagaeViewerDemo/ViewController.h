//
//  ViewController.h
//  KRImagaeViewerDemo
//
//  Created by Kalvar on 12/10/21.
//  Copyright (c) 2012 - 2015 年 Kuo-Ming Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KRImageViewer;

@interface ViewController : UIViewController

@property (nonatomic, strong) KRImageViewer *krImageViewer;

-(IBAction)browsingPreloads:(id)sender;
-(IBAction)browsingURLs:(id)sender;
-(IBAction)browsingImages:(id)sender;
-(IBAction)browsingImagesPageByPage:(id)sender;
-(IBAction)startWatchingRotationsByYourself:(id)sender;
-(IBAction)stopWatchingRotations:(id)sender;
-(IBAction)stopWatchingRotationsAndBackToInitialOrientation:(id)sender;


@end
