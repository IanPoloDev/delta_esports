# DELTA ESPORTS
## Desarrollo de plataforma profesional de gestión de torneos esports

### 1. OBJETIVO GENERAL

Quiero que desarrolles una aplicación web completa llamada **DELTA ESPORTS**, destinada a organizar, administrar, supervisar y transmitir en tiempo real los resultados de torneos competitivos de videojuegos.

Los primeros videojuegos que administrará la plataforma serán:

- Super Smash Bros. Ultimate
- Mortal Kombat
- EA SPORTS FC 27

El sistema debe estar diseñado para utilizarse en un torneo presencial universitario, pero su arquitectura debe permitir organizar otros eventos y torneos en el futuro.

**No quiero una maqueta, una landing page simple ni un prototipo que solo simule funcionalidades. Quiero construir un producto funcional, profesional y escalable, con base de datos real, autenticación, panel administrativo, gestión de torneos y actualizaciones en tiempo real.**

La aplicación deberá tener dos experiencias principales:

1. **Experiencia administrativa:** utilizada por organizadores, árbitros y staff autorizado.
2. **Experiencia pública:** utilizada por jugadores, espectadores y asistentes para seguir resultados, eliminatorias, posiciones y partidas en vivo.

Ambas deben compartir la información de una misma base de datos, con cambios sincronizados en tiempo real.

---

# 2. IDENTIDAD VISUAL Y DISEÑO

## Nombre de la plataforma

**DELTA ESPORTS**

Utilizar Delta Esports como marca principal en la navegación, el panel de administración, las clasificaciones y las vistas públicas.

## Estilo visual

Quiero una identidad visual inspirada en plataformas de competición esports de primer nivel.

El resultado debe transmitir:

- Profesionalismo.
- Tecnología.
- Competitividad.
- Modernidad.
- Organización.
- Calidad visual premium.

No quiero una estética infantil, caricaturesca, saturada ni con elementos gaming exagerados.

### Paleta de colores propuesta

- Fondo principal: `#080B14`
- Superficies: `#101827`
- Paneles secundarios: `#172235`
- Azul eléctrico: `#00B8FF`
- Violeta: `#7957FF`
- Verde de confirmación: `#16D9A0`
- Rojo de alerta: `#FF5367`
- Texto principal: `#F5F7FF`
- Texto secundario: `#94A3B8`

Estas tonalidades pueden ajustarse para conseguir un resultado más refinado.

### Dirección artística

Utilizar:

- Diseño dark mode premium.
- Tipografía moderna, como Inter o Geist.
- Bordes finos y tarjetas elegantes.
- Gradientes discretos.
- Iconografía Lucide.
- Jerarquías visuales claras.
- Espaciado consistente.
- Interfaces limpias y fáciles de interpretar.
- Resaltados sutiles para partidas activas y ganadores.

Evitar neones excesivos, sombras exageradas, fondos sobrecargados y animaciones que interfieran con la lectura.

## Animaciones

Implementar microinteracciones elegantes utilizando Motion o una alternativa adecuada.

Ejemplos:

- Transiciones suaves entre páginas.
- Aparición progresiva de tarjetas.
- Animación al actualizar puntuaciones.
- Resaltado temporal al avanzar un jugador.
- Transición al declarar un ganador.
- Cambios animados en el ranking.
- Indicador discreto de actualización en vivo.
- Apertura y cierre fluidos de paneles.
- Estados hover y focus profesionales.
- Animaciones especiales, pero sobrias, al anunciar campeones.

Las animaciones deben ser fluidas, no bloquear interacciones y respetar `prefers-reduced-motion`.

---

# 3. ARQUITECTURA Y TECNOLOGÍAS

Propongo utilizar un stack moderno y mantenible.

### Frontend

- Next.js con App Router.
- React.
- TypeScript estricto.
- Tailwind CSS.
- shadcn/ui.
- Lucide Icons.
- Motion.
- React Hook Form.
- Zod.

### Backend e infraestructura

- Supabase.
- PostgreSQL.
- Supabase Auth.
- Supabase Realtime.
- Políticas Row Level Security.
- Operaciones transaccionales en el servidor.
- API y acciones de servidor bien estructuradas.

### Visualización de brackets

Desarrollar un componente especializado en torneos, utilizando SVG, React Flow o una solución técnicamente adecuada.

El bracket debe ser visualmente avanzado, interactivo y conectado directamente con el motor de torneos.

No utilizar una simple colección de tarjetas sin conexiones.

### Calidad técnica

- Arquitectura modular.
- Código reutilizable.
- Componentes tipados.
- Validación de entradas.
- Control de errores.
- Estados de carga.
- Protección de rutas.
- Gestión segura de sesiones.
- Pruebas automatizadas.
- Diseño responsive.
- Optimización de consultas.
- Accesibilidad WCAG 2.2 AA como objetivo.

Seleccionar dependencias mantenidas y compatibles, sin introducir librerías innecesarias.

---

# 4. ROLES Y SISTEMA DE PERMISOS

La plataforma debe contar con un sistema de permisos real.

## Superadministrador

Tiene control completo:

- Crear y editar eventos.
- Crear torneos.
- Administrar usuarios.
- Asignar permisos.
- Configurar formatos de competición.
- Gestionar todos los participantes.
- Editar resultados.
- Resolver disputas.
- Reiniciar competiciones mediante procedimientos seguros.
- Consultar auditorías.
- Publicar anuncios.
- Controlar el estado del evento.

## Organizador

Puede administrar los eventos y torneos específicamente asignados.

Puede:

- Gestionar inscripciones.
- Crear enfrentamientos.
- Configurar horarios.
- Administrar brackets.
- Validar y corregir resultados.
- Gestionar personal autorizado.
- Publicar información del torneo.

No debe administrar eventos ajenos.

## Árbitro / Staff de resultados

Puede:

- Acceder a las partidas asignadas.
- Registrar resultados.
- Consultar participantes.
- Marcar partidas como iniciadas o finalizadas.
- Reportar incidencias.
- Solicitar correcciones.

Los permisos deben poder configurarse por evento y por torneo.

Un árbitro de Mortal Kombat no debe poder editar resultados de Smash Bros. si no tiene autorización.

## Participante

Puede:

- Consultar su perfil.
- Consultar sus próximas partidas.
- Visualizar su historial.
- Consultar sus estadísticas.
- Conocer sus rivales.
- Seguir el progreso del torneo.

No puede modificar puntuaciones oficiales.

## Público / Espectador

No necesita iniciar sesión.

Puede:

- Consultar todos los torneos públicos.
- Ver resultados en tiempo real.
- Visualizar brackets.
- Consultar clasificaciones.
- Revisar partidas finalizadas.
- Identificar participantes clasificados.
- Consultar horarios.
- Seguir el desarrollo de las finales.

**La visualización pública es una función fundamental, no secundaria.**

---

# 5. PANEL DE ADMINISTRACIÓN

Desarrollar un dashboard privado de administración con navegación lateral profesional.

### Navegación sugerida

- Dashboard
- Eventos
- Torneos
- Participantes
- Inscripciones
- Partidas
- Brackets
- Clasificaciones
- Calendario
- Anuncios
- Staff y permisos
- Historial y auditoría
- Configuración

## Dashboard principal

Mostrar indicadores como:

- Total de eventos.
- Torneos activos.
- Participantes inscritos.
- Participantes confirmados.
- Partidas programadas.
- Partidas en progreso.
- Partidas finalizadas.
- Resultados pendientes.
- Próximas finales.
- Incidencias pendientes.

Incluir gráficos, tarjetas de actividad y un feed de eventos recientes.

Ejemplos:

"Se registró el resultado de Smash Ultimate — Ronda 2".

"Jugador Alpha avanza a semifinales".

"Final de Mortal Kombat en progreso".

"Nuevo participante registrado en FC27".

Las estadísticas deben proceder de datos reales.

---

# 6. GESTIÓN DE EVENTOS

Un evento puede contener múltiples torneos independientes.

Ejemplo:

**Evento:** Delta Esports University Championship

**Torneos:**
- Super Smash Bros. Ultimate
- Mortal Kombat
- EA SPORTS FC 27

Cada torneo debe tener sus propios:

- Participantes.
- Formato competitivo.
- Reglas.
- Bracket.
- Calendario.
- Árbitros.
- Puntuaciones.
- Clasificaciones.
- Campeón.

Un usuario puede participar en varios juegos, pero debe registrarse individualmente en cada competición.

## Información de un evento

- Nombre.
- Descripción.
- Imagen o banner.
- Fecha y hora.
- Sede.
- Estado.
- Organizadores.
- Videojuegos participantes.
- Reglamento general.
- Anuncios.
- Patrocinadores opcionales.

Estados del evento:

- Borrador.
- Inscripciones abiertas.
- Inscripciones cerradas.
- Próximamente.
- En curso.
- Finalizado.
- Cancelado.

Configurar zona horaria `America/Panama` por defecto, con fechas almacenadas correctamente.

---

# 7. SISTEMA DE INSCRIPCIONES Y JUGADORES

Crear un módulo completo de participantes.

## Datos del jugador

- ID único.
- Nombre completo (privado cuando corresponda).
- Gamer tag o nombre competitivo.
- Fotografía/avatar opcional.
- Correo electrónico opcional según modalidad de inscripción.
- Teléfono opcional y privado.
- Universidad, facultad o equipo opcional.
- Videojuegos en los que participa.
- Estado de inscripción.
- Fecha de registro.
- Historial competitivo.

### Registro de participantes

El administrador debe poder:

1. Registrar jugadores manualmente.
2. Editar datos.
3. Inscribirlos en distintos torneos.
4. Importar participantes desde CSV.
5. Validar inscripciones.
6. Rechazar inscripciones.
7. Retirar jugadores.
8. Gestionar check-in presencial.
9. Consultar inscritos por videojuego.
10. Detectar duplicados.

Estados:

- Pendiente.
- Aprobado.
- Confirmado.
- Check-in completado.
- Retirado.
- Descalificado.

Agregar un registro público opcional configurable por evento, con aprobación administrativa.

El modelo de datos también debe permitir equipos en una futura ampliación, aunque los torneos iniciales serán individuales.

Nunca exponer correos, teléfonos ni información privada en páginas públicas.

---

# 8. MOTOR DE TORNEOS

Este es el módulo más importante de la aplicación.

Crear un motor de competición sólido, independiente del diseño visual.

Debe administrar:

- Participantes.
- Seeds.
- Rondas.
- Enfrentamientos.
- Puntuaciones.
- Ganadores.
- Perdedores.
- Avances.
- Eliminaciones.
- Reglas.
- Clasificaciones.
- Resultados definitivos.

## Formatos compatibles

### A. Eliminación simple (Single Elimination)

El participante que pierde queda eliminado.

El ganador avanza automáticamente a la siguiente ronda.

### B. Doble eliminación (Double Elimination)

Implementar el sistema de la imagen de referencia.

Debe incluir:

**Upper Bracket / Winners Bracket**

Los participantes comienzan en el cuadro superior.

Los ganadores avanzan.

Los perdedores pasan al cuadro inferior según las conexiones correspondientes.

**Lower Bracket / Losers Bracket**

Los jugadores disponen de una segunda oportunidad.

Si pierden en el lower bracket, quedan eliminados.

**Grand Final**

Se enfrentan el ganador del upper bracket y el ganador del lower bracket.

Soportar reinicio de gran final (Grand Final Reset) cuando corresponda: si gana el participante procedente del lower bracket en la primera gran final, se disputa una segunda final para determinar al campeón.

Esta regla debe poder activarse o desactivarse antes del inicio.

El sistema debe soportar tamaños de participación que no sean potencias de dos, asignando BYEs correctamente.

### C. Fase de grupos

Incluir soporte para grupos con:

- Todos contra todos.
- Victorias.
- Derrotas.
- Empates cuando el videojuego lo permita.
- Puntos de clasificación.
- Diferencia de goles cuando corresponda.
- Criterios de desempate configurables.
- Clasificados automáticos hacia una fase eliminatoria.

### D. Formato suizo

Preparar soporte modular para rondas suizas, con emparejamientos válidos y criterios de desempate.

No confundir la fase suiza con eliminación simple.

## Configuración de competición

Permitir:

- Elegir formato.
- Número de jugadores.
- Generar seeds automáticos.
- Asignar seeds manuales.
- Definir participantes clasificados.
- Elegir partidas al mejor de 3, 5 o 7.
- Configurar desempates.
- Crear las rondas.
- Publicar el bracket.
- Bloquear el bracket antes de iniciar.

No generar enfrentamientos definitivos hasta validar los participantes y las reglas.

---

# 9. VISUALIZADOR PROFESIONAL DE BRACKETS

Inspirarse directamente en la imagen proporcionada.

El bracket debe verse como un cuadro competitivo auténtico, con líneas que conecten enfrentamientos.

## Diseño del bracket

Cada enfrentamiento tendrá una tarjeta compacta que muestre:

- Jugador 1.
- Jugador 2.
- Avatar opcional.
- Seed.
- Puntuación.
- Ganador.
- Estado.
- Número de ronda.
- Horario, si existe.

Usar una disposición horizontal por rondas.

En doble eliminación, mostrar los cuadros superior e inferior de manera ordenada, con la final claramente diferenciada.

## Características visuales

- Líneas de conexión entre partidas.
- Zoom in/out.
- Movimiento horizontal y vertical.
- Opción de ajustar a pantalla.
- Botón para centrar el bracket.
- Resaltado del recorrido de un jugador.
- Tooltips informativos.
- Diferenciación entre winners y losers.
- Visualización de BYEs.
- Indicadores de partidas en vivo.
- Colores discretos para ganadores y perdedores.
- Scroll y navegación fluidos.
- Mini mapa opcional para cuadros grandes.

## Interacción

Cuando el usuario haga clic en un jugador:

- Resaltar su trayectoria.
- Mostrar sus resultados.
- Mostrar su siguiente rival, si está definido.
- Indicar si sigue compitiendo o fue eliminado.

Cuando haga clic en una partida:

- Abrir un panel de detalle.
- Mostrar los competidores.
- Mostrar resultados parciales y finales.
- Mostrar el historial de juegos.
- Indicar el ganador.
- Mostrar el estado y el horario.

## Actualización automática

Cuando un árbitro confirme un resultado:

1. La puntuación se actualiza.
2. El ganador se resalta.
3. El motor calcula su destino.
4. El jugador avanza al enfrentamiento correspondiente.
5. La partida siguiente se actualiza.
6. Las vistas públicas reciben los cambios en tiempo real.
7. Se actualizan las estadísticas derivadas.

**No quiero que se tenga que actualizar manualmente la página para observar los cambios.**

Las conexiones de los cuadros deben ser correctas y basarse en reglas competitivas reales, no en posiciones visuales improvisadas.

---

# 10. SISTEMA DE PUNTUACIONES

Crear un módulo especializado para introducir resultados.

## Flujo administrativo

Un árbitro autorizado debe poder:

1. Seleccionar el torneo.
2. Seleccionar la ronda.
3. Seleccionar la partida.
4. Visualizar los jugadores.
5. Comenzar el enfrentamiento.
6. Introducir los resultados.
7. Revisar los datos.
8. Confirmar el ganador.
9. Finalizar el enfrentamiento.

Los cambios deben registrarse en la base de datos.

## Smash Bros. Ultimate

Permitir:

- Mejor de 3.
- Mejor de 5.
- Mejor de 7 si se configura.
- Registro de victorias por juego.
- Identificación del ganador de cada juego.
- Resultado acumulado del set.
- Avance automático del vencedor.

Ejemplo:

Jugador Alpha: 3

Jugador Bravo: 1

Ganador: Jugador Alpha.

## Mortal Kombat

Permitir:

- Sets al mejor de 3 o 5.
- Victorias por juego.
- Resultado total.
- Ganador del enfrentamiento.
- Historial de juegos si se desea.

Ejemplo:

Jugador Delta: 2

Jugador Echo: 1

Ganador: Jugador Delta.

## EA SPORTS FC 27

El sistema debe manejar puntuaciones futbolísticas.

Permitir:

- Goles del jugador 1.
- Goles del jugador 2.
- Tiempo regular.
- Prórroga opcional.
- Penaltis opcionales.
- Ganador del encuentro.
- Empates cuando la modalidad los permita.

En eliminatorias, no permitir avanzar un enfrentamiento empatado sin aplicar el criterio de desempate establecido.

Ejemplo:

Jugador Alpha: 2 goles

Jugador Bravo: 2 goles

Penaltis: 5-4.

Ganador: Jugador Alpha.

Las reglas del videojuego deben configurarse por torneo y no introducirse como condiciones rígidas en la interfaz.

## Protección de resultados

Agregar:

- Confirmación antes de publicar.
- Validación de resultados.
- Prevención de datos imposibles.
- Prevención de doble envío.
- Control de versiones para evitar conflictos entre árbitros.
- Auditoría de modificaciones.
- Motivo obligatorio para corregir resultados definitivos.
- Opción de bloquear resultados.
- Gestión de incidencias y disputas.

Un resultado incorrecto no debe alterar silenciosamente las fases posteriores.

Si se corrige una partida cuyos resultados ya afectaron enfrentamientos siguientes, el sistema debe identificar dependencias y exigir un procedimiento controlado de corrección.

---

# 11. SISTEMA DE TIEMPO REAL

Implementar un sistema real de sincronización utilizando Supabase Realtime o una arquitectura equivalente.

Cuando el staff registre un resultado, los espectadores deben recibir automáticamente:

- Nueva puntuación.
- Nuevo estado de la partida.
- Ganador.
- Clasificado.
- Cambios en el bracket.
- Actualizaciones de ranking.
- Anuncios de resultados.

## Comportamiento esperado

El espectador puede tener abierto el bracket en su teléfono mientras el árbitro introduce resultados desde una computadora.

Al confirmar el resultado, el teléfono debe reflejar la información sin recargar la página.

Incluir:

- Suscripciones a cambios autorizados.
- Reconexión automática.
- Recuperación de datos tras desconexión.
- Actualización de caché.
- Indicador de conexión.
- Manejo de eventos duplicados.
- Orden correcto de actualizaciones.
- Sincronización de múltiples espectadores.

No utilizar intervalos constantes como único mecanismo de sincronización si existe una solución de eventos.

El sistema debe seguir siendo consistente aunque una conexión se interrumpa temporalmente.

---

# 12. PÁGINA PÚBLICA DEL EVENTO

Crear una experiencia pública independiente del panel administrativo.

Ruta sugerida:

`/eventos/[slug]`

La página debe mostrar:

- Nombre del evento.
- Banner.
- Estado del evento.
- Información general.
- Torneos disponibles.
- Partidas en curso.
- Próximos enfrentamientos.
- Resultados recientes.
- Clasificaciones.
- Brackets.
- Anuncios.

## Página pública de cada videojuego

Ruta sugerida:

`/torneos/[slug]`

Mostrar:

- Nombre del torneo.
- Logo o imagen del juego.
- Formato de competición.
- Cantidad de participantes.
- Estado actual.
- Siguiente partida.
- Partidas en vivo.
- Bracket completo.
- Clasificación.
- Historial de resultados.
- Reglamento.

El público debe poder cambiar rápidamente entre Smash Ultimate, Mortal Kombat y FC27.

Diseñar la experiencia pública pensando principalmente en teléfonos, pero también en pantallas grandes.

---

# 13. CLASIFICACIONES Y POSICIONES

Crear un sistema de clasificación competitivo que refleje el formato real del torneo.

## Ranking general

Mostrar una tabla con:

- Posición.
- Gamer tag.
- Equipo o universidad, si existe.
- Partidas jugadas.
- Victorias.
- Derrotas.
- Puntuación aplicable.
- Estado actual.

Para formatos eliminatorios, mostrar posiciones definitivas cuando puedan calcularse.

Ejemplo:

1. Campeón.
2. Subcampeón.
3. Tercer lugar.
4. Cuarto lugar.
5.º–6.º. Posiciones compartidas cuando corresponda.

No inventar clasificaciones exactas cuando el formato solo permite determinar posiciones empatadas.

## Estadísticas

Agregar información como:

- Porcentaje de victorias.
- Sets ganados.
- Sets perdidos.
- Partidas disputadas.
- Racha actual.
- Rival más reciente.
- Historial de enfrentamientos.

En FC27 incluir:

- Goles a favor.
- Goles en contra.
- Diferencia de goles.

## Podio final

Cuando finalice el torneo, mostrar una presentación especial de:

- Campeón.
- Subcampeón.
- Tercer lugar.

Con animaciones elegantes, nombres de jugadores y elementos gráficos de Delta Esports.

El podio debe derivarse de resultados oficialmente confirmados.

---

# 14. CENTRO DE PARTIDAS EN VIVO

Crear una sección específica llamada **EN VIVO**.

Mostrar todas las partidas que estén desarrollándose.

Cada tarjeta incluirá:

- Videojuego.
- Jugadores.
- Puntuación.
- Ronda.
- Estado.
- Horario.
- Identificador de la partida.

Estados posibles:

- Programada.
- Lista para comenzar.
- En vivo.
- Pendiente de confirmación.
- Finalizada.
- Suspendida.
- En disputa.
- Cancelada.

Los usuarios podrán filtrar por videojuego.

### Animaciones de resultados

Cuando una partida finalice:

- Actualizar las puntuaciones.
- Mostrar al vencedor.
- Resaltar su clasificación.
- Actualizar el bracket.
- Reflejar el cambio en el panel de partidas recientes.

Evitar efectos visuales invasivos y conservar la legibilidad.

---

# 15. MODO PANTALLA COMPLETA PARA EL EVENTO

Este módulo es especialmente importante porque Delta Esports se utilizará en un evento presencial.

Crear un **Presentation Mode** pensado para proyectores, televisores y pantallas LED.

Rutas sugeridas:

`/display/evento/[slug]`

`/display/torneo/[slug]`

## Características

- Interfaz sin navegación innecesaria.
- Tipografía grande.
- Alto contraste.
- Actualización automática.
- Bracket a pantalla completa.
- Resultados destacados.
- Partidas en directo.
- Próximos enfrentamientos.
- Campeones.
- Anuncios.
- Branding Delta Esports.

Incluir modos seleccionables:

1. Bracket.
2. Marcador en vivo.
3. Clasificación.
4. Próximas partidas.
5. Podio.
6. Resumen del evento.

Permitir que el organizador elija qué contenido mostrar.

## Overlay para transmisiones

Crear una vista independiente con diseño compatible con OBS Studio.

Debe permitir mostrar:

- Jugador 1.
- Jugador 2.
- Resultado actual.
- Videojuego.
- Fase del torneo.
- Nombre del evento.

Agregar una variante de fondo transparente apta para Browser Source, evitando exponer herramientas administrativas.

Los resultados deberán actualizarse en tiempo real.

---

# 16. CALENDARIO Y PROGRAMACIÓN

Crear un módulo para organizar las partidas del evento.

Permitir:

- Asignar fecha y hora.
- Seleccionar estación o setup.
- Asignar árbitro.
- Consultar partidos pendientes.
- Ver partidas en curso.
- Reprogramar enfrentamientos.
- Evitar conflictos de horarios de jugadores y estaciones.
- Filtrar por torneo.

## Estaciones de juego

Ejemplos:

- Smash Station 01.
- Smash Station 02.
- Mortal Kombat Station 01.
- FC27 Station 01.
- Main Stage.

Estas estaciones deben ser configurables.

---

# 17. NOTIFICACIONES Y ANUNCIOS

Implementar un centro de notificaciones dentro de la plataforma.

Tipos de anuncios:

- Próxima partida.
- Resultado confirmado.
- Jugador clasificado.
- Inicio de semifinales.
- Inicio de gran final.
- Cambio de horario.
- Torneo finalizado.
- Campeón declarado.

Los administradores podrán publicar anuncios manuales.

El público visualizará un feed de anuncios publicados, ordenado cronológicamente.

No enviar notificaciones privadas al público sin autorización.

---

# 18. PERFIL COMPETITIVO DEL JUGADOR

Cada competidor debe tener una página pública opcional.

Mostrar:

- Gamer tag.
- Avatar.
- Torneos en los que participa.
- Estado competitivo.
- Posición.
- Partidas disputadas.
- Victorias.
- Derrotas.
- Historial de resultados.
- Próximo enfrentamiento, si existe.

Agregar un gráfico o sección de trayectoria dentro del torneo.

Cuando un jugador haya sido eliminado, indicarlo claramente.

Cuando avance a una nueva ronda, mostrar la nueva fase.

---

# 19. UX/UI Y RESPONSIVE

La interfaz debe diseñarse con especial atención a la experiencia de usuario.

## Desktop

- Sidebar administrativo.
- Dashboard con métricas.
- Tablas profesionales.
- Brackets amplios.
- Paneles de detalle.
- Navegación clara.

## Tablet

- Sidebar adaptable.
- Tablas con scroll adecuado.
- Brackets navegables.
- Formularios utilizables.

## Mobile

- Navegación compacta.
- Marcadores grandes y legibles.
- Tablas adaptadas.
- Cards de enfrentamientos.
- Bracket con pan y zoom táctil.
- Acceso rápido a resultados en vivo.

## Principios

- No requerir demasiados clics para registrar un resultado.
- Minimizar errores humanos.
- Mostrar feedback claro.
- Confirmar acciones importantes.
- Formularios fáciles de completar.
- Estados vacíos bien diseñados.
- Skeleton loaders.
- Manejo de errores sin perder información.
- Navegación por teclado.
- Contraste accesible.
- Mensajes en español claros y profesionales.

La experiencia debe ser intuitiva incluso para alguien del staff que utiliza el sistema por primera vez.

---

# 20. BASE DE DATOS

Diseñar un modelo relacional sólido y normalizado.

Entidades sugeridas:

- users
- profiles
- roles
- event_memberships
- tournament_memberships
- events
- tournaments
- tournament_rules
- participants
- teams
- registrations
- check_ins
- stages
- groups
- group_memberships
- seeds
- rounds
- matches
- match_slots
- games
- match_results
- match_dependencies
- standings
- stations
- schedules
- announcements
- disputes
- audit_logs

Puedes reorganizar este modelo si existe una estructura técnicamente mejor.

## Requisitos

- Identificadores únicos.
- Llaves foráneas.
- Restricciones de integridad.
- Índices adecuados.
- Timestamps.
- Migraciones.
- Soft deletes cuando corresponda.
- Registros auditables.
- Separación entre resultados oficiales y datos derivados.
- Operaciones transaccionales.
- Permisos definidos por evento y torneo.

Los resultados finales deben ser la fuente de verdad para los avances y clasificaciones.

La base de datos debe impedir inconsistencias competitivas.

---

# 21. SEGURIDAD

Implementar seguridad desde la primera fase.

Requisitos:

- Autenticación segura.
- Autorización del lado del servidor.
- Roles y permisos persistentes.
- Row Level Security.
- Protección de rutas privadas.
- Validación de formularios.
- Protección contra modificaciones no autorizadas.
- Protección contra asignación de roles por el cliente.
- Limitación de solicitudes sensibles.
- Registro de actividades administrativas.
- Protección de datos personales.
- Variables de entorno seguras.
- No exponer claves privilegiadas al navegador.

El navegador jamás debe decidir por sí mismo si un usuario puede modificar un resultado.

Las escrituras de resultados y los avances automáticos deben ejecutarse de manera atómica en el servidor o mediante funciones seguras de base de datos.

---

# 22. HISTORIAL Y AUDITORÍA

Toda modificación importante debe quedar registrada.

Ejemplo:

**Acción:** Actualización de resultado.

**Usuario:** Árbitro asignado.

**Torneo:** Super Smash Bros. Ultimate.

**Partida:** Upper Bracket — Semifinal 1.

**Resultado anterior:** 1-1.

**Resultado nuevo:** 2-1.

**Fecha:** Fecha y hora exactas.

Registrar también:

- Creación de participantes.
- Eliminaciones administrativas.
- Cambios de seed.
- Modificación de brackets.
- Publicación de resultados.
- Correcciones.
- Descalificaciones.
- Cambios de roles.

Agregar filtros de auditoría para administradores.

---

# 23. IMPORTACIÓN Y EXPORTACIÓN

Permitir:

- Importar participantes mediante CSV.
- Exportar listas de inscritos.
- Exportar clasificaciones.
- Exportar resultados.
- Descargar reportes de partidas.
- Exportar brackets como imagen o PDF.
- Descargar un resumen final del torneo.

Los reportes deben ser legibles y utilizar la identidad de Delta Esports.

Validar los archivos antes de importarlos y mostrar errores por fila.

---

# 24. CONFIGURACIÓN PERSONALIZABLE

Crear una sección de ajustes para permitir:

- Cambiar el nombre del evento.
- Cambiar imágenes.
- Personalizar colores secundarios.
- Configurar reglamentos.
- Seleccionar formatos de competición.
- Ajustar cantidad de participantes.
- Configurar sets por ronda.
- Asignar staff.
- Gestionar estaciones.
- Cambiar los estados del torneo.
- Publicar u ocultar clasificaciones.
- Activar o desactivar inscripciones públicas.
- Personalizar la pantalla de presentación.

Estas opciones deben tener efectos reales en el sistema.

---

# 25. EXPERIENCIA DE USUARIO ESPERADA

## Escenario 1: Inscripción

El administrador entra a Delta Esports.

Crea el torneo de Smash Ultimate.

Registra 16 jugadores.

Elige doble eliminación.

Configura las reglas.

Asigna seeds.

Publica el bracket.

Todos los espectadores pueden visualizar los enfrentamientos iniciales.

## Escenario 2: Resultado en vivo

Dos participantes compiten en Smash.

El árbitro abre la partida desde una tablet.

Introduce:

Jugador Alpha: 2

Jugador Bravo: 1

Confirma el resultado.

Delta Esports:

- Guarda el resultado.
- Declara ganador a Alpha.
- Mueve a Alpha al siguiente encuentro.
- Coloca a Bravo en el lower bracket.
- Actualiza el bracket público.
- Actualiza las estadísticas.
- Registra la operación en auditoría.

Los cambios aparecen en los dispositivos conectados.

## Escenario 3: Gran final

El torneo llega a la gran final.

La pantalla principal muestra:

**DELTA ESPORTS — GRAND FINAL**

Jugador Alpha vs. Jugador Omega.

El staff controla las puntuaciones.

El público observa los cambios en directo.

Si corresponde un Grand Final Reset, el sistema activa la segunda final.

Cuando se confirma el resultado definitivo, Delta Esports:

- Identifica al campeón.
- Completa la clasificación.
- Marca el torneo como finalizado.
- Actualiza las estadísticas.
- Presenta una pantalla especial de campeón.
- Permite exportar los resultados.

---

# 26. CALIDAD Y PRUEBAS

Desarrollar pruebas para los componentes críticos.

## Pruebas del motor de torneos

Verificar:

- Eliminación simple.
- Doble eliminación.
- Número irregular de jugadores.
- Asignación de BYEs.
- Progresión de ganadores.
- Descenso al lower bracket.
- Eliminación definitiva.
- Grand Final Reset.
- Cálculo del campeón.
- Partidas al mejor de N.
- Resolución de empates.
- Descalificaciones.
- Correcciones de resultados.
- Clasificaciones.

## Pruebas de seguridad

Verificar que:

- Un espectador no pueda modificar resultados.
- Un árbitro no pueda editar torneos ajenos.
- Un participante no pueda otorgarse privilegios.
- Dos árbitros no puedan sobrescribir silenciosamente un resultado.
- Las credenciales privilegiadas nunca lleguen al frontend.

## Pruebas de tiempo real

Verificar:

- Actualizaciones simultáneas.
- Reconexión.
- Eventos duplicados.
- Recarga de página.
- Varios espectadores conectados.
- Consistencia entre panel administrativo y vista pública.

Implementar pruebas unitarias, de integración y end-to-end en los flujos esenciales.

---

# 27. DEMOSTRACIÓN INICIAL

Incluir una herramienta para cargar datos de demostración.

Crear tres torneos de ejemplo:

1. Super Smash Bros. Ultimate.
2. Mortal Kombat.
3. EA SPORTS FC 27.

Agregar participantes ficticios, partidas de prueba y diferentes estados competitivos.

Debe existir un escenario de doble eliminación suficientemente completo para probar:

- Upper Bracket.
- Lower Bracket.
- Semifinales.
- Finales.
- Grand Final.
- Ganadores y perdedores.
- Avance automático.

Estos datos deben identificarse claramente como demostración y nunca confundirse con resultados reales.

---

# 28. ESTRUCTURA DE RUTAS

Propuesta inicial:

### Públicas

- `/`
- `/eventos`
- `/eventos/[slug]`
- `/torneos/[slug]`
- `/torneos/[slug]/bracket`
- `/torneos/[slug]/partidas`
- `/torneos/[slug]/clasificacion`
- `/jugadores/[id]`
- `/en-vivo`
- `/display/evento/[slug]`
- `/display/torneo/[slug]`
- `/overlay/[slug]`

### Autenticación

- `/login`
- `/recuperar-contrasena`

### Administración

- `/admin`
- `/admin/eventos`
- `/admin/torneos`
- `/admin/participantes`
- `/admin/inscripciones`
- `/admin/partidas`
- `/admin/brackets`
- `/admin/clasificaciones`
- `/admin/calendario`
- `/admin/staff`
- `/admin/auditoria`
- `/admin/configuracion`

Puedes mejorar la estructura para conseguir una arquitectura limpia y coherente.

---

# 29. ORDEN DE IMPLEMENTACIÓN

Quiero que trabajes con un plan de desarrollo estructurado, evitando construir toda la interfaz con datos falsos antes de desarrollar la lógica.

### Fase 1 — Fundamentos

- Inicializar el proyecto.
- Configurar diseño base.
- Preparar Supabase.
- Diseñar esquema de base de datos.
- Implementar autenticación.
- Crear roles y permisos.
- Construir navegación administrativa y pública.

### Fase 2 — Gestión competitiva

- Eventos.
- Torneos.
- Participantes.
- Inscripciones.
- Check-in.
- Reglas.
- Seeds.

### Fase 3 — Motor de torneos

- Eliminación simple.
- Doble eliminación.
- Sistema de puntuaciones.
- Avance automático.
- Grand Final Reset.
- Corrección segura de resultados.

### Fase 4 — Visualizador competitivo

- Brackets conectados.
- Zoom y navegación.
- Tarjetas de enfrentamientos.
- Interacciones.
- Clasificaciones.
- Perfiles de jugadores.

### Fase 5 — Tiempo real

- Sincronización.
- Panel de partidas en vivo.
- Vista pública.
- Actualizaciones automáticas.
- Gestión de reconexiones.

### Fase 6 — Experiencia profesional

- Dashboard.
- Microanimaciones.
- Pantallas de presentación.
- Overlay OBS.
- Calendario.
- Anuncios.
- Estadísticas.

### Fase 7 — Funciones adicionales

- Fase de grupos.
- Formato suizo.
- Importaciones.
- Exportaciones.
- Auditorías avanzadas.
- Personalización.

### Fase 8 — Validación final

- Pruebas.
- Corrección de errores.
- Seguridad.
- Optimización.
- Accesibilidad.
- Responsive.
- Preparación de despliegue.

Cada fase debe integrarse con las anteriores sin introducir soluciones provisionales difíciles de reemplazar.

---

# 30. CRITERIOS DE ACEPTACIÓN

No considero que la plataforma esté terminada hasta que se puedan completar estos procesos:

1. Un administrador crea un evento y tres torneos.
2. Registra participantes reales.
3. Configura un bracket de doble eliminación.
4. Publica los enfrentamientos.
5. Un árbitro inicia sesión con permisos limitados.
6. Registra los resultados de su torneo.
7. Los jugadores avanzan correctamente.
8. Los perdedores descienden al cuadro inferior.
9. Los espectadores observan los cambios sin recargar.
10. La gran final determina correctamente al campeón.
11. El ranking muestra posiciones correctas.
12. El administrador puede consultar auditorías.
13. La pantalla de presentación muestra resultados reales.
14. Los datos permanecen al cerrar y volver a abrir la aplicación.
15. El sistema funciona en escritorio, tablet y móvil.
16. Los usuarios no autorizados no pueden alterar la competición.

No simules estos flujos con datos estáticos.

---

# 31. INSTRUCCIONES FINALES PARA CODEX

Actúa como un equipo senior de ingeniería compuesto por:

- Arquitecto de software.
- Desarrollador frontend.
- Desarrollador backend.
- Especialista en bases de datos.
- Ingeniero de sistemas en tiempo real.
- Diseñador UX/UI.
- Ingeniero de pruebas.
- Especialista en aplicaciones esports.

Tu objetivo es construir **Delta Esports como un producto real**, no únicamente generar pantallas visualmente atractivas.

Antes de comenzar:

1. Inspecciona el repositorio y los archivos existentes.
2. Identifica las herramientas y dependencias disponibles.
3. Define una arquitectura viable.
4. Establece un plan de implementación.
5. Documenta las decisiones técnicas principales.
6. Identifica los riesgos del motor competitivo.

Después, implementa el proyecto por fases directamente en el código.

### Reglas de trabajo

- No te limites a explicar cómo se desarrollaría: escribe y modifica el código.
- No sustituyas una base de datos real por arrays en memoria.
- No presentes funcionalidades simuladas como terminadas.
- No dejes botones decorativos sin función en los flujos implementados.
- No introduzcas permisos falsos controlados únicamente desde React.
- No marques una fase como terminada sin validar sus criterios.
- Mantén el código organizado.
- Crea componentes reutilizables.
- Documenta las variables de entorno.
- Incluye migraciones y datos de demostración.
- Ejecuta pruebas cuando el entorno lo permita.
- Explica los bloqueos técnicos reales.
- Si falta una credencial o configuración externa, prepara el proyecto para conectarla sin inventar valores.
- Prioriza la integridad de los resultados sobre los efectos visuales.
- Nunca alteres resultados oficiales sin autorización y auditoría.

Puedes mejorar las decisiones técnicas cuando exista una alternativa justificadamente superior, siempre que respetes todos los requisitos funcionales.

**La prioridad absoluta es que el torneo funcione correctamente: participantes, enfrentamientos, resultados, avances, clasificaciones y tiempo real. La segunda prioridad es ofrecer una experiencia UX/UI excepcional.**

El resultado visual debe estar a la altura de una plataforma profesional utilizada durante una competición esports presencial.

Quiero que al abrir Delta Esports se perciba como un sistema competitivo auténtico, moderno, bien diseñado y confiable.

**Comienza con la arquitectura y la implementación de la primera fase, manteniendo un plan claro para completar todas las funcionalidades.**