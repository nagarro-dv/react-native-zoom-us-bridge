#import "RNZoomUsManager.h"
#import "RNZoomUsBridge.h"
#import "RNZoomUsBridgeEventEmitter.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

typedef enum {
  MobileRTCSampleTokenType_Token,
  MobileRTCSampleTokenType_ZAK,
} MobileRTCSampleTokenType;

@implementation RNZoomUsBridge
{
  BOOL isInitialized;
  RCTPromiseResolveBlock initializePromiseResolve;
  RCTPromiseRejectBlock initializePromiseReject;
  RCTPromiseResolveBlock meetingPromiseResolve;
  RCTPromiseRejectBlock meetingPromiseReject;
}

static RNZoomUsBridgeEventEmitter *internalEmitter = nil;

- (instancetype)init {
  if (self = [super init]) {
    isInitialized = NO;
    initializePromiseResolve = nil;
    initializePromiseReject = nil;
    meetingPromiseResolve = nil;
    meetingPromiseReject = nil;
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(
  initialize: (NSString *)appKey
  withAppSecret: (NSString *)appSecret
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  if (isInitialized) {
    resolve(@"Already initialize Zoom SDK successfully.");
    return;
  }

  isInitialized = true;

  @try {
    initializePromiseResolve = resolve;
    initializePromiseReject = reject;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      [[RNZoomUsManager sharedInstance] authenticate:appKey appSecret:appSecret completion:^(NSUInteger resultCode) {
        resolve(@{});
      }];
    }];

  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing initialize", ex);
  }
}

RCT_EXPORT_METHOD(
                  startMeeting:(NSString *)meetingNumber
                  userName:(NSString *)userName
                  userId:(NSString *)userId
                  userZak:(NSString *)userZak
                  withResolve: (RCTPromiseResolveBlock)resolve
                  withReject: (RCTPromiseRejectBlock)reject
)
{
  @try {
    meetingPromiseResolve = resolve;
    meetingPromiseReject = reject;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      [[RNZoomUsManager sharedInstance] startMeeting:meetingNumber userName:userName userId:userId userZak:userZak completion:^(NSUInteger resultCode) {
        if (resultCode == 0) {
          resolve(@{ @"result": @"success" });
        } else {
          resolve(@{ @"result": @"error" });
        }
      }];
    }];
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing startMeeting", ex);
  }
}

RCT_EXPORT_METHOD(
  joinMeeting:(NSString *)meetingNumber
  userName:(NSString *)userName
  password:(NSString *)password
  withResolve: (RCTPromiseResolveBlock)resolve
  withReject: (RCTPromiseRejectBlock)reject
)
{
  @try {
    meetingPromiseResolve = resolve;
    meetingPromiseReject = reject;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      [[RNZoomUsManager sharedInstance] joinMeeting:meetingNumber userName:userName password:password completion:^(NSUInteger resultCode) {
        resolve(@{});
      }];
    }];
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing joinMeeting", ex);
  }
}

RCT_EXPORT_METHOD(createJWT: (NSString *)jwtApiKey
                  withApiSecret: (NSString *)jwtApiSecret
                  withResolve: (RCTPromiseResolveBlock)resolve
                  withReject: (RCTPromiseRejectBlock)reject
) {
  @try {
    NSString *accessToken = [self createJWTAccessToken: jwtApiKey withApisecret: jwtApiSecret];
    NSLog(@"createJWT token success @%@", accessToken);
    resolve(accessToken);
  } @catch (NSError *ex) {
      reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing createJWT", ex);
    NSLog(@"ERR_UNEXPECTED_EXCEPTION @%@", ex);
  }

}

/*
 * Request User Token Or ZAK Via Rest API
 * Rest API(List User): https://api.zoom.us/v2/users
 */

- (NSString *)dictionaryToJson:(NSMutableDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData == nil)
    {
        return nil;
    }
    else
    {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

- (NSString *)base64Encode:(NSString*)decodeString
{
    NSData *encodeData = [decodeString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:0];

    NSMutableString *mutStr = [NSMutableString stringWithString:base64String];
    NSRange range = {0,base64String.length};
    [mutStr replaceOccurrencesOfString:@"=" withString:@"" options:NSLiteralSearch range:range];

    return mutStr;
}

/*
 * Hmac AlgSHA256 Encryption.
 */
- (NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString * hash = [HMAC base64Encoding];
    return hash;
}

/*
 * Create JSON Web Tokens (JWT) for Authentication.
 * Guide Link: https://zoom.github.io/api/#authentication
 */
- (NSString *)createJWTAccessToken:(NSString *)apikey withApisecret:(NSString *)apisecret
{

  NSMutableDictionary *dictHeader = [NSMutableDictionary dictionary];
  [dictHeader setValue:@"HS256" forKey:@"alg"];
  [dictHeader setValue:@"JWT" forKey:@"typ"];
  NSString *base64Header = [self base64Encode:[self dictionaryToJson:dictHeader]];

  //    {
  //        "iss": "API_KEY",
  //        "exp": 1496091964000
  //    }
  NSMutableDictionary *dictPayload = [NSMutableDictionary dictionary];
  [dictPayload setValue:apikey forKey:@"iss"];
  [dictPayload setValue:@"123456789101" forKey:@"exp"];
  NSString *base64Payload = [self base64Encode:[self dictionaryToJson:dictPayload]];

  NSString *composer = [NSString stringWithFormat:@"%@.%@",base64Header,base64Payload];
  NSString *hashmac = [self hmac:composer withKey:apisecret];

  NSString *accesstoken = [NSString stringWithFormat:@"%@.%@.%@",base64Header,base64Payload,hashmac];
    NSLog(@"createJWTAccessToken, accesstoken=%@", accesstoken);
  return accesstoken;
}

@end
