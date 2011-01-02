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
#import "ContentController.h"

@implementation WLContainerControllersAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	ContentController *aViewController = [[ContentController alloc] initWithNibName:@"AViewController" bundle:nil];
	aViewController.title = @"Seg A";
//	aViewController.view.backgroundColor = [UIColor redColor];
	ContentController *bViewController = [[ContentController alloc] initWithNibName:@"BViewController" bundle:nil];
	bViewController.title = @"Seg B";
//	bViewController.view.backgroundColor = [UIColor blueColor];
	
//	WLSwitchController *switchController = [[WLSwitchController alloc] init];
//	switchController.viewControllers = [NSArray arrayWithObjects:aViewController, bViewController, nil];
//	[navigationController pushViewController:switchController animated:NO];
//	[switchController release];

	WLSplitViewController *splitViewController = [[WLSplitViewController alloc] init];
	splitViewController.showsSplitLine = NO;
	splitViewController.delegate = self;
	splitViewController.viewControllers = [NSArray arrayWithObjects:aViewController, bViewController, nil];
	[navigationController pushViewController:splitViewController animated:NO];
	[splitViewController release];

	[aViewController release];
	[bViewController release];

    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
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

