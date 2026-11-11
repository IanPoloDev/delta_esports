# Arquitectura y límites

## Componentes

Next.js App Router y React/TypeScript; alojamiento inicial Vinext sobre Workers y alternativa Next.js nativa en Vercel. Supabase provee Auth, PostgreSQL/RLS y Realtime. La aplicación nunca utiliza almacenamiento local como fuente oficial.

Las rutas privadas verifican usuario y pertenencia al staff en servidor. RLS restringe datos y operaciones por evento/torneo; los contactos están separados de las vistas públicas. La instalación no concede permisos.

## Motor competitivo

La migración 002 contiene el motor transaccional: generación sembrada en potencia de dos, BYEs resueltos sin derrotas, dependencias ganador/perdedor, upper/lower, final y reset. Cada resultado bloquea torneo y partida, valida alcance y versión esperada, comprueba puntuación, registra auditoría, propaga dependencias y recalcula clasificación dentro de la misma transacción. Un UUID de solicitud evita repetir publicaciones.

Los puestos finales se calculan por ronda de eliminación, con empates de posición permitidos. FC usa goles reglamentarios, goles adicionales de prórroga y tanda separada. Los sets utilizan BO3/BO5. No se permiten resultados empatados sin resolución.

La corrección exige organizador y motivo. Solo permite reabrir resultados cuyo avance no haya empezado; se bloquea con dependientes ya iniciados/resueltos y para Grand Final/Reset. No hay invalidación automática de partidas posteriores ni corrección forzada.

## Público y PWA

La API usa un cliente anónimo sin cookies y una instantánea SQL consistente, sin contactos privados. Realtime invalida la vista y provoca una nueva lectura; tras reconexión vuelve a cargar el estado oficial. Se conserva la última instantánea pública con fecha, nunca presentada como directo sin conexión. La instantánea abarca el conjunto visible; para eventos de gran tamaño se necesita paginación/segmentación y medición de carga.

El service worker cachea recursos e interfaz pública, excluye API, autenticación, administración y RSC. Las actualizaciones requieren acción del usuario; las sesiones administrativas no se recargan automáticamente durante una edición. Manifest, iconos, standalone, guía por dispositivo y QR dependen del navegador y HTTPS.

## Validación y pendientes

39 pruebas automatizadas: seguridad de la base, torneos simples/dobles de tamaños regulares e irregulares, BYEs, reset activado/desactivado, campeón, posiciones, fútbol, control de versión, idempotencia, corrección segura y persistencia al reabrir PostgreSQL embebido. No equivalen a una prueba de Supabase cloud.

Pendientes de entorno: ejecutar migraciones remotas, configurar Auth/SMTP y variables, comprobar dos espectadores y un árbitro reales, desconexión/reconexión, carga simultánea y dispositivos físicos PWA. No se garantiza un volumen de espectadores sin medición. La administración carga hasta 1.000 registros por tabla: el alcance probado es el evento universitario, no un archivo histórico ilimitado.

Fuera del alcance esencial: suizo/grupos, invalidación de resultados ya propagados con partidas iniciadas, estadísticas avanzadas, importaciones masivas y personalizaciones complejas. El calendario refleja datos registrados; no incluye optimizador de estaciones.
