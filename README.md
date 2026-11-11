# Delta Esports

Plataforma pública PWA para torneos universitarios. Se continuó el proyecto existente, conservando su identidad, autenticación, portal y estructura.

**Estado:** motor y panel implementados; 39 pruebas automatizadas aprobadas en PostgreSQL embebido. Falta conectar una instancia Supabase real y realizar el ensayo operativo remoto. Sin credenciales se muestran estados vacíos y no se permite operar resultados. `/demo` contiene únicamente ejemplos rotulados.

## Ejecutar

Node 22.13 o posterior. `npm ci`, copiar `.env.example` a `.env.local`, completar variables y ejecutar `npm run dev`.

- `npm test`: permisos, RLS, auditoría, torneos completos y persistencia.
- `npm run typecheck`: TypeScript.
- `npm run build`: alojamiento Sites (Vinext/Workers).
- `npm run build:vercel`: Next.js nativo.

## Entrega

- Eliminación simple y doble, seeds, BYEs, upper/lower, final y reset configurable.
- Puntuaciones BO3/BO5 y fútbol con prórroga y penaltis.
- Resultados atómicos, versiones, idempotencia, avances, campeón y puestos compartidos.
- Administración, permisos, participantes, inscripciones, bracket interactivo y proyector.
- Lectura pública consistente, suscripciones Realtime, reconexión y aviso offline.
- PWA, instalación guiada y cinco QR descargables.

[Configuración y operación](docs/DESPLIEGUE.md) · [Arquitectura y límites](docs/ARQUITECTURA.md)

Aplicar las migraciones `001_foundation` y `002_competition` en orden. Nunca incluir claves privilegiadas en el navegador ni subir `.env.local` a Git. El código contiene una propuesta de identidad Delta; los iconos deben validarse con el organizador si existe una marca oficial distinta.
