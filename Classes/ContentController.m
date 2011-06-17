//
//  ContentVController.m
//  WLContainerController
//
//  Created by Wang Ling on 7/16/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "ContentController.h"


@implementation ContentController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	DLog(@"%@ viewDidLoad", self.title);
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"%@ viewWillAppear:%d", self.title, animated);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"%@ viewDidAppear:%d", self.title, animated);
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"%@ viewWillDisapper:%d", self.title, animated);
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	NSLog(@"%@ viewDidDisappear:%d", self.title, animated);
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	NSLog(@"%@ will rotate", self.title);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	NSLog(@"%@ did rotate", self.title);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
