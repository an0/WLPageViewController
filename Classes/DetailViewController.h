//
//  DetailViewController.h
//  NestedModalView
//
//  Created by Wang Ling on 5/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLSplitViewController.h"

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, WLSplitViewControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    id detailItem;
    UILabel *detailDescriptionLabel;
	
	NSUInteger depth;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, assign) NSUInteger depth;

- (IBAction)showModal;
- (IBAction)dismissModal;

@end
