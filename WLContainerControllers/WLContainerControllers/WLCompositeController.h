//  Created by Ling Wang on 1/31/15.
//  Copyright (c) 2015 I Wonder Phone. All rights reserved.

#import <UIKit/UIKit.h>

@interface WLCompositeController : UIViewController

@property(nonatomic, copy) NSArray<__kindof UIViewController *> *viewControllers;
@property(nonatomic, readonly) UIView *contentView;

#pragma mark - Protected

- (void)layoutContentView;

@end
