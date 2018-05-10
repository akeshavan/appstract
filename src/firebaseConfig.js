import firebase from 'firebase';

// copy/paste this from your firebase console
var config = {
  apiKey: "AIzaSyD08blKQnxP3FR1hk6aMDv6YM4mdV8XwoQ",
  authDomain: "appstract0.firebaseapp.com",
  databaseURL: "https://appstract0.firebaseio.com",
  projectId: "appstract0",
  storageBucket: "appstract0.appspot.com",
  messagingSenderId: "435321691621"
};

firebase.initializeApp(config);

export const db = firebase.database();
