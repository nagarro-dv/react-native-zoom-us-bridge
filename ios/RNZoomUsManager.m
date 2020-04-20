#import "RNZoomUsManager.h"
#import "RNZoomUsBridgeEventEmitter.h"
#import <MobileRTC/MobileRTC.h>

static RNZoomUsManager *sharedInstance = nil;

@implementation RNZoomUsManager

NSString *const kSDKDomain = @"zoom.us";

static RNZoomUsBridgeEventEmitter *internalEmitter = nil;

+ (RNZoomUsManager *)sharedInstance {
  if (sharedInstance == nil) {
    sharedInstance = [[super allocWithZone:NULL] init];
  }
  
  return sharedInstance;
}

- (void)authenticate: (NSString *)appKey appSecret:(NSString *)appSecret completion:(void (^_Nonnull)(NSUInteger resultCode))completion{
  
  MobileRTCSDKInitContext *context = [MobileRTCSDKInitContext new];
  [context setDomain:kSDKDomain];
  [context setEnableLog:NO];
  [[MobileRTC sharedRTC] initialize:context];

  MobileRTCAuthService *authService = [[MobileRTC sharedRTC] getAuthService];
  if (authService) {
    NSLog(@"SDK LOG - Auth Requested");
    authService.delegate = self;
    authService.clientKey = appKey;
    authService.clientSecret = appSecret;
    [authService sdkAuth];
    completion(1);
  }
  
}

- (void)startMeeting:(NSString *)meetingId userName:(NSString *)userName userId:(NSString *)userId userZak:(NSString *)userZak completion:(void (^_Nonnull)(NSUInteger resultCode))completion {
  
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        ms.delegate = self;

        MobileRTCMeetingStartParam4WithoutLoginUser * params = [[MobileRTCMeetingStartParam4WithoutLoginUser alloc]init];
        params.userName = userName;
        params.meetingNumber = meetingId;
        params.userID = userId;
        params.userType = MobileRTCUserType_APIUser;
        params.zak = userZak;
        params.userToken = @"null";

        MobileRTCMeetError startMeetingResult = [ms startMeetingWithStartParam:params];
        NSLog(@"startMeeting, startMeetingResult=%d", startMeetingResult);
        completion(1);
    }
}

- (void)joinMeeting:(NSString *)meetingId userName:(NSString *)userName password:(NSString *)password completion:(void (^_Nonnull)(NSUInteger resultCode))completion {
  NSLog(@"joinMeeting called on native module");
    
  MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
  if (ms) {
    ms.delegate = self;

    NSDictionary *paramDict = @{
    kMeetingParam_Username: userName,
    kMeetingParam_MeetingNumber: meetingId,
    kMeetingParam_MeetingPassword: password ? password : @""
    };

    MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithDictionary:paramDict];
    NSLog(@"joinMeeting, joinMeetingResult=%d", joinMeetingResult);
    completion(1);
  }
}

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue {
  NSLog(@"SDK LOG - Auth Returned %d", returnValue);
  RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
  
  NSDictionary *resultDict = returnValue == MobileRTCMeetError_Success ? @{} : @{@"error": @"start_error"};
  [emitter userSDKInitilized:resultDict];

  [[[MobileRTC sharedRTC] getAuthService] setDelegate:self];

  if (returnValue != MobileRTCAuthError_Success)
  {
    NSLog(@"SDK LOG - Auth Error'd %d", returnValue);
  }
}

@end
