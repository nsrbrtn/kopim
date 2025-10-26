(function registerKopimServiceWorker() {
  if (!('serviceWorker' in navigator)) {
    return;
  }

  if (!window.isSecureContext && location.hostname !== 'localhost') {
    return;
  }

  let hasReloaded = false;

  const register = async () => {
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
        console.info('[kopim-sw] Активирован обновлённый service worker, перезагружаем приложение.');
        window.location.reload();
      });
    } catch (error) {
      console.error('[kopim-sw] Ошибка регистрации service worker', error);
    }
  };

  if (document.readyState === 'complete') {
    register();
  } else {
    window.addEventListener('load', register, { once: true });
  }
})();
