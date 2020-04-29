# react-native-zoom-us-bridge Common Errors
Various issues you might encounter while using this library.

## iOS Build issues
```
'/RNZoomUSBridgeExample/ios/Pods/ZoomSDK/MobileRTC.framework/MobileRTC' does not contain bitcode. You must rebuild it with bitcode enabled (Xcode setting ENABLE_BITCODE), obtain an updated library from the vendor, or disable bitcode for this target. file '/RNZoomUSBridgeExample/ios/Pods/ZoomSDK/MobileRTC.framework/MobileRTC' for architecture arm64
```
This is caused by bitcode being enabled in the project. Disable bitcode.
---


```
ld: '/RNZoomUsBirdge/ios/Pods/ZoomSDK/MobileRTC.framework/MobileRTC' does not contain bitcode. You must rebuild it with bitcode enabled (Xcode setting ENABLE_BITCODE), obtain an updated library from the vendor, or disable bitcode for this target. file '/RNZoomUsBirdge/ios/Pods/ZoomSDK/MobileRTC.framework/MobileRTC' for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```
This is caused by building for Actual Device with the x86_64/i386 SDK. Please make sure to use the non x86_64 SDK.
---


```
'MobileRTC/MobileRTC.h' file not found
```

This is caused by SDK not installed or not copied to the proper location.
---


```
Undefined symbol: _OBJC_CLASS_$_MobileRTC
Undefined symbol: _OBJC_CLASS_$_MobileRTCMeetingStartParam4WithoutLoginUser
Undefined symbol: _OBJC_CLASS_$_MobileRTCSDKInitContext
Undefined symbol: _kMeetingParam_MeetingNumber
Undefined symbol: _kMeetingParam_MeetingPassword
Undefined symbol: _kMeetingParam_Username
```
This is caused by building for Simulator using non X86_64 SDK


## Android Build issues
```
Manifest merger failed : uses-sdk:minSdkVersion 16 cannot be smaller than version 21 declared in library [:commonlib] /Users/jimji/Apps/RNLibs/testZoomBridge/android/commonlib/build/.transforms/fc29670577197af67b6687a185dbf7f7/AndroidManifest.xml as the library might be using APIs not available in 16
```
This is caused by not using the right android SDK version in your build.gradle file. Please make sure to update the versions accordingly.
---


```
A problem occurred evaluating project ':react-native-zoom-us-bridge'. Project with path ':commonlib' could not be found in project ':react-native-zoom-us-bridge'.
```
This is caused by commonlib and mobilertc not added to your `settings.gradle` please make sure to add that there.
---


```
Could not resolve project :commonlib.
```
This is caused by the zoom.us SDK not being copied into the android folder. Please make sure its copied properly.
---


```
Manifest merger failed : Attribute application@appComponentFactory value=(android.support.v4.app.CoreComponentFactory) from [com.android.support:support-compat:28.0.0] AndroidManifest.xml:22:18-91
```
This is caused by attempting to build for non-androidx build. You must update your build to androidx, the SDK does not support non-androidx builds.