'use client';
import {useEffect,useState} from 'react';
import {Download,Smartphone,Share,PlusSquare,Monitor,RefreshCw,CheckCircle2} from 'lucide-react';
interface InstallEvent extends Event { prompt:()=>Promise<void>; userChoice:Promise<{outcome:string}> }
let pendingInstall:InstallEvent|null=null;
export function PWAProvider(){
 const [waiting,setWaiting]=useState<ServiceWorker|null>(null);
 const [reloadReady,setReloadReady]=useState(false);
 useEffect(()=>{
  const capture=(e:Event)=>{e.preventDefault();pendingInstall=e as InstallEvent;window.dispatchEvent(new Event('delta-install-ready'));};
  window.addEventListener('beforeinstallprompt',capture);
  if(process.env.NODE_ENV!=='production'||!('serviceWorker' in navigator))return()=>window.removeEventListener('beforeinstallprompt',capture);
  let alive=true;let reloaded=false;let controlled=!!navigator.serviceWorker.controller;
  const changed=()=>{if(!controlled){controlled=true;return;}if(/^\/(admin|login|actualizar-contrasena|recuperar-contrasena)/.test(location.pathname)){setWaiting(null);setReloadReady(true);return;}if(!reloaded){reloaded=true;window.location.reload();}};
  navigator.serviceWorker.addEventListener('controllerchange',changed);
  navigator.serviceWorker.register('/sw.js',{scope:'/',updateViaCache:'none'}).then(reg=>{
   if(!alive)return;if(reg.waiting)setWaiting(reg.waiting);
   reg.addEventListener('updatefound',()=>{const worker=reg.installing;worker?.addEventListener('statechange',()=>{if(alive&&worker.state==='installed'&&navigator.serviceWorker.controller)setWaiting(worker);});});
  }).catch(()=>{});
  return()=>{alive=false;window.removeEventListener('beforeinstallprompt',capture);navigator.serviceWorker.removeEventListener('controllerchange',changed);};
 },[]);
 return reloadReady?<aside className="update-toast"><RefreshCw size={18}/><span>Nueva versión disponible. Termina tus cambios antes de recargar.</span><button onClick={()=>{if(confirm('¿Recargar? Se perderán los datos del formulario que no hayas guardado.'))location.reload();}}>Recargar</button></aside>:waiting?<aside className="update-toast"><RefreshCw size={18}/><span>Una nueva versión está lista.</span><button onClick={()=>waiting.postMessage({type:'ACTIVATE_UPDATE'})}>Actualizar</button></aside>:null;
}
export function InstallPage(){
 const [prompt,setPrompt]=useState<InstallEvent|null>(null);const [installed,setInstalled]=useState(false);const [platform,setPlatform]=useState('');const [message,setMessage]=useState('');
 useEffect(()=>{
  const ua=navigator.userAgent;setPlatform(/iPad|iPhone|iPod/.test(ua)||(/Mac/.test(ua)&&navigator.maxTouchPoints>1)?'ios':/Android/.test(ua)?'android':'desktop');
  setInstalled(window.matchMedia('(display-mode: standalone)').matches);
  setPrompt(pendingInstall);
  const ready=()=>setPrompt(pendingInstall);window.addEventListener('delta-install-ready',ready);
  const capture=(e:Event)=>{e.preventDefault();setPrompt(e as InstallEvent);};const done=()=>{setInstalled(true);setPrompt(null);};
  window.addEventListener('beforeinstallprompt',capture);window.addEventListener('appinstalled',done);
  return()=>{window.removeEventListener('delta-install-ready',ready);window.removeEventListener('beforeinstallprompt',capture);window.removeEventListener('appinstalled',done);};
 },[]);
 return <><div className="page-intro"><span className="eyebrow">DELTA, SIEMPRE CONTIGO</span><h1>Tu competencia.<br/><span>En tu pantalla de inicio.</span></h1><p>Entra desde tu navegador o instala Delta Esports cuando tu dispositivo lo permita. Sin crear una cuenta.</p></div><div className="install-layout"><section className="panel install-feature"><div className="app-icon">Δ</div><h2>Delta Esports</h2><p>Un acceso directo a cada enfrentamiento.</p>{installed?<span className="pill green"><CheckCircle2 size={16}/> Ya estás en la aplicación</span>:prompt?<button className="primary" onClick={async()=>{await prompt.prompt();const choice=await prompt.userChoice;setMessage(choice.outcome==='accepted'?'Sigue las indicaciones de tu navegador.':'Puedes instalarla más adelante.');pendingInstall=null;setPrompt(null);}}><Download size={18}/> Instalar aplicación</button>:<span className="pill">Sigue las instrucciones de tu navegador</span>}<p role="status">{message}</p><div className="install-foot">La instalación no otorga permisos de staff.<br/>Los resultados en directo requieren internet.</div></section><div className="install-guides">{[{id:'ios',icon:Share,title:'iPhone y iPad',body:'Abre Delta en Safari. Pulsa Compartir y selecciona “Añadir a pantalla de inicio”. Activa “Abrir como app web” si aparece, y confirma.'},{id:'android',icon:Smartphone,title:'Android',body:'Abre la web en un navegador compatible, como Chrome. En el menú busca “Instalar aplicación” o “Añadir a pantalla de inicio”. Si aparece el botón de instalación, puedes utilizarlo.'},{id:'desktop',icon:Monitor,title:'Computadora',body:'En Chrome o Edge, busca el icono de instalación en la barra de direcciones o la opción de instalar en el menú. En Safari de Mac compatible, utiliza “Añadir al Dock”.'}].map(g=><section className={`panel guide ${platform===g.id?'recommended':''}`} key={g.id}><g.icon size={24}/><div><h3>{g.title}{platform===g.id&&<small> TU DISPOSITIVO</small>}</h3><p>{g.body}</p></div></section>)}<p className="muted">La disponibilidad varía por sistema y navegador. Si no aparece la opción, puedes seguir usando todas las páginas públicas desde la web.</p></div></div></>;
}
