//
//  ViewController.m
//  HGScanViewDemo
//
//  Created by HamGuy on 3/16/15.
//  Copyright (c) 2015 HamGuy. All rights reserved.
//

#import "ViewController.h"
#import "HGScanViewController.h"

@interface ViewController ()<HGScanViewControllerDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) HGScanViewController* scanController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startItem;

@end

@implementation ViewController  

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *drugTypes = @[AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeQRCode];
//    NSArray *types = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    _scanController = [[HGScanViewController alloc] initWithSupportedTypes:drugTypes];
    _scanController.focusColor = [UIColor blueColor];
    _scanController.scanArea = CGRectMake((self.view.bounds.size.width-300)/2, 100, 300, 100);
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
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:scanResult delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alerView show];
    NSLog(@"result is : %@",scanResult);
}
- (IBAction)wantStart:(id)sender {
    [self.scanController start];
    self.startItem.enabled = NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.startItem.enabled = YES;
}
@end
