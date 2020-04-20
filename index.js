import { NativeModules } from 'react-native';

const { RNZoomUsBridge, RNZoomUsBridgeEventEmitter: _RNZoomUsBridgeEventEmitter } = NativeModules;

export default RNZoomUsBridge;
export const RNZoomUsBridgeEventEmitter = _RNZoomUsBridgeEventEmitter;
