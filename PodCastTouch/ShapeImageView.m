
//
//  ShapeImageView.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 15..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "ShapeImageView.h"

@implementation ShapeImageView

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self updateLayer];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self updateLayer];
    
}
/*
- (CAShapeLayer*)shapeLayer
{
    CAShapeLayer *shapeLayer = (CAShapeLayer*)self.layer.mask;
    return shapeLayer;
}

- (void)removeBorderLayer
{
    CAShapeLayer *borderLayer = [self.layer valueForKey:BorderLayerKey];
    
}
 */

- (void)updateLayer
{
    if(CGSizeEqualToSize((self.bounds.size), CGSizeZero))
        return;
    
    CGFloat minimum = fminf(self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(
                          CGRectGetMidX(self.bounds) - minimum/2.0,
                                                                           CGRectGetMidY(self.bounds) - minimum/2.0,minimum,minimum)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    self.layer.mask = maskLayer;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"bounds"])
        [self updateLayer];
}

- (void)setup
{
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    if(!(self=[super initWithImage:image highlightedImage:highlightedImage]))
        return self;
    
    [self setup];
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    if(!(self=[super initWithImage:image]))
        return self;
    
    [self setup];
    
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"bounds"];
}
@end
