# react-native-zoom-us-bridge

## Getting started

`$ npm install react-native-zoom-us-bridge --save`

or

yarn react-native-zoom-us-bridge

### Mostly automatic installation

RN 60 > auto link

RN 60 <
`$ react-native link react-native-zoom-us-bridge`

Mandatory iOS setup process
Using Cocoapods (recommended)
SDK is too large for standard git so lfs must be activated.
brew git-lfs
pod install

to use dev, swap out pod file.

Manually adding library
Download library
Drag library to folder
Add library and framework


Setting up zoom sdk key (required)

Setting up zoom jwt key (optional if you are going to be creating/starting meetings)
explanation of user accounts

## Usage
```javascript
import RNZoomUsBridge from 'react-native-zoom-us-bridge';

RNZoomUsBridge.joinMeeting();


RNZoomUsBridge.startMeeting();
```

checklist
SDK app keys etc
JWT app keys
can join meeting
can start meeting
can not create meeting
can not login, SDK login only

explain user related stuff
add event emitter



Errors
build failed undefined issue, file size small, missing lfs

build failed, wont run on sim, need dev libs

build success, apple reject, wrong libs, need prod libs