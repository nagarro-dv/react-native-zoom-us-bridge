/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React, {useEffect, useReducer} from 'react';
import {
  StyleSheet,
  Text,
  View,
  NativeEventEmitter,
  Alert,
  TouchableOpacity,
  TextInput,
} from 'react-native';

import RNZoomUsBridge, {
  RNZoomUsBridgeEventEmitter,
} from 'react-native-zoom-us-bridge';

// YOU WILL NEED TO SET THIS
const ZOOM_SDK_KEY = '0pwMOPLd6vyl6a4mFo3ZMs10uy90TGKIw0c2';
const ZOOM_SDK_SECRET = 'j4zdEbKiLgktXxCLAh1SRIrsydFUJ2JjDaeL';
const ZOOM_JWT_API_KEY = 'oEdfAdW4RGaxThkQSBkrqg';
const ZOOM_JWT_API_SECRET = 'OPZcOGgEramfl67GYBlygWP3rkyuXPi7zaqQ';

const initialState = {
  meetingId: '',
  meetingPassword: '',
  meetingTitle: '',
  userName: '',
  userEmail: '',
  userId: '',
  accessToken: '',
  userZoomAccessToken: '',
  meetingCreated: false,
  view: 'select',
};

function reducer(state, action) {
  switch (action.type) {
    case 'UPDATE_MEETINGID':
      return {
        ...state,
        meetingId: action.payload,
      };
    case 'UPDATE_MEETINGPASSWORD':
      return {
        ...state,
        meetingPassword: action.payload,
      };
    case 'UPDATE_MEETINGTITLE':
      return {
        ...state,
        meetingTitle: action.payload,
      };
    case 'UPDATE_USERNAME':
      return {
        ...state,
        userName: action.payload,
      };
    case 'UPDATE_USEREMAIL':
      return {
        ...state,
        userEmail: action.payload,
      };
    case 'UPDATE_USERID':
      return {
        ...state,
        userId: action.payload,
      };
    case 'UPDATE_ACCESSTOKEN':
      return {
        ...state,
        accessToken: action.payload,
      };
    case 'UPDATE_USERZAK':
      return {
        ...state,
        userZoomAccessToken: action.payload,
      };
    case 'UPDATE_MEETINGCREATED':
      return {
        ...state,
        meetingCreated: action.payload,
      };
    case 'UPDATE_VIEW':
      return {
        ...state,
        view: action.payload,
      };
    default:
      throw new Error();
  }
}

const App = () => {
  const [state, dispatch] = useReducer(reducer, initialState);

  // lets listen to the events!
  useEffect(() => {
    const meetingEventEmitter = new NativeEventEmitter(
      RNZoomUsBridgeEventEmitter,
    );

    // add sdk init listener
    const sdkInitialized = meetingEventEmitter.addListener(
      'SDKInitialized',
      () => {
        console.log('SDKInitialized');

        // lets also get access token
        createAccessToken();
      },
    );

    // add meeting waiting room is active
    const meetingWaitingRoomIsActiveSubscription =
      meetingEventEmitter.addListener('waitingRoomActive', () => {
        Alert.alert(
          'Error Joining',
          'Meeting waiting room is active. Please disable before joining.',
          [{text: 'OK', onPress: () => null}],
          {cancelable: false},
        );
        console.log('waitingRoomActive');
      });

    const meetingStatusChangedSubscription = meetingEventEmitter.addListener(
      'meetingStatusChanged',
      event => console.log('meetingStatusChanged', event.eventProperty),
    );

    const hiddenSubscription = meetingEventEmitter.addListener(
      'meetingSetToHidden',
      () => console.log('Meeting Hidden'),
    );

    const endedSubscription = meetingEventEmitter.addListener(
      'meetingEnded',
      result => {
        console.log('Meeting Ended: ', result);
        if ('error' in result) {
          Alert.alert(
            'Error Joining',
            'One of your inputs is invalid.',
            [{text: 'OK', onPress: () => null}],
            {cancelable: false},
          );
        }
      },
    );

    const meetingErroredSubscription = meetingEventEmitter.addListener(
      'meetingError',
      result => {
        console.log('Meeting Errored: ', result);
        if ('error' in result) {
          Alert.alert(
            'Error Joining',
            'One of your inputs is invalid.',
            [{text: 'OK', onPress: () => null}],
            {cancelable: false},
          );
        }
      },
    );

    const startedSubscription = meetingEventEmitter.addListener(
      'meetingStarted',
      result => {
        console.log('Meeting Started: ', result);
        if ('error' in result) {
          Alert.alert(
            'Error Joining',
            'One of your inputs is invalid.',
            [{text: 'OK', onPress: () => null}],
            {cancelable: false},
          );
        }
      },
    );

    const joinedSubscription = meetingEventEmitter.addListener(
      'meetingJoined',
      result => {
        console.log('Meeting Joined: ', result);
        if ('error' in result) {
          Alert.alert(
            'Error Joining',
            'One of your inputs is invalid.',
            [{text: 'OK', onPress: () => null}],
            {cancelable: false},
          );
        }
      },
    );

    initializeZoomSDK();

    return () => {
      // remove listeners
      sdkInitialized.remove();
      meetingWaitingRoomIsActiveSubscription.remove();
      meetingStatusChangedSubscription.remove();
      hiddenSubscription.remove();
      endedSubscription.remove();
      meetingErroredSubscription.remove();
      startedSubscription.remove();
      joinedSubscription.remove();
    };
  }, []);

  const initializeZoomSDK = () => {
    if (ZOOM_SDK_KEY && ZOOM_SDK_SECRET) {
      // init sdk
      console.log('RNZoomUsBridge', RNZoomUsBridge);
      RNZoomUsBridge.initialize(ZOOM_SDK_KEY, ZOOM_SDK_SECRET)
        .then()
        .catch(err => {
          console.warn(err);
          Alert.alert('error!', err.message);
        });
    }
  };

  const joinMeeting = async () => {
    if (state.meetingId && state.userName && state.meetingPassword) {
      RNZoomUsBridge.joinMeeting(
        String(state.meetingId),
        state.userName,
        state.meetingPassword,
      )
        .then()
        .catch(err => {
          console.warn(err);
          Alert.alert('error!', err.message);
        });
    }
  };

  const createAccessToken = async () => {
    // to talk to ZOOM API you will need access token
    if (ZOOM_JWT_API_KEY && ZOOM_JWT_API_SECRET) {
      const accessToken = await RNZoomUsBridge.createJWT(
        ZOOM_JWT_API_KEY,
        ZOOM_JWT_API_SECRET,
      )
        .then()
        .catch(err => console.log(err));

      console.log(`createAccessToken ${accessToken}`);

      if (accessToken) {
        dispatch({type: 'UPDATE_ACCESSTOKEN', payload: accessToken});
      }
    }
  };

  const getUserID = async (userEmail, accessToken) => {
    const fetchURL = `https://api.zoom.us/v2/users/${userEmail}`;
    const userResult = await fetch(fetchURL, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
    })
      .then(response => response.json())
      .then(json => {
        return json;
      })
      .catch(error => {
        console.error(error);
      });

    console.log('userResult', userResult);

    if (userResult && userResult.code === 429) {
      // rate error try again later
      Alert.alert('API Rate error try again in a few seconds');
    }

    if (userResult && userResult.id && userResult.status === 'active') {
      // set user id
      const {id: userId} = userResult;
      dispatch({type: 'UPDATE_USERID', payload: userId});

      return userId;
    }

    return false;
  };

  const createUserZAK = async (userId, accessToken) => {
    const fetchURL = `https://api.zoom.us/v2/users/${userId}/token?type=zak`;
    const userZAKResult = await fetch(fetchURL, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
    })
      .then(response => response.json())
      .then(json => {
        return json;
      })
      .catch(error => {
        console.error(error);
      });

    console.log('userZAKResult', userZAKResult);

    if (userZAKResult && userZAKResult.code === 429) {
      // rate error try again later
      Alert.alert('API Rate error try again in a few seconds');
    }

    if (userZAKResult && userZAKResult.token) {
      // set user id
      const {token} = userZAKResult;

      dispatch({type: 'UPDATE_USERZAK', payload: token});

      return token;
    }

    return false;
  };

  const createMeeting = async () => {
    if (state.accessToken && state.meetingTitle && state.userEmail) {
      // user ID is pulled from jwt end point using the email address
      const userId = await getUserID(state.userEmail, state.accessToken);
      await createUserZAK(userId, state.accessToken);

      if (userId) {
        // use api to create meeting
        const fetchURL = `https://api.zoom.us/v2/users/${userId}/meetings`;
        const createMeetingResult = await fetch(fetchURL, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${state.accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            topic: state.meetingTitle,
            type: 1,
            duration: 30,
            password: '123456', // set your own password is possible
            settings: {
              waiting_room: false,
              registrants_confirmation_email: false,
              audio: 'voip',
            },
          }),
        })
          .then(response => response.json())
          .then(json => {
            return json;
          })
          .catch(error => {
            console.error(error);
          });

        console.log('createMeetingResult', createMeetingResult);

        if (createMeetingResult && createMeetingResult.code === 429) {
          // rate error try again later
          Alert.alert('API Rate error try again in a few seconds');
        }

        if (createMeetingResult && createMeetingResult.id) {
          const {id, password} = createMeetingResult;
          dispatch({type: 'UPDATE_MEETINGID', payload: id});
          dispatch({type: 'UPDATE_MEETINGPASSWORD', payload: password});
          dispatch({type: 'UPDATE_MEETINGCREATED', payload: true});
        }
      }
    }
  };

  const startMeeting = async () => {
    if (state.meetingId && state.userId && state.userZoomAccessToken) {
      await RNZoomUsBridge.startMeeting(
        String(state.meetingId),
        state.userName,
        state.userId,
        state.userZoomAccessToken,
      );
    }
  };

  const viewJoin = () => dispatch({type: 'UPDATE_VIEW', payload: 'join'});

  const viewHost = () => dispatch({type: 'UPDATE_VIEW', payload: 'host'});

  return (
    <View style={styles.container}>
      <Text style={styles.welcome}>☆RNZoomUsBridge example☆</Text>
      {!ZOOM_SDK_KEY || !ZOOM_SDK_SECRET ? (
        <Text style={styles.welcome}>
          ZOOM_APP_KEY and ZOOM_APP_SECRET must be set
        </Text>
      ) : null}
      {!ZOOM_JWT_API_KEY || !ZOOM_JWT_API_SECRET ? (
        <Text style={styles.welcome}>
          optional ZOOM_JWT_APP_KEY and ZOOM_JWT_APP_SECRET must be set to host
          meetings
        </Text>
      ) : null}
      {state.view === 'select' ? (
        <>
          <TouchableOpacity onPress={viewJoin} style={styles.button}>
            <Text style={styles.buttonText}>Join a Meeting</Text>
          </TouchableOpacity>
          {state.accessToken ? (
            <TouchableOpacity onPress={viewHost} style={styles.button}>
              <Text style={styles.buttonText}>Host a Meeting</Text>
            </TouchableOpacity>
          ) : null}
        </>
      ) : null}
      {state.view === 'join' ? (
        <>
          <TextInput
            value={state.meetingId}
            placeholder="Meeting ID"
            onChangeText={text =>
              dispatch({type: 'UPDATE_MEETINGID', payload: text})
            }
            style={styles.input}
          />
          <TextInput
            value={state.meetingPassword}
            placeholder="Meeting Password"
            onChangeText={text =>
              dispatch({type: 'UPDATE_MEETINGPASSWORD', payload: text})
            }
            style={styles.input}
          />
          <TextInput
            value={state.userName}
            placeholder="Your name"
            onChangeText={text =>
              dispatch({type: 'UPDATE_USERNAME', payload: text})
            }
            style={styles.input}
          />
          <TouchableOpacity onPress={joinMeeting} style={styles.button}>
            <Text style={styles.buttonText}>Join Meeting</Text>
          </TouchableOpacity>
        </>
      ) : null}
      {state.view === 'host' ? (
        <>
          <TextInput
            value={state.userEmail}
            placeholder="Your zoom email address"
            onChangeText={text =>
              dispatch({type: 'UPDATE_USEREMAIL', payload: text})
            }
            style={styles.input}
          />
          <TextInput
            value={state.meetingTitle}
            placeholder="Meeting title"
            onChangeText={text =>
              dispatch({type: 'UPDATE_MEETINGTITLE', payload: text})
            }
            style={styles.input}
          />
          <TouchableOpacity onPress={createMeeting} style={styles.button}>
            <Text style={styles.buttonText}>Create Meeting</Text>
          </TouchableOpacity>
          {state.meetingCreated ? (
            <>
              <TextInput
                value={state.meetingId}
                placeholder="Meeting ID"
                style={styles.input}
                editable={false}
              />
              <TextInput
                value={state.meetingPassword}
                placeholder="Meeting Password"
                style={styles.input}
                editable={false}
              />
              <TouchableOpacity onPress={startMeeting} style={styles.button}>
                <Text style={styles.buttonText}>Start Meeting</Text>
              </TouchableOpacity>
            </>
          ) : null}
        </>
      ) : null}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  input: {
    width: 200,
    padding: 10,
    borderRadius: 5,
    borderWidth: 1,
    borderColor: 'grey',
    margin: 3,
  },
  button: {
    width: 200,
    padding: 10,
    borderRadius: 5,
    backgroundColor: 'salmon',
    alignItems: 'center',
    justifyContent: 'center',
    margin: 3,
  },
  buttonText: {
    color: 'white',
  },
});

export default App;
