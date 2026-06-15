(function registerKopimServiceWorker() {
  if (!('serviceWorker' in navigator)) {
    return;
  }

  if (!window.isSecureContext && location.hostname !== 'localhost') {
    return;
  }

  let hasReloaded = false;

  const registerAppServiceWorker = async () => {
    try {
      const workerUrl = new URL('service_worker.js', window.location.href);
      const registration = await navigator.serviceWorker.register(workerUrl);
      registration.addEventListener('updatefound', () => {
        const installing = registration.installing;
        if (!installing) {
          return;
        }
        installing.addEventListener('statechange', () => {
          if (installing.state === 'installed' && navigator.serviceWorker.controller) {
            console.info('[kopim-sw] Доступна новая версия. Она будет активирована после перезагрузки.');
          }
        });
      });

      navigator.serviceWorker.addEventListener('controllerchange', () => {
        if (hasReloaded) {
          return;
        }
        hasReloaded = true;
        console.info('[kopim-sw] Активирован обновлённый service worker. Перезагрузите страницу, чтобы увидеть изменения.');
      });
    } catch (error) {
      console.error('[kopim-sw] Ошибка регистрации service worker', error);
    }
  };

  const registerFirebaseMessagingWorker = async () => {
    try {
      const workerUrl = new URL(
        'firebase-messaging-sw.js',
        window.location.href,
      );
      await navigator.serviceWorker.register(workerUrl, {
        scope: '/firebase-cloud-messaging-push-scope',
      });
    } catch (error) {
      console.error(
        '[kopim-sw] Ошибка регистрации Firebase Messaging service worker',
        error,
      );
    }
  };

  const unregisterOldFlutterServiceWorker = async () => {
    if ('serviceWorker' in navigator) {
      try {
        const registrations = await navigator.serviceWorker.getRegistrations();
        for (const registration of registrations) {
          if (registration.active && registration.active.scriptURL.includes('flutter_service_worker.js')) {
            console.info('[kopim-sw] Найдена старая версия Flutter SW. Разрегистрируем...', registration.active.scriptURL);
            await registration.unregister();
          }
        }
      } catch (e) {
        console.error('[kopim-sw] Ошибка при удалении старого Flutter SW', e);
      }
    }
  };

  const cleanOldFlutterCaches = async () => {
    if ('caches' in window) {
      try {
        const keys = await caches.keys();
        for (const key of keys) {
          if (key.startsWith('flutter-app-') || key.startsWith('flutter-resources-')) {
            console.info('[kopim-sw] Удаляем старый кэш Flutter:', key);
            await caches.delete(key);
          }
        }
      } catch (e) {
        console.error('[kopim-sw] Ошибка при очистке кэша Flutter', e);
      }
    }
  };

  const register = async () => {
    await unregisterOldFlutterServiceWorker();
    await cleanOldFlutterCaches();
    await registerAppServiceWorker();
  };

  if (document.readyState === 'complete') {
    register();
  } else {
    window.addEventListener('load', register, { once: true });
  }
})();
