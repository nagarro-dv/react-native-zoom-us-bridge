#import <React/RCTBridgeModule.h>

#import <MobileRTC/MobileRTC.h>

@interface RNZoomUsBridge : NSObject <RCTBridgeModule, MobileRTCAuthDelegate, MobileRTCMeetingServiceDelegate>

@end
