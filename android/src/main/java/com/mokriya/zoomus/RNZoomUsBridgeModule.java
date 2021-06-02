package com.mokriya.zoomus;

import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Callback;

import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;

import us.zoom.sdk.ZoomSDK;
import us.zoom.sdk.ZoomError;
import us.zoom.sdk.ZoomSDKInitializeListener;

import us.zoom.sdk.MeetingStatus;
import us.zoom.sdk.MeetingError;
import us.zoom.sdk.MeetingService;
import us.zoom.sdk.MeetingServiceListener;

import us.zoom.sdk.StartMeetingOptions;
import us.zoom.sdk.StartMeetingParamsWithoutLogin;

import us.zoom.sdk.JoinMeetingOptions;
import us.zoom.sdk.JoinMeetingParams;

import com.mokriya.zoomus.RNZoomUsBridgeHelper;

public class RNZoomUsBridgeModule extends ReactContextBaseJavaModule implements ZoomSDKInitializeListener, MeetingServiceListener, LifecycleEventListener {

    private final static String TAG = "RNZoomUsBridge";
    private final ReactApplicationContext reactContext;

    private Boolean isInitialized = false;
    private Promise initializePromise;
    private Promise meetingPromise;
    private Promise otherPromise;

    public RNZoomUsBridgeModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addLifecycleEventListener(this);
    }

    public void sendEvent(ReactContext reactContext, String eventName, WritableMap params) {
        reactContext
        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit(eventName, params);
    }

    @Override
    public String getName() {
        return "RNZoomUsBridge";
    }

    @ReactMethod
    public void initialize(final String appKey, final String appSecret, final Promise promise) {
        if (isInitialized) {
        promise.resolve("Already initialize Zoom SDK successfully.");
        return;
        }

        isInitialized = true;

        try {
        initializePromise = promise;

        reactContext.getCurrentActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ZoomSDK zoomSDK = ZoomSDK.getInstance();

                zoomSDK.initialize(reactContext.getCurrentActivity(), appKey, appSecret, RNZoomUsBridgeModule.this);
            }
        });
        } catch (Exception ex) {
        promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void startMeeting(
        final String meetingNo,
        final String displayName,
        final String userId,
        final String zoomAccessToken,
        Promise promise
    ) {
        try {
        meetingPromise = promise;

        ZoomSDK zoomSDK = ZoomSDK.getInstance();
        if(!zoomSDK.isInitialized()) {
            promise.reject("ERR_ZOOM_START", "ZoomSDK has not been initialized successfully");
            return;
        }

        final MeetingService meetingService = zoomSDK.getMeetingService();
        if(meetingService.getMeetingStatus() != MeetingStatus.MEETING_STATUS_IDLE) {
            long lMeetingNo = 0;
            try {
            lMeetingNo = Long.parseLong(meetingNo);
            } catch (NumberFormatException e) {
            promise.reject("ERR_ZOOM_START", "Invalid meeting number: " + meetingNo);
            return;
            }

            if(meetingService.getCurrentRtcMeetingNumber() == lMeetingNo) {
            meetingService.returnToMeeting(reactContext.getCurrentActivity());
            promise.resolve("Already joined zoom meeting");
            return;
            }
        }

        StartMeetingOptions opts = new StartMeetingOptions();
        StartMeetingParamsWithoutLogin params = new StartMeetingParamsWithoutLogin();
        params.displayName = displayName;
        params.meetingNo = meetingNo;
        params.userId = userId;
        params.userType = MeetingService.USER_TYPE_API_USER;
        params.zoomAccessToken = zoomAccessToken;

        int startMeetingResult = meetingService.startMeetingWithParams(reactContext.getCurrentActivity(), params, opts);
        Log.i(TAG, "startMeeting, startMeetingResult=" + startMeetingResult);

        if (startMeetingResult != MeetingError.MEETING_ERROR_SUCCESS) {
            promise.reject("ERR_ZOOM_START", "startMeeting, errorCode=" + startMeetingResult);
        }
        } catch (Exception ex) {
        promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void createJWT(
        final String apiKey,
        final String apiSecret,
        Promise promise
    ) {
        try {
            otherPromise = promise;

            String accessToken = RNZoomUsBridgeHelper.createJWTAccessToken(apiKey, apiSecret);
            Log.i(TAG, "accessToken=" + accessToken);

            promise.resolve(accessToken);
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void joinMeeting(
        final String meetingNo,
        final String displayName,
        final String meetingPassword,
        Promise promise
    ) {
        try {
        meetingPromise = promise;

        ZoomSDK zoomSDK = ZoomSDK.getInstance();
        if(!zoomSDK.isInitialized()) {
            promise.reject("ERR_ZOOM_JOIN", "ZoomSDK has not been initialized successfully");
            return;
        }

        final MeetingService meetingService = zoomSDK.getMeetingService();

        JoinMeetingOptions opts = new JoinMeetingOptions();
        JoinMeetingParams params = new JoinMeetingParams();
        params.displayName = displayName;
        params.meetingNo = meetingNo;
        params.password = meetingPassword;

        int joinMeetingResult = meetingService.joinMeetingWithParams(reactContext.getCurrentActivity(), params, opts);
        Log.i(TAG, "joinMeeting, joinMeetingResult=" + joinMeetingResult);

        if (joinMeetingResult != MeetingError.MEETING_ERROR_SUCCESS) {
            promise.reject("ERR_ZOOM_JOIN", "joinMeeting, errorCode=" + joinMeetingResult);
        }
        } catch (Exception ex) {
        promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @Override
    public void onZoomSDKInitializeResult(int errorCode, int internalErrorCode) {
        Log.i(TAG, "onZoomSDKInitializeResult, errorCode=" + errorCode + ", internalErrorCode=" + internalErrorCode);
        if(errorCode != ZoomError.ZOOM_ERROR_SUCCESS) {
        initializePromise.reject(
                "ERR_ZOOM_INITIALIZATION",
                "Error: " + errorCode + ", internalErrorCode=" + internalErrorCode
        );
        } else {
        registerListener();
        WritableMap params = Arguments.createMap();
        sendEvent(reactContext, "SDKInitialized", params);
        initializePromise.resolve("Initialize Zoom SDK successfully.");
        }
    }

    @Override
    public void onMeetingStatusChanged(MeetingStatus meetingStatus, int errorCode, int internalErrorCode) {
        Log.i(TAG, "onMeetingStatusChanged, meetingStatus=" + meetingStatus + ", errorCode=" + errorCode + ", internalErrorCode=" + internalErrorCode);

        if (meetingPromise == null) {
        return;
        }

        WritableMap params = Arguments.createMap();

        if(meetingStatus == MeetingStatus.MEETING_STATUS_FAILED) {
        meetingPromise.reject(
                "ERR_ZOOM_MEETING",
                "Error: " + errorCode + ", internalErrorCode=" + internalErrorCode
        );
        meetingPromise = null;
        } else if (meetingStatus == MeetingStatus.MEETING_STATUS_DISCONNECTING) {

        sendEvent(reactContext, "meetingEnded", params);

        } else if (meetingStatus == MeetingStatus.MEETING_STATUS_INMEETING) {

        sendEvent(reactContext, "meetingStarted", params);
        meetingPromise.resolve("Connected to zoom meeting");
        meetingPromise = null;

        } else {
        params.putString("eventProperty", "onMeetingStatusChanged, meetingStatus=" + meetingStatus + ", errorCode=" + errorCode + ", internalErrorCode=" + internalErrorCode);
        sendEvent(reactContext, "meetingStatusChanged", params);
        }
    }

    private void registerListener() {
        Log.i(TAG, "registerListener");
        ZoomSDK zoomSDK = ZoomSDK.getInstance();
        MeetingService meetingService = zoomSDK.getMeetingService();
        if(meetingService != null) {
        meetingService.addListener(this);
        }
    }

    private void unregisterListener() {
        Log.i(TAG, "unregisterListener");
        ZoomSDK zoomSDK = ZoomSDK.getInstance();
        if(zoomSDK.isInitialized()) {
        MeetingService meetingService = zoomSDK.getMeetingService();
        meetingService.removeListener(this);
        }
    }

    @Override
    public void onCatalystInstanceDestroy() {
        unregisterListener();
    }

    // React LifeCycle
    @Override
    public void onHostDestroy() {
        unregisterListener();
    }

    @Override
    public void onHostPause() {}

    @Override
    public void onHostResume() {}

    @Override
    public void onZoomAuthIdentityExpired() {
        Log.e(TAG,"onZoomAuthIdentityExpired in init");
    }
}
