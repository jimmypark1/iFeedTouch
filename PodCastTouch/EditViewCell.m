//
//  EditViewCell.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 14..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "EditViewCell.h"


@implementation EditViewCell

- (void)prepareForReuse
{
    for( UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }

}
@end
