//
//  CircleCellView.m
//  BLEReceiver
//
//  Created by Peter Brock on 07/04/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "CircleCellView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CircleCellView

- (void)layoutSubviews {

    [super layoutSubviews];
    [self layoutIfNeeded];
    self.layer.cornerRadius = self.frame.size.width/2;
}

@end
