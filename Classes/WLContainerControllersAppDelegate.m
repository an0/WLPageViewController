//
//  WLContainerControllersAppDelegate.m
//  WLContainerControllers
//
//  Created by Wang Ling on 7/16/10.
//  Copyright I Wonder Phone 2010. All rights reserved.
//

#import "WLContainerControllersAppDelegate.h"
#import "WLSwitchController.h"
#import "WLSplitViewController.h"
#import "WLTabBarController.h"
#import "ContentController.h"
#import "MasterViewController.h"
#import "DetailViewController.h"

@implementation WLContainerControllersAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	ContentController *aViewController = [[ContentController alloc] initWithNibName:@"AViewController" bundle:nil];
	aViewController.title = @"Seg A";
	aViewController.view.backgroundColor = [UIColor redColor];
	ContentController *bViewController = [[ContentController alloc] initWithNibName:@"BViewController" bundle:nil];
	bViewController.title = @"Seg B";
	bViewController.view.backgroundColor = [UIColor blueColor];		

//	WLSwitchController *switchController = [[WLSwitchController alloc] init];
//	switchController.viewControllers = [NSArray arrayWithObjects:aViewController, bViewController, nil];
//	[navigationController pushViewController:switchController animated:NO];

	WLTabBarController *tabBarController = [[WLTabBarController alloc] init];
	tabBarController.viewControllers = [NSArray arrayWithObjects:aViewController, bViewController, nil];
	
//	MasterViewController *masterViewController = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain];	
//	DetailViewController *detailViewController = [[DetailViewController alloc] init];
//	WLSplitViewController *splitViewController = [[WLSplitViewController alloc] init];
//	splitViewController.showsSplitLine = NO;
//	splitViewController.delegate = self;
//	splitViewController.viewControllers = [NSArray arrayWithObjects:masterViewController, detailViewController, nil];
//	[navigationController pushViewController:splitViewController animated:NO];

    window.rootViewController = tabBarController;
    [window makeKeyAndVisible];

    return YES;
}



#pragma mark -
#pragma mark WLSplitViewControllerDelegate methods

- (void)splitViewController:(WLSplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {
	DLog(@"popover");
}

- (void)splitViewController:(WLSplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
	DLog(@"willHideViewController");
	barButtonItem.title = @"Master";
	navigationController.topViewController.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(WLSplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
	DLog(@"willShowViewController");
	navigationController.topViewController.navigationItem.leftBarButtonItem = nil;	
}

@end

