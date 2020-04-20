//
//  ModernHealthEventEmitter.m
//  modernHealthPocRN61
//
//  Created by Brian Thomas on 4/9/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RNZoomUSBridgeEventEmitter.h"

@implementation RNZoomUsBridgeEventEmitter
{
  bool hasListeners;
}

+ (id)allocWithZone:(NSZone *)zone {
  static RNZoomUsBridgeEventEmitter *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      sharedInstance = [super allocWithZone:zone];
  });
  return sharedInstance;
}

- (void)startObserving {
    hasListeners = YES;
}

- (void)stopObserving {
    hasListeners = NO;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"SDKInitialized", @"meetingStarted", @"meetingJoined", @"meetingSetToHidden", @"meetingEnded", @"meetingStatusChanged"];
}

- (void)userSDKInitilized:(NSDictionary *)result
{
  [self sendEventWithName:@"SDKInitialized" body:result];
}

- (void)userStartedAMeeting:(NSDictionary *)result
{
  [self sendEventWithName:@"meetingStarted" body:result];
}

- (void)userJoinedAMeeting:(NSDictionary *)result {
  [self sendEventWithName:@"meetingJoined" body:result];
}

- (void)userToggledMeetingHidden:(BOOL)hidden
{
  [self sendEventWithName:@"meetingSetToHidden" body:@{}];
}

- (void)userEndedTheMeeting:(NSDictionary *)result
{
  [self sendEventWithName:@"meetingEnded" body:result];
}

@end
