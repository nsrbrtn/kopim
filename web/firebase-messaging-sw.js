importScripts('https://www.gstatic.com/firebasejs/10.12.3/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.3/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBT3VtuZQqe4NQpcCYA6t5xdDJeGRuVB5M',
  appId: '1:228213546937:web:d0dd6142a848fa1ced2068',
  messagingSenderId: '228213546937',
  projectId: 'kopim-prod',
  authDomain: 'kopim-prod.firebaseapp.com',
  storageBucket: 'kopim-prod.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification ?? {};
  self.registration.showNotification(notification.title ?? 'kopim', {
    body: notification.body,
  });
});
