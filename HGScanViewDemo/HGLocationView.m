//
//  HGLocationView.m
//
//  Created by HamGuy on 11/14/14.
//  Copyright (c) 2014 DXY.CN. All rights reserved.
//

#import "HGLocationView.h"

@interface HGLocationView ()

@property (nonatomic, strong) CAShapeLayer *outline;

@end

@implementation HGLocationView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _outline = [CAShapeLayer new];
        _outline.strokeColor = [[[UIColor greenColor] colorWithAlphaComponent:0.8] CGColor];
        _outline.lineWidth = 1.0;
        _outline.fillColor = [[UIColor clearColor] CGColor];
        [self.layer addSublayer:_outline];
    }
    return self;
}

- (void)setCorners:(NSArray *)corners {
    if (corners != _corners) {
        _corners = corners;
        _outline.path = [[self cratePathFromPoints:corners] CGPath];
    }
}

-(void)setLineWidth:(CGFloat)lineWidth{
    if (_lineWidth == lineWidth) {
        return;
    }
    _lineWidth = lineWidth;
    _outline.lineWidth = lineWidth;
}

-(void)setBorderColor:(UIColor *)borderColor{
    if (_borderColor == borderColor) {
        return;
    }
    _borderColor = borderColor;
    _outline.strokeColor = [borderColor CGColor];
}

- (UIBezierPath *)cratePathFromPoints:(NSArray *)points {
    UIBezierPath *path = [UIBezierPath new];
    // Start at the first corner
    [path moveToPoint:[[points firstObject] CGPointValue]];
    
    // Now draw lines around the corners
    for (NSUInteger i = 1; i < points.count; i++) {
        [path addLineToPoint:[points[i] CGPointValue]];
    }
    
    // And join it back to the first corner
    [path addLineToPoint:[[points firstObject] CGPointValue]];
    
    return path;
}


@end
