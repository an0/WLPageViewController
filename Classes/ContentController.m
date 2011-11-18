//
//  ContentVController.m
//  WLContainerController
//
//  Created by Wang Ling on 7/16/10.
//  Copyright 2010 I Wonder Phone. All rights reserved.
//

#import "ContentController.h"
#import "UIColor+WLExtension.h"

@implementation ContentController

@synthesize vavigationController = _vavigationController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	DLog(@"%@ viewDidLoad", self.title);
	self.view.backgroundColor = [UIColor randomColor];
	UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewIsTapped:)];
	self.view.gestureRecognizers = [NSArray arrayWithObject:tapGR];
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)viewIsTapped:(UITapGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		CGPoint point = [recognizer locationInView:recognizer.view];
		if (point.y >= recognizer.view.center.y) {
			// Push.
			ContentController *viewController = [[ContentController alloc] init];
			[self.vavigationController pushViewController:viewController animated:YES];
		} else {
			// Pop.
			[self.vavigationController popViewControllerAnimated:YES];
		}
	}
}


@end
