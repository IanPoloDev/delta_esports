import type {Metadata,Viewport} from 'next';
import {PWAProvider} from '@/components/delta/pwa';
import './globals.css';
export const metadata:Metadata={title:{default:'Delta Esports — Tu arena competitiva',template:'%s · Delta Esports'},description:'Sigue torneos, enfrentamientos, brackets y resultados oficiales. Acceso público desde cualquier dispositivo.',manifest:'/manifest.webmanifest',applicationName:'Delta Esports',appleWebApp:{capable:true,statusBarStyle:'black-translucent',title:'Delta Esports'},icons:{icon:'/favicon.svg',apple:'/icons/apple-touch-icon.png'}};
export const viewport:Viewport={width:'device-width',initialScale:1,themeColor:'#080B14'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="es"><body>{children}<PWAProvider/></body></html>}
