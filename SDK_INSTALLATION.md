# react-native-zoom-us-bridge Zoom.us SDK Installation

## iOS installation using POD

To use pod you will need to activate lfs for your git cli.

**tl;dr git lfs is used to store large files, zoom.us iOS SDK is huge.
**
[read more about git lfs](https://help.github.com/en/github/managing-large-files/installing-git-large-file-storage)

Activate lfs by using homebrew `brew install git-lfs`

Make sure this is added to your Podfile `pod 'ZoomDEVSDK', :git => 'https://github.com/mokriya-org/zoom-us-ios-sdk-dev-pod.git'`

`pod install` from ios folder.

### Optional, using production Zoom.us SDK
`ZoomDEVSDK` can not be used for release build. Apple Will reject your App. You must use this Pod instead. However, this pod file does not work with simulators.

`pod 'ZoomSDK', :git => 'https://github.com/mokriya-org/zoom-us-ios-sdk-pod.git'`

## iOS installation via manual download
[Download zoom.us iOS SDK at](https://github.com/zoom/zoom-sdk-ios)
[Follow this guide to integrate the SDK](https://marketplace.zoom.us/docs/sdk/native-sdks/iOS/getting-started/integration)

## Android installation via manual download
Sorry, there are no semi-auto way to install the Android SDK at the moment. It must be done 100% manually.
[Download zoom.us Android SDK at](https://github.com/zoom/zoom-sdk-android)
[Follow this guide to integrate the SDK](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started/integration)


[After SDK has been installed, proceed with SDK account setup](SDK_ACCOUNT_SETUP.md)