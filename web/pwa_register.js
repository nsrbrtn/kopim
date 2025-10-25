(function registerKopimServiceWorker() {
  if (!('serviceWorker' in navigator)) {
    return;
  }

  const register = async () => {
    try {
      const registration = await navigator.serviceWorker.register('service_worker.js');
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
