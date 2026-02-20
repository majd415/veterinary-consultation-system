// TODO: Replace with your project's Firebase configuration if needed
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAkyOHmpt6_BwWrVui4uGSMlRgpk8nZHhQ",
  appId: "1:510700126849:web:7df237173120550ed24380",
  messagingSenderId: "510700126849",
  projectId: "dog-vet-chat",
  authDomain: "dog-vet-chat.firebaseapp.com",
  storageBucket: "dog-vet-chat.firebasestorage.app",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
