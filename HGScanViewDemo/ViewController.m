//
//  ViewController.m
//  HGScanViewDemo
//
//  Created by HamGuy on 3/16/15.
//  Copyright (c) 2015 HamGuy. All rights reserved.
//

#import "ViewController.h"
#import "HGScanViewController.h"

@interface ViewController ()<HGScanViewControllerDelegate>

@property (nonatomic, strong) HGScanViewController* scanController;

@end

@implementation ViewController  

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scanController = [[HGScanViewController alloc] init];
    _scanController.focusColor = [UIColor blueColor];
    _scanController.scanArea = CGRectMake((self.view.bounds.size.width-200)/2, 100, 200, 200);
    _scanController.delegate = self;
    [self.view addSubview:_scanController.view];
    [self addChildViewController:_scanController];
    [_scanController didMoveToParentViewController:self];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.scanController start];
}

#pragma mark - HGScanViewControllerDelegate
-(void)scanViewController:(HGScanViewController *)controller didFinishedScanWithResult:(NSString *)scanResult{
    NSLog(@"result is : %@",scanResult);
}

@end
