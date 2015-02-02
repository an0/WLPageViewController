//
//  DataViewController.m
//  WLPageViewController
//
//  Created by Ling Wang on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataViewController.h"

@implementation DataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.title = [self.dataObject description];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
    NSLog(@"%@ viewWillAppear", self.dataObject);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ viewDidAppear", self.dataObject);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@ viewWillDisappear", self.dataObject);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%@ viewDidDisappear", self.dataObject);
}

@end
