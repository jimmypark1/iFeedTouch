//
//  ShapeImageView.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 15..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapeImageView : UIImageView

@property (nonatomic) UIBezierPath *shape;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;

@end
