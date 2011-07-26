//
//  DetailViewController.m
//  NestedModalView
//
//  Created by Wang Ling on 5/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DetailViewController.h"


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end



@implementation DetailViewController

@synthesize toolbar, popoverController, detailItem, detailDescriptionLabel, depth;


#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
	
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}


- (void)configureView {
    // Update the user interface for the detail item.
    detailDescriptionLabel.text = [detailItem description];   
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (WLSplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    NSLog(@"willHideViewController");
    barButtonItem.title = @"Root List";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (WLSplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    NSLog(@"willShowViewController");
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	NSLog(@"d%d: will rotate", depth);
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	NSLog(@"d%d: did rotate", depth);
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}



#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"d%d: viewDidLoad", depth);
    [super viewDidLoad];
	if (depth > 0) {
		self.detailItem = [NSString stringWithFormat:@"Modal %d", depth];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"d%d: viewWillAppear", depth);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"d%d: viewDidAppear", depth);
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"d%d: viewWillDisapper", depth);
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	NSLog(@"d%d: viewDidDisappear", depth);
    [super viewDidDisappear:animated];
}


- (void)viewDidUnload {
	NSLog(@"d%d: viewDidUnload", depth);
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Button actions

- (IBAction)showModal {
	
	DetailViewController *modalViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
	modalViewController.depth = depth + 1;
	if (depth == 0) {
		modalViewController.modalPresentationStyle = UIModalPresentationFullScreen;
		[self presentModalViewController:modalViewController animated:YES];
	} else {
		modalViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
		[self presentModalViewController:modalViewController animated:YES];
	}
}

- (IBAction)dismissModal {
	[self dismissModalViewControllerAnimated:YES];
}

@end
