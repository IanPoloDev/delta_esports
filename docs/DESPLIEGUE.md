# Configurar y operar Delta Esports

## Estado real

Código del sistema esencial implementado y validado localmente. La conexión Supabase no está configurada: todavía no hay resultados oficiales ni un torneo operativo remoto. La web vacía y `/demo` no sustituyen el ensayo general.

## 1. Supabase

1. Crea un proyecto dedicado. En SQL Editor ejecuta `supabase/migrations/202611110001_foundation.sql` y después `202611110002_competition.sql`. Si 001 ya está aplicada, ejecuta solo 002. No ejecutes el seed en producción.
2. Comprueba RLS y publicación `supabase_realtime`. Las migraciones las configuran.
3. En Authentication crea/invita la cuenta del organizador. Copia su UUID y ejecuta:

```sql
insert into public.platform_admins(user_id) values ('UUID_REAL_DEL_USUARIO');
```

4. Desactiva registro público de cuentas; invita al staff desde Auth. Las cuentas y contraseñas se gestionan allí; los roles por evento/torneo se asignan desde `/admin` → Permisos usando su UUID. No compartas la cuenta del organizador.
5. Configura Auth Site URL al dominio HTTPS definitivo y permite su ruta `/auth/callback`. Configura SMTP y prueba invitación/recuperación de contraseña.

## 2. Variables y publicación

```dotenv
NEXT_PUBLIC_SUPABASE_URL=https://TU_PROYECTO.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=TU_CLAVE_PUBLICABLE
NEXT_PUBLIC_SITE_URL=https://TU_DOMINIO
```

La URL y clave publicable identifican el proyecto; RLS protege las operaciones. Nunca uses `service_role`, contraseña de base o clave secreta en `NEXT_PUBLIC_*`.

En Sites, configura las variables del proyecto existente y reconstruye/publica con esos mismos valores disponibles durante el build: el cliente incorpora las variables `NEXT_PUBLIC_*`. Cambiar solo el entorno de ejecución no actualiza el bundle ya compilado. No publiques `.env.local`.

Alternativa Vercel: importa este código en tu repositorio Git, selecciona Next.js, usa `npm ci` y `npm run build:vercel` (ver `vercel.json`), configura las variables y despliega. No se ha creado un despliegue Vercel.

Añade un dominio propio en el hosting, copia exactamente sus registros DNS y espera HTTPS activo. Actualiza Auth y `NEXT_PUBLIC_SITE_URL`, reconstruye y vuelve a generar los QR. No se ha proporcionado un dominio propio.

## 3. Operar un torneo

1. Entra por `/login`. En Eventos crea y publica el evento.
2. Crea los torneos con juegos y slugs `smash-ultimate`, `mortal-kombat` y `fc27` para que los QR predeterminados coincidan.
3. Registra gamer tags/equipos en Participantes. En Inscripciones añade cada jugador al torneo y confirma asistencia.
4. En Competición selecciona torneo, configura simple/doble, BO3/BO5 y reset. FC utiliza goles, no sets.
5. Revisa participantes admitidos y seeds. Pulsa Generar bracket y confirma. Se congelan reglas e inscripciones para proteger el cuadro.
6. Publica el torneo. Asigna al árbitro el alcance apropiado en Permisos.
7. El árbitro abre una partida lista y la inicia. Registra puntuación, revisa y confirma el resultado. Ganadores, lower, clasificaciones y campeón se actualizan en una transacción.
8. En FC introduce goles reglamentarios; si hay empate, los goles ADICIONALES de prórroga; si persiste, la tanda. No sumes dos veces la prórroga.
9. Para un error inmediato, el organizador puede reabrir la partida con motivo solo si los enfrentamientos siguientes no comenzaron. Final/reset y resultados con dependientes resueltos están bloqueados para evitar corrupción.
10. Usa Vista pública y Proyector desde Competición. El proyector ofrece directo, siguientes partidas, bracket, clasificación y campeón.

## 4. Ensayo obligatorio antes del evento

- Crear un torneo de ensayo con 16 jugadores; completar ambos cuadros y probar reset.
- Usar un organizador, un árbitro limitado y dos navegadores anónimos. Confirmar que estos últimos no pueden escribir y que ambos reciben resultados sin recargar.
- Intentar confirmar el mismo resultado en dos pestañas: la versión obsoleta debe rechazarse.
- Cerrar/reabrir aplicación y verificar persistencia remota. Desconectar un espectador: debe ver aviso y recuperar los datos al reconectar.
- Revisar móvil/escritorio y proyector. Probar carga simultánea según la asistencia prevista.
- Instalar desde `/instalar` cuando el navegador lo admita. Verificar icono, standalone, caché y actualización en dispositivos físicos. No hay instalación automática universal.
- Descargar los cinco PNG desde `/qr` en el dominio definitivo y escanear cada uno antes de imprimir.

## 5. Pruebas entregadas y límites

`npm test`: 39 pruebas aprobadas sobre PostgreSQL embebido, incluidas RLS, permisos, motor, FC, concurrencia optimista, auditoría y persistencia tras reinicio. TypeScript y compilación Next.js de producción aprobados. La revisión visual utiliza datos de demostración rotulados; no acredita conexión remota.

Pendiente: Supabase real y ensayo anterior, entrega de correos, medición de concurrencia, instalación física y dominio propio. Funciones secundarias no implementadas: suizo, grupos, estadísticas avanzadas, importación masiva y corrección forzada de resultados con descendientes ya iniciados. La identidad gráfica requiere aprobación si hay iconos oficiales externos.
