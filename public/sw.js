const VERSION='delta-v2';
const STATIC=VERSION+'-static';
const PUBLIC=VERSION+'-pages';
const CORE=['/offline.html','/icons/icon-192.png','/icons/icon-512.png','/icons/apple-touch-icon.png','/favicon.svg'];
self.addEventListener('install',event=>event.waitUntil(caches.open(STATIC).then(cache=>cache.addAll(CORE))));
// Activation is requested by a visible button; never silently reload an active staff form.
self.addEventListener('message',event=>{if(event.data?.type==='ACTIVATE_UPDATE')self.skipWaiting();});
self.addEventListener('activate',event=>event.waitUntil((async()=>{for(const key of await caches.keys())if(key.startsWith('delta-')&&![STATIC,PUBLIC].includes(key))await caches.delete(key);await self.clients.claim();})()));
function publicPage(path){return path==='/'||/^\/(eventos|torneos|en-vivo|clasificaciones|calendario|anuncios|instalar|qr|demo|display|overlay)(\/|$)/.test(path);}
self.addEventListener('fetch',event=>{
 const req=event.request,url=new URL(req.url);
 if(req.method!=='GET'||url.origin!==self.location.origin)return;
 // No auth, private pages, RSC payloads or API responses are stored in Cache Storage.
 if(/^\/(admin|api|login|recuperar-contrasena|actualizar-contrasena|auth|signin-with-chatgpt|callback)/.test(url.pathname)||req.headers.get('RSC')||url.searchParams.has('_rsc'))return;
 if(req.mode==='navigate'&&publicPage(url.pathname)){
  event.respondWith((async()=>{try{const res=await fetch(req);if(res.ok&&res.headers.get('Content-Type')?.includes('text/html')){const cache=await caches.open(PUBLIC);await cache.put(req,res.clone());const keys=await cache.keys();if(keys.length>30)await cache.delete(keys[0]);}return res;}catch{return(await caches.match(req))||(await caches.match('/offline.html'));}})());return;
 }
 if(/\.(js|css|woff2|png|svg|webp)$/.test(url.pathname))event.respondWith((async()=>{const cached=await caches.match(req);if(cached)return cached;const res=await fetch(req);if(res.ok){const cache=await caches.open(STATIC);await cache.put(req,res.clone());}return res;})());
});
