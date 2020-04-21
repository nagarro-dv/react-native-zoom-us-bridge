//
//  WaitingViewController.h
//  modernHealthPocRN61
//
//  Created by Brian Thomas on 4/7/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WaitingViewController : UIViewController

@property (nonatomic, assign) BOOL isHidden;

@property (nonatomic, weak) IBOutlet UILabel *waitingLabel;

- (IBAction)endTapped:(id)sender;

@end

NS_ASSUME_NONNULL_END
