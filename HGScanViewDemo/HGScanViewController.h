//
//  HGScanViewController.h
//  HGScanViewDemo
//
//  Created by HamGuy on 3/16/15.
//  Copyright (c) 2015 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@protocol HGScanViewControllerDelegate;

@interface HGScanViewController : UIViewController

@property (nonatomic, strong) UIColor* focusColor;
@property (nonatomic, assign) CGRect scanArea;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign) CGFloat foucusLineHeight;

@property (nonatomic, weak) id<HGScanViewControllerDelegate> delegate;

- (instancetype)initWithSupportedTypes:(NSArray *)surppottedTypes;

-(void)switchFlashMode:(AVCaptureFlashMode)flashMode;

-(void)start;
-(void)stop;

@end

@protocol HGScanViewControllerDelegate <NSObject>

-(void)scanViewController:(HGScanViewController *)controller didFinishedScanWithResult:(NSString *)scanResult;

@end