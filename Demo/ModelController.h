//
//  ModelController.h
//  WLPageViewController
//
//  Created by Ling Wang on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLPageViewController.h"

@class DataViewController;

@interface ModelController : NSObject <WLPageViewControllerDataSource>
- (DataViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;
@end
