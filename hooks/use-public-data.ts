'use client';
import {useEffect,useState} from 'react';
import {browserDB} from '@/lib/supabase/browser';
import {Snapshot,emptySnapshot} from '@/lib/types';
export type Connection='connecting'|'live'|'offline'|'stale'|'unconfigured';
const CACHE='delta-public-v1';
export function usePublicData(){
 const [data,setData]=useState<Snapshot>(emptySnapshot);
 const [connection,setConnection]=useState<Connection>('connecting');
 useEffect(()=>{
  let stopped=false, subscribed=false, running=false, rerun=false, timer:ReturnType<typeof setTimeout>|undefined, attempt=0;
  let official=false;
  try{const cached=JSON.parse(localStorage.getItem(CACHE)||'null');if(cached?.mode==='official'&&Array.isArray(cached.events)&&Array.isArray(cached.matches)){setData(cached);setConnection('stale');}}catch{}
  const db=browserDB();
  async function refresh(){
   if(stopped)return;
   if(!navigator.onLine){setConnection('offline');return;}
   if(running){rerun=true;return;}running=true;
   try{
    const res=await fetch('/api/public',{cache:'no-store',signal:AbortSignal.timeout(12000)});
    if(!res.ok)throw new Error('Unavailable');
    const next:Snapshot=await res.json();if(stopped)return;
    official=next.mode==='official';setData(next);
    setConnection(!official?'unconfigured':subscribed?'live':'stale');attempt=0;
    if(official)try{localStorage.setItem(CACHE,JSON.stringify(next));}catch{}
   }catch{if(!stopped){setConnection(navigator.onLine?'stale':'offline');clearTimeout(timer);timer=setTimeout(refresh,Math.min(30000,1000*2**attempt++));}}
   finally{running=false;if(rerun){rerun=false;void refresh();}}
  }
  const channel=db?.channel('delta-public').on('postgres_changes',{event:'*',schema:'public'},()=>{void refresh();}).subscribe(status=>{
   subscribed=status==='SUBSCRIBED';
   if(subscribed)void refresh();else if(official&&!stopped)setConnection(navigator.onLine?'stale':'offline');
  });
  const offline=()=>setConnection('offline');
  const wake=()=>{if(document.visibilityState==='visible')void refresh();};
  window.addEventListener('online',refresh);window.addEventListener('offline',offline);document.addEventListener('visibilitychange',wake);
  void refresh();
  return()=>{stopped=true;clearTimeout(timer);window.removeEventListener('online',refresh);window.removeEventListener('offline',offline);document.removeEventListener('visibilitychange',wake);if(channel)void db?.removeChannel(channel);};
 },[]);
 return {data,connection};
}
