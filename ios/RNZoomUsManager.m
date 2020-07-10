#import "RNZoomUsManager.h"
#import "RNZoomUsBridgeEventEmitter.h"
#import <MobileRTC/MobileRTC.h>

@interface RNZoomUsManager (){
    NSString* url;
}

@end
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
//[self onInitMeetingView];
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

- (void)joinMeeting:(NSString *)meetingId userName:(NSString *)userName password:(NSString *)password meetingUrl:(NSString *)meetingUrl completion:(void (^_Nonnull)(NSUInteger resultCode))completion {
  NSLog(@"joinMeeting called on native module");
    
  MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
//  [[MobileRTC sharedRTC] getMeetingSettings].enableCustomMeeting = YES;

  if (ms) {
    ms.delegate = self;
      url = meetingUrl;
    NSDictionary *paramDict = @{
    kMeetingParam_Username: userName,
    kMeetingParam_MeetingNumber: meetingId,
    kMeetingParam_MeetingPassword: password ? password : @"",
    };

    MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithDictionary:paramDict];
    NSLog(@"joinMeeting, joinMeetingResult=%d", joinMeetingResult);
    completion(1);
  }
}

- (void)onWaitingRoomStatusChange:(BOOL)needWaiting
{
   NSLog(@"onWaitingRoomStatusChange, needWaiting=%d", needWaiting);
    if (needWaiting) {
        // waiting room not supported lets leave meeting
        RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
        [emitter meetingWaitingRoomIsActive:@{}];
        [self leaveMeeting];
    }
}

- (void)leaveMeeting {
  MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
  if (!ms) return;
  [ms leaveMeetingWithCmd:LeaveMeetingCmd_Leave];
  RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
  [emitter userEndedTheMeeting:@{}];
}

- (void)onMeetingStateChange:(MobileRTCMeetingState)state {
  NSLog(@"onMeetingStatusChanged, meetingState=%d", state);

  if (state == MobileRTCMeetingState_InMeeting) {
      RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
      [emitter userJoinedAMeeting:@{}];
//      [self onInitMeetingView];
      double delayInSeconds = 5.0;
      dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
      dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      //code to be executed on the main queue after delay
      [self onInitMeetingView];
//     [self doSometingWithObject:obj1 andAnotherObject:obj2];
      });
  }
}

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue {
    NSLog(@"SDK LOG - Auth Returned %d", returnValue);

    NSDictionary *resultDict = returnValue == MobileRTCMeetError_Success ? @{} : @{@"error": @"start_error"};

    RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
    [emitter userSDKInitilized:resultDict];
    [[[MobileRTC sharedRTC] getAuthService] setDelegate:self];
    if (returnValue != MobileRTCAuthError_Success)
    {
        NSLog(@"SDK LOG - Auth Error'd %d", returnValue);
    }
}

- (void)onMeetingReturn:(MobileRTCMeetError)errorCode internalError:(NSInteger)internalErrorCode {
  NSLog(@"onMeetingReturn, error=%d, internalErrorCode=%zd", errorCode, internalErrorCode);

  if (errorCode != MobileRTCMeetError_Success) {
    RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
    [emitter meetingErrored:@{}];
  }

}

- (void)onMeetingError:(MobileRTCMeetError)errorCode message:(NSString *)message {
  NSLog(@"onMeetingError, errorCode=%d, message=%@", errorCode, message);
if (errorCode != MobileRTCMeetError_Success) {
    RNZoomUsBridgeEventEmitter *emitter = [RNZoomUsBridgeEventEmitter allocWithZone: nil];
    [emitter meetingErrored:@{}];
}
}

- (void)onInitMeetingView {
  // Create & Present View Controller
  NSLog(@"onInitMeetingView....");

    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    UIView *v = [ms meetingView];
        
//    if (@available(iOS 11.0, *)) {
//        UIWebView *sv = [[UIWebView alloc] initWithFrame:CGRectMake(0, v.safeAreaInsets.top -  65, v.frame.size.width, v.frame.size.height -  v.safeAreaInsets.top - v.safeAreaInsets.bottom - 120)];
//        [sv loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString: url]]];
//        sv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
//        sv.backgroundColor = [UIColor clearColor];
//        [sv setOpaque:NO];
//        sv.alpha = 1;
////        //    sv.UIScrollView = [UICollectionLayoutSectionOrthogonalScrollingBehavior false]
//        [v addSubview:sv];
//    } else {
    
    
    UIWebView *sv = [[UIWebView alloc] initWithFrame:CGRectMake(0, 65, v.frame.size.width, v.frame.size.height - 120)];
    [sv loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString: url]]];
    sv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    sv.backgroundColor = [UIColor clearColor];
    [sv setOpaque:NO];
    sv.alpha = 1;
//        sv.UIScrollView = [UICollectionLayoutSectionOrthogonalScrollingBehavior false]
  
    
    
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leading = [NSLayoutConstraint
    constraintWithItem:v attribute:NSLayoutAttributeLeft
    relatedBy:NSLayoutRelationEqual toItem:sv attribute:
    NSLayoutAttributeLeft multiplier:1.0 constant:65];
    /* Top space to superview Y*/
    NSLayoutConstraint *top = [NSLayoutConstraint
    constraintWithItem:v attribute:NSLayoutAttributeTop
    relatedBy:NSLayoutRelationEqual toItem:sv attribute:
    NSLayoutAttributeTop multiplier:1.0f constant:20];

    NSLayoutConstraint *trailing = [NSLayoutConstraint
    constraintWithItem:v attribute:NSLayoutAttributeRight
    relatedBy:NSLayoutRelationEqual toItem:sv attribute:
    NSLayoutAttributeTop multiplier:1.0f constant:20];

    NSLayoutConstraint *bottom = [NSLayoutConstraint
    constraintWithItem:v attribute:NSLayoutAttributeBottom
    relatedBy:NSLayoutRelationEqual toItem:sv attribute:
    NSLayoutAttributeTop multiplier:1.0f constant:55];

    [sv addConstraints:@[leading, top, trailing, bottom]];
      [v addSubview:sv];
    
    
//    if (@available(iOS 11, *)) {
//        UILayoutGuide * guide = v.safeAreaLayoutGuide;
//
//
//
//        NSLayoutConstraint *leftButtonXConstraint = [NSLayoutConstraint
//         constraintWithItem:v.safeAreaLayoutGuide.topAnchor attribute:NSLayoutAttributeLeft
//        relatedBy:NSLayoutRelationEqual toItem:self attribute:
//        NSLayoutAttributeLeft multiplier:1.0 constant: 65];
//        /* Top space to superview Y*/
//        NSLayoutConstraint *leftButtonYConstraint = [NSLayoutConstraint
//         constraintWithItem:v.safeAreaLayoutGuide.bottomAnchor attribute:NSLayoutAttributeTop
//         relatedBy:NSLayoutRelationEqual toItem:self attribute:
//         NSLayoutAttributeTop multiplier:1.0f constant: 55];
//
////        UIWebView *sv = [[UIWebView alloc] initWithFrame:CGRectMake(0, leftButtonXConstraint , v.frame.size.width, (v.frame.size.height - leftButtonYConstraint))];
////        [sv loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString: url]]];
////        sv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
////        sv.backgroundColor = [UIColor clearColor];
////        [sv setOpaque:NO];
////        sv.alpha = 1;
//        [v addSubview:sv];
//    }
//

        
    
//        [sv.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
//        [sv.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES;
//        [sv.topAnchor constraintEqualToAnchor:(guide.topAnchor + 65)].active = YES;
//        [sv.bottomAnchor constraintEqualToAnchor:(guide.bottomAnchor - 55)].active = YES;
//    }
//    else {
//        UILayoutGuide *margins = v.layoutMarginsGuide;
//        [sv.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor].active = YES;
//        [sv.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor].active = YES;
//        [sv.topAnchor constraintEqualToAnchor: v.topLayoutGuide.bottomAnchor].active = YES;
//        [sv.bottomAnchor constraintEqualToAnchor: v.bottomLayoutGuide.topAnchor].active = YES;

//    }
    
        // Fallback on earlier versions
//    }
}


- (void)onDestroyMeetingView
{
  // Remove & Dismiss View Controller
  NSLog(@"onDestroyMeetingView....");

    
//  [self.customMeetingVC willMoveToParentViewController:nil];
//  [self.customMeetingVC.view removeFromSuperview];
//  [self.customMeetingVC removeFromParentViewController];
//  self.customMeetingVC = nil;
}


@end
