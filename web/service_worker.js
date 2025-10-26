const APP_SHELL_CACHE = 'kopim-shell-v1';
const RUNTIME_CACHE = 'kopim-runtime-v1';
const CORE_ASSETS = [
  '/',
  'index.html',
  'manifest.json',
  'version.json',
  'flutter.js',
  'flutter_bootstrap.js',
  'main.dart.js',
  'main.dart.mjs',
  'main.dart.wasm',
  'assets/AssetManifest.json',
  'assets/AssetManifest.bin.json',
  'assets/AssetManifest.bin',
  'assets/FontManifest.json',
  'assets/NOTICES',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/skwasm.js',
  'canvaskit/skwasm.wasm',
];
const CORE_SET = new Set(CORE_ASSETS);
const FIREBASE_HOST_SUFFIXES = [
  'firebaseio.com',
  'googleapis.com',
  'gstatic.com',
  'firebasestorage.googleapis.com',
  'firebasestorage.app',
  'firebaseapp.com',
  'cloudfunctions.net',
];

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(APP_SHELL_CACHE).then(async (cache) => {
      await Promise.all(
        CORE_ASSETS.map(async (asset) => {
          try {
            const request = new Request(asset, {
              cache: 'reload',
              credentials: 'same-origin',
            });
            const response = await fetch(request);
            if (response && response.ok) {
              await cache.put(asset, response.clone());
            }
          } catch (error) {
            console.warn('[kopim-sw] Не удалось закешировать', asset, error);
          }
        }),
      );
    }),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== APP_SHELL_CACHE && key !== RUNTIME_CACHE)
          .map((key) => caches.delete(key)),
      ),
    ).then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') {
    return;
  }

  const url = new URL(request.url);

  if (url.origin === self.location.origin) {
    if (request.mode === 'navigate') {
      event.respondWith(handleNavigationRequest(request));
      return;
    }

    if (isCoreAsset(url.pathname)) {
      event.respondWith(cacheFirst(request));
      return;
    }

    event.respondWith(runtimeCacheFirst(request));
    return;
  }

  if (isFirebaseRequest(url)) {
    event.respondWith(networkWithOfflineFallback(request));
  }
});

async function handleNavigationRequest(request) {
  const cache = await caches.open(APP_SHELL_CACHE);
  const cached = await cache.match('index.html');
  try {
    const networkResponse = await fetch(request);
    if (networkResponse && networkResponse.ok) {
      await cache.put('index.html', networkResponse.clone());
      return networkResponse;
    }
    throw new Error('Navigation fetch failed');
  } catch (error) {
    if (cached) {
      return cached;
    }
    return new Response('offline', {
      status: 503,
      statusText: 'Offline',
    });
  }
}

async function cacheFirst(request) {
  const cache = await caches.open(APP_SHELL_CACHE);
  const cached = await cache.match(request, { ignoreSearch: true });
  if (cached) {
    return cached;
  }
  const response = await fetch(request);
  if (response && response.ok) {
    await cache.put(request, response.clone());
  }
  return response;
}

async function runtimeCacheFirst(request) {
  const cache = await caches.open(RUNTIME_CACHE);
  const cached = await cache.match(request);
  if (cached) {
    return cached;
  }
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      await cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    return cached ?? Promise.reject(error);
  }
}

async function networkWithOfflineFallback(request) {
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      return response;
    }
    throw new Error('Response not ok');
  } catch (_) {
    return new Response(
      JSON.stringify({ status: 'offline', message: 'Сеть недоступна' }),
      {
        status: 503,
        headers: { 'Content-Type': 'application/json' },
      },
    );
  }
}

function isFirebaseRequest(url) {
  return FIREBASE_HOST_SUFFIXES.some((suffix) => url.hostname.endsWith(suffix));
}

function isCoreAsset(pathname) {
  if (CORE_SET.has(pathname)) {
    return true;
  }
  const normalized = pathname.startsWith('/') ? pathname.slice(1) : pathname;
  if (CORE_SET.has(normalized)) {
    return true;
  }
  // Для wasm-рендерера Flutter запрашивает файлы с query-параметрами, поэтому
  // игнорируем часть после вопросительного знака.
  const [pathWithoutSearch] = normalized.split('?');
  return CORE_SET.has(pathWithoutSearch);
}
