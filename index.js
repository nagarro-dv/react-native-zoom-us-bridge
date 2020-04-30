import { NativeModules } from 'react-native';

const { RNZoomUsBridge, RNZoomUsBridgeEventEmitter: _RNZoomUsBridgeEventEmitter } = NativeModules;
export const RNZoomUsBridgeEventEmitter = _RNZoomUsBridgeEventEmitter;


export const EVENTS_TYPE = {
  SDK_INITIALIZED: 'SDKInitialized',
  WAITING_ROOM_ACTIVE: 'waitingRoomActive',
  MEETING_STATUS_CHANGED: 'meetingStatusChanged',
  MEETING_SET_TO_HIDDEN: 'meetingSetToHidden',
  MEETING_ENDED: 'meetingEnded',
  MEETING_ERROR: 'meetingError',
  MEETING_STARTED: 'meetingStarted',
  MEETING_JOINED: 'meetingJoined',
};


export const ZoomEventEmitter = new NativeEventEmitter(RNZoomUsBridgeEventEmitter);


const request = (objOptions) => {
  const { url, token, method, body } = objOptions;

  return fetch(url, {
    method: method || 'GET',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    ...(body && { body })
  }).then((response) => response.json());
};


const Zoom = (objOptions) => {
  const {
    ZOOM_APP_KEY,
    ZOOM_APP_SECRET,
    ZOOM_JWT_APP_KEY,
    ZOOM_JWT_APP_SECRET,
  } = objOptions;

  const addListener = (strType, fnCallback) => {
    return ZoomEventEmitter.addListener(strType, fnCallback);
  };


  const initialize = () => {
    return RNZoomUsBridge.initialize(
      ZOOM_APP_KEY,
      ZOOM_APP_SECRET,
    );
  }

  const createJWT = () => {
    return RNZoomUsBridge.createJWT(ZOOM_JWT_APP_KEY, ZOOM_JWT_APP_SECRET);
  };


  const getUserID = (userEmail, accessToken) => {
    const fetchURL = `https://api.zoom.us/v2/users/${userEmail}`;
    return request({
      url: fetchURL,
      token: accessToken,
    });
  };


  const createUserZAK = (userId, accessToken) => {
    const fetchURL = `https://api.zoom.us/v2/users/${userId}/token?type=zak`;
    return request({
      url: fetchURL,
      token: accessToken,
    });
  };


  const createMeeting = async (objOptions) => {
    const { accessToken, userEmail, title, type, duration, password, ...config } = objOptions;

    const userId = await getUserID(userEmail, accessToken);

    if (userId) {
      const userZAK = await createUserZAK(userId, accessToken);

      if (userZAK) {

        const fetchURL = `https://api.zoom.us/v2/users/${userId}/meetings`
        return request({
          method: 'POST',
          url: fetchURL,
          token: accessToken,
          body: JSON.stringify({
            topic: title,
            type,
            duration,
            password,
            settings: {
              waiting_room: false,
              registrants_confirmation_email: false,
              audio: 'voip',
            },
            ...config,
          })
        });
      }
    }

    return Promise.reject("MISSING_DATA");
  };


  return {
    ...RNZoomUsBridge,
    initialize,
    createJWT,
    getUserID,
    createUserZAK,
    createMeeting,
    EVENTS_TYPE,
    ZoomEventEmitter,
  };
};

export default Zoom;
