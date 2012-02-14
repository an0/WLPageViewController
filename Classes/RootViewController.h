//
//  RootViewController.h
//  WLPageViewController
//
//  Created by Ling Wang on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLPageViewController.h"

@interface RootViewController : UIViewController <WLPageViewControllerDelegate>

@property (strong, nonatomic) WLPageViewController *pageViewController;

@end
