#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNZoomUsBridgeEventEmitter : RCTEventEmitter <RCTBridgeModule>

- (void)userSDKInitilized:(NSDictionary *)result;
- (void)userStartedAMeeting:(NSDictionary *)result;
- (void)userJoinedAMeeting:(NSDictionary *)result;
- (void)meetingWaitingRoomIsActive:(NSDictionary *)result;
- (void)meetingErrored:(NSDictionary *)result;

- (void)userToggledMeetingHidden:(BOOL)hidden;

- (void)userEndedTheMeeting:(NSDictionary *)result;

@end

NS_ASSUME_NONNULL_END
