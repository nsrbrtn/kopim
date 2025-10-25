importScripts('https://www.gstatic.com/firebasejs/10.12.3/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.3/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDx-Bk8U_a-_HZAw-0t3RnophFfVkL6qho',
  appId: '1:219578876393:web:ed7e608b42240c7d3bcb78',
  messagingSenderId: '219578876393',
  projectId: 'device-streaming-74c1af8e',
  authDomain: 'device-streaming-74c1af8e.firebaseapp.com',
  databaseURL: 'https://device-streaming-74c1af8e-default-rtdb.europe-west1.firebasedatabase.app',
  storageBucket: 'device-streaming-74c1af8e.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification ?? {};
  self.registration.showNotification(notification.title ?? 'kopim', {
    body: notification.body,
  });
});
