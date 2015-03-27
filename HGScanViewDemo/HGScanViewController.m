//
//  HGScanViewController.m
//  HGScanViewDemo
//
//  Created by HamGuy on 3/16/15.
//  Copyright (c) 2015 HamGuy. All rights reserved.
//

#import "HGScanViewController.h"
#import "HGLocationView.h"

@interface HGScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession* captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) HGLocationView* boundingBox;
@property (nonatomic, strong) AVCaptureDevice* captureDevice;
@property (nonatomic, strong) AVCaptureMetadataOutput* dataOutput;
@property (nonatomic, strong) UIView* continerView;
@property (nonatomic, strong) NSArray* surpportedScanTypes;

@end

@implementation HGScanViewController

- (instancetype)initWithSupportedTypes:(NSArray *)surppottedTypes
{
    self = [super init];
    if (self) {
        if (surppottedTypes) {
            self.surpportedScanTypes = surppottedTypes;
        }else{
            
            self.surpportedScanTypes = @[AVMetadataObjectTypeQRCode];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Setter
-(void)setScanArea:(CGRect)scanArea{
    _scanArea = scanArea;
    self.continerView.frame = scanArea;
}

-(void)setFocusColor:(UIColor *)focusColor{
    _focusColor = focusColor;
    self.boundingBox.borderColor = _focusColor;
}

-(void)setFlashMode:(AVCaptureFlashMode)flashMode{
    if (_flashMode == flashMode) {
        return;
    }
    _flashMode = flashMode;
    [self.captureDevice setFlashMode:flashMode];
}

-(void)setSurpportedScanTypes:(NSArray *)surpportedScanTypes{
    if (_surpportedScanTypes == surpportedScanTypes) {
        return;
    }
    _surpportedScanTypes = surpportedScanTypes;
}


-(UIView *)continerView{
    if (_continerView == nil) {
        _continerView = [[UIView alloc] initWithFrame:self.scanArea];
        _continerView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_continerView];
        [self setUpMaskLayer];
    }
    return _continerView;
}

#pragma mark - Private
-(void)setUp{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
    if (input) {
        [session addInput:input];
    }else{
        NSLog(@"config capturedevice error = %@",error);
        return;
    }
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [session addOutput:output];
    output.metadataObjectTypes = self.surpportedScanTypes;
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.dataOutput = output;
    [self updateRectOfIntrest];
    self.captureSession = session;
    
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer.bounds = self.view.bounds;
    self.previewLayer.position =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    self.boundingBox = [[HGLocationView alloc] initWithFrame:self.continerView.bounds];
    self.boundingBox.backgroundColor = [UIColor clearColor];
    self.boundingBox.borderColor = self.focusColor ? : [UIColor redColor];
    [self.continerView addSubview:_boundingBox];
    self.boundingBox.hidden = YES;
}

-(void)setUpMaskLayer{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRect:self.scanArea];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor grayColor].CGColor;
    fillLayer.opacity = 0.5;
    [self.view.layer addSublayer:fillLayer];
}

-(void)updateRectOfIntrest{
    if (CGRectEqualToRect(CGRectZero, _scanArea)) {
        return;
    }
    CGSize size = self.view.bounds.size;
    CGRect rect = CGRectMake(self.scanArea.origin.y/size.height, self.scanArea.origin.x/size.width, self.scanArea.size.height/size.height, self.scanArea.size.width/size.width);
    self.dataOutput.rectOfInterest = rect;
}

#pragma mark - Public

-(void)switchFlashMode:(AVCaptureFlashMode)flashMode{
    self.flashMode = flashMode;
}

-(void)start{
    [self.captureSession startRunning];
    self.boundingBox.hidden = YES;
}

-(void)stop{
    [self.captureSession stopRunning];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *scanResult = nil;
    for (AVMetadataObject *metaData in metadataObjects) {
        if ([self.surpportedScanTypes containsObject:metaData.type]) {
             [self stop];
            // Transform the meta-data coordinates to screen coords
            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:metaData];
            // Update the frame on the _boundingBox view, and show it
            CGRect frame = transformed.bounds;
            _boundingBox.frame = frame;
            _boundingBox.hidden = NO;
            // Now convert the corners array into CGPoints in the coordinate system
            // of the bounding box itself
            NSArray *translatedCorners = [self translatePoints:transformed.corners fromView:self.view toView:_boundingBox];
            
            // Set the corners array
            _boundingBox.corners = translatedCorners;
            
            scanResult = [transformed stringValue];
           
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(scanViewController:didFinishedScanWithResult:)]) {
                [self.delegate scanViewController:self didFinishedScanWithResult:scanResult];
            }
            break;
        }
        
        
    }
}

- (NSArray *)translatePoints:(NSArray *)points fromView:(UIView *)fromView toView:(UIView *)toView {
    NSMutableArray *translatedPoints = [NSMutableArray new];
    
    // The points are provided in a dictionary with keys X and Y
    for (NSDictionary *point in points) {
        // Let's turn them into CGPoints
        CGPoint pointValue = CGPointMake([point[@"X"] floatValue], [point[@"Y"] floatValue]);
        // Now translate from one view to the other
        CGPoint translatedPoint = [fromView convertPoint:pointValue toView:toView];
        // Box them up and add to the array
        [translatedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
    }
    return [translatedPoints copy];
}
@end
