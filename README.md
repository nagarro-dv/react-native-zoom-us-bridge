# react-native-zoom-us-bridge
This library bridges React Native with zoom.us SDK. This library uses the zoom.us SDK authentication process. You might have a zoom developer account to use this library. User login using zoom user accounts is not implemented.

## Getting started

`$ npm install react-native-zoom-us-bridge --save`

or

`yarn add react-native-zoom-us-bridge`

### Mostly automatic installation

RN 60 >= auto link

RN 60 <
`$ react-native link react-native-zoom-us-bridge`

### SDK installation
[Follow SDK installation instructions here](SDK_INSTALLATION.md)

### SDK Account setup
[Follow SDK Account instructions here](SDK_ACCOUNT_SETUP.md)

## Usage

### Basic joining meeting
APP key and secrent is required
```javascript
import RNZoomUsBridge from 'react-native-zoom-us-bridge';

RNZoomUsBridge.initialize(
  ZOOM_APP_KEY,
  ZOOM_APP_SECRET,
);

RNZoomUsBridge.joinMeeting(
  meetingId,
  userName,
  meetingPassword,
);


RNZoomUsBridge.startMeeting(

);
```
### Hosting meeting
JWT key and secret is required

```javascript

// get accessToken to communicate with zoom api

// use token to get userId of the user account you are creating the meeting with

// use the userId to obtain the Zoom Access Token

// use Zoom Access Token etc, to create a meeting

// use the meeting Id to start & join the meting
RNZoomUsBridge.startMeeting(
  meetingId,
  'userName',
  userId,
  userZoomAccessToken
);
```

### Events from zoom sdk
Use event emitter to listen for meeting state changes
```javascript
import RNZoomUsBridge, {RNZoomUsBridgeEventEmitter} from 'react-native-zoom-us-bridge';

const meetingEventEmitter = new NativeEventEmitter(RNZoomUsBridgeEventEmitter);

meetingEventEmitter.addListener(
  'SDKInitialized',
  () => {
    console.log("SDKInitialized");
  }
);

"SDKInitialized", "meetingStarted", "meetingJoined", "meetingSetToHidden", "meetingEnded", "meetingStatusChanged", "waitingRoomActive", "meetingError"

```
| Listener             | Description                                  |
|----------------------|----------------------------------------------|
| SDKInitialized       | Status update - SDK initialized successfully |
| meetingStarted       | Status update - Meeting started successfully |
| meetingJoined        | Status update - Meeting joined successfully  |
| meetingEnded         | Status update - Meeting ended without error  |
| meetingStatusChanged | Status update - Updates the meeting status   |
| meetingError         | Error - Meeting ended with error             |
| waitingRoomActive    | Error - Meeting waiting room is active       |

## Errors
build failed undefined issue, file size small, missing lfs

build failed, wont run on sim, need dev libs

build success, apple reject, wrong libs, need prod libs