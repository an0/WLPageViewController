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
}

@end
