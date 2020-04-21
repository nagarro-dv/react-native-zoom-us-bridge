//
//  WaitingViewController.m
//  modernHealthPocRN61
//
//  Created by Brian Thomas on 4/7/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "WaitingViewController.h"
#import "RNZoomUsManager.h"

@interface WaitingViewController ()

@end

@implementation WaitingViewController

- (void)endTapped:(id)sender {
  // bail out of the join process or cache that we need to immediately quit after joining
  [[RNZoomUsManager sharedInstance] leaveMeeting];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  typeof(self) __weak weakSelf = self;
  [[ZoomMeetingManager sharedInstance] onWaitingRoomStatusUpdated:^(BOOL isWaiting) {
    [[weakSelf statusLabel] setText: isWaiting ? @"Waiting for the host to approve..." : @"Connecting..."];
  }];
}

@end
