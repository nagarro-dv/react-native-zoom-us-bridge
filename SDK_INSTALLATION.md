# react-native-zoom-us-bridge Zoom.us SDK Installation

## iOS installation using POD

To use pod you will need to activate lfs for your git cli.

**tl;dr git lfs is used to store large files, zoom.us iOS SDK is huge.
**
[read more about git lfs](https://help.github.com/en/github/managing-large-files/installing-git-large-file-storage)

Activate lfs by using homebrew `brew install git-lfs`

Make sure this is added to your Podfile `pod 'ZoomSDK', :git => 'https://github.com/mokriya-org/zoom-us-ios-sdk-dev-pod.git'`

`pod install` from ios folder.

### Optional, using production Zoom.us SDK
`pod 'ZoomSDK', :git => 'https://github.com/mokriya-org/zoom-us-ios-sdk-dev-pod.git'` can not be used for release build. Apple Will reject your App. You must use this Pod instead. However, this pod file does not work with simulators.

`pod 'ZoomSDK', :git => 'https://github.com/mokriya-org/zoom-us-ios-sdk-pod.git'`

## iOS SDK installation via manual download
[Download zoom.us iOS SDK at](https://github.com/zoom/zoom-sdk-ios)

1. Open the downloaded zip file and locate the `lib` folder
2. Open project workspace, drag the `lib` folder to the project (ios_image1)
3. Make sure to check `copy if needed` (ios_image2)
4. Rename folder to `ZoomSDK` double check by looking up the folder in finder or terminal. (ios_image3, 4)
5. On Xcode Open ZoomSDK folder, find MobileRTC.framework, drag it to General -> Frameworks, Libraries... make sure its set to `Embed & Sign` (ios_image5)
6. Verify the `ZoomSDK` folder is in `Build Phases`, `Copy Bundle Resources`, if not, drag the folder in there (ios_image6)


or [Follow this orignal guide to integrate the SDK](https://marketplace.zoom.us/docs/sdk/native-sdks/iOS/getting-started/integration)

## iOS manual step required add permissions to info.plist
```javascript
<key>NSCameraUsageDescription</key>
<string>we need your camera</string>
<key>NSMicrophoneUsageDescription</key>
<string>we need your mic</string>
```

## Android installation via manual download
Sorry, there are no semi-auto way to install the Android SDK at the moment. It must be done 100% manually.
[Download zoom.us Android SDK at](https://github.com/zoom/zoom-sdk-android)

1. Open the downloaded zip file and locate `mobilertc-android-studio` folder which contains commonlib and mobilertc
2. Select both and drag into your project/android folder (android_image1, 2)
3. Open `android/settings.gradle` add `, ':mobilertc', ':commonlib'` to `include ':app'` (android_image3)
4. Open `android/build.gradle` and update your sdk versions to match the following
   ```javascript
   buildToolsVersion = "29.0.0"
        minSdkVersion = 21
        compileSdkVersion = 29
        targetSdkVersion = 28
        ``` (android_image4)
5. Open `android/app/build.gradle` and add `multiDexEnabled true` to `defaultConfig` (android_image5)


[Follow this guide to integrate the SDK](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started/integration)


[After SDK has been installed, proceed with SDK account setup](SDK_ACCOUNT_SETUP.md)