#import "RNZoomUsBridgeEventEmitter.h"

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
  return @[@"SDKInitialized", @"meetingStarted", @"meetingJoined", @"meetingSetToHidden", @"meetingEnded", @"meetingStatusChanged", @"waitingRoomActive", @"meetingError"];
}

- (void)meetingErrored:(NSDictionary *)result
{
    if (hasListeners) {
        [self sendEventWithName:@"meetingError" body:result];
    }
}


- (void)meetingWaitingRoomIsActive:(NSDictionary *)result
{
    if (hasListeners) {
        [self sendEventWithName:@"waitingRoomActive" body:result];
    }
}

- (void)userSDKInitilized:(NSDictionary *)result
{
    if (hasListeners) {
        [self sendEventWithName:@"SDKInitialized" body:result];
    }
}

- (void)userStartedAMeeting:(NSDictionary *)result
{
    if (hasListeners) {
        [self sendEventWithName:@"meetingStarted" body:result];
    }
}

- (void)userJoinedAMeeting:(NSDictionary *)result {
    if (hasListeners) {
        [self sendEventWithName:@"meetingJoined" body:result];
    }
}

- (void)userToggledMeetingHidden:(BOOL)hidden
{
    if (hasListeners) {
        [self sendEventWithName:@"meetingSetToHidden" body:@{}];
    }
}

- (void)userEndedTheMeeting:(NSDictionary *)result
{
    if (hasListeners) {
        [self sendEventWithName:@"meetingEnded" body:result];
    }
}

@end
