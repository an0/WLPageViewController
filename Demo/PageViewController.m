//
//  PageViewController.m
//  WLPageViewController
//
//  Created by Ling Wang on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PageViewController.h"

#import "ModelController.h"

#import "DataViewController.h"

@interface PageViewController ()
@property (readonly, strong, nonatomic) ModelController *modelController;
@end

@implementation PageViewController

@synthesize modelController = _modelController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Configure the page view controller and add it as a child view controller.
	DataViewController *startingViewController = [self.modelController viewControllerAtIndex:0];
	self.pageViewController = [[WLPageViewController alloc] initWithViewController:startingViewController pageSpacing:80];
//	self.pageViewController.enableTapPageTurning = YES;
	self.pageViewController.dataSource = self.modelController;
	self.pageViewController.delegate = self;

	[self addChildViewController:self.pageViewController];
	[self.view addSubview:self.pageViewController.view];

	// Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
	CGRect pageViewRect = self.view.bounds;
	self.pageViewController.view.frame = pageViewRect;

	[self.pageViewController didMoveToParentViewController:self];    

	// Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
//	self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (ModelController *)modelController
{
    /*
     Return the model controller object, creating it if necessary.
     In more complex implementations, the model controller may be passed to the view controller.
     */
    if (!_modelController) {
        _modelController = [[ModelController alloc] init];
    }
    return _modelController;
}


@end
