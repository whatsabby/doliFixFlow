# Paso a paso — Implementación de tickets Letsfix en Dolibarr

> Versión: 0.1  
> Objetivo: guía sencilla para implementar en Dolibarr una alternativa a SupportCandy usando el módulo nativo de Tickets como base.

## Enfoque recomendado

La mejor estrategia no es clonar SupportCandy desde cero.

La recomendación es:

> Usar el módulo nativo de **Tickets de Dolibarr** como base y crear encima un módulo propio de Letsfix para adaptar el flujo real de reparación.

Esto permite aprovechar lo que Dolibarr ya tiene:

- clientes / terceros / contactos
- usuarios internos
- permisos
- adjuntos
- agenda
- presupuestos
- facturas
- productos y servicios
- API e integraciones

Y desarrollar solo lo específico de Letsfix:

- estados personalizados con colores
- campos de reparación
- vistas/listados tipo SupportCandy
- reglas de flujo
- importador desde SupportCandy
- integración futura con WordPress

---

## 1. Activar y probar Tickets nativo de Dolibarr

Antes de desarrollar nada, empezaría activando el módulo **Tickets** de Dolibarr.

Hay que probar manualmente:

- crear un ticket
- asignarlo a un usuario
- cambiar estado
- añadir mensajes o notas
- adjuntar archivos
- vincularlo a un cliente/tercero
- revisar qué permisos permite
- comprobar si tiene portal público útil

### Objetivo

Entender qué cubre Dolibarr de forma nativa y qué necesita realmente el módulo Letsfix.

---

## 2. Decidir qué se queda nativo y qué será módulo Letsfix

### Usaría Dolibarr nativo para

- ticket base
- clientes, terceros y contactos
- técnicos y administradores como usuarios Dolibarr
- documentos y adjuntos
- agenda/citas si encaja
- presupuestos y facturas vinculadas
- productos/servicios/recambios
- permisos base

### Crearía en el módulo Letsfix

- estados personalizados de reparación
- colores de estados y prioridades
- campos específicos de dispositivo
- inspección visual de recepción
- vistas/listados operativos
- importador desde SupportCandy
- mapeo entre WordPress/SupportCandy y Dolibarr
- reglas propias del flujo de reparación

---

## 3. Crear módulo mínimo `letsfixtickets`

No empezaría por el módulo completo.

Primero haría un módulo mínimo instalable que:

- aparezca en la lista de módulos de Dolibarr
- se pueda activar/desactivar
- no modifique core de Dolibarr
- cree sus tablas/configuración propias si hacen falta
- permita añadir CSS o pequeñas mejoras visuales
- tenga una página básica de configuración

### Objetivo

Tener una base limpia sobre la que iterar.

---

## 4. Crear los estados Letsfix

Después implementaría los estados actuales de SupportCandy adaptados a Dolibarr.

Estados principales:

- 🚀 Nuevo
- 📦 Pendiente de recepción
- 🏁 Recepcionado por Letsfix
- 🔍 En diagnóstico por Letsfix
- 👨‍🔧 / 👩‍🔧 Técnico asignado
- ⚙️ En curso
- 🛠️ En reparación
- 🚚 En espera de recepción de recambio
- 💬 En espera de respuesta del cliente
- 🕓 En espera de respuesta por Letsfix
- ✅ Listo para envío
- ✈️ Enviado de vuelta al cliente
- 📬 Recepcionado por el cliente
- ❌ Presupuesto rechazado
- 🔒 Cerrado

Cada estado debería tener:

- nombre
- color de texto
- color de fondo
- orden
- si está abierto o cerrado
- si está bloqueado
- si espera al cliente
- si espera a Letsfix
- estado nativo Dolibarr equivalente

### Objetivo

Reproducir el flujo real de reparación de Letsfix sin pelearse con Dolibarr.

---

## 5. Añadir campos de reparación

Luego añadiría campos extra al ticket.

Campos mínimos:

- tipo de dispositivo
- marca del equipo
- modelo
- inspección visual de recepción
- prioridad
- categoría
- ID antiguo de SupportCandy
- ID cliente SupportCandy
- ID usuario WordPress si existe
- origen del ticket

Siempre que se pueda, usaría **extrafields de Dolibarr**.

### Objetivo

Que el ticket tenga la información técnica necesaria para trabajar una reparación.

---

## 6. Adaptar la pantalla de detalle del ticket

La ficha del ticket debe ser útil para el técnico.

Debería mostrar claramente:

- datos del cliente
- datos del dispositivo
- estado visible con color
- prioridad
- técnico asignado
- conversación con el cliente
- notas internas
- adjuntos
- inspección visual
- diagnóstico
- presupuesto vinculado
- factura/pedido vinculado si existe

Acciones rápidas deseables:

- cambiar estado
- asignar técnico
- añadir respuesta pública
- añadir nota interna
- adjuntar archivo
- crear presupuesto desde ticket
- crear evento/cita
- cerrar ticket
- reabrir ticket

### Objetivo

Que el técnico no eche de menos SupportCandy.

---

## 7. Crear listado operativo tipo SupportCandy

Después haría un listado práctico para el día a día.

Columnas mínimas:

- ID
- estado
- título/asunto
- cliente
- categoría
- prioridad
- técnico asignado
- fecha de última actualización

Filtros mínimos:

- Todos
- Míos
- Sin asignar
- Sin resolver
- Cerrados
- Pendientes de cliente
- Pendientes de Letsfix
- En diagnóstico
- En reparación
- Esperando recambio
- Listos para entrega/envío

### Objetivo

Que el equipo pueda priorizar y trabajar rápido.

---

## 8. Implementar permisos

Antes de migrar datos reales, cerraría permisos.

### Cliente

- puede crear ticket
- puede ver sus tickets
- puede responder públicamente
- puede adjuntar archivos permitidos
- no puede ver notas internas
- no puede ver tickets de otros clientes

### Técnico

- puede ver tickets asignados
- puede responder si tiene permiso
- puede crear notas internas
- puede cambiar estados permitidos
- puede añadir diagnóstico/inspección
- no necesariamente puede borrar ni configurar

### Administrador

- puede ver todo
- puede asignar/reasignar
- puede configurar estados/campos/vistas
- puede importar desde SupportCandy
- puede cerrar/reabrir tickets

### Usuario sistema / integración

- usado para API/importaciones
- permisos mínimos necesarios
- acciones auditadas

### Objetivo

Evitar fugas de información, sobre todo con notas internas y tickets de clientes.

---

## 9. Crear importador SupportCandy en modo dry-run

No importaría datos directamente al principio.

Primero haría un importador en modo simulación.

El dry-run debe indicar:

- cuántos clientes encuentra
- cuántos tickets encuentra
- cuántos agentes encuentra
- cuántos estados/prioridades/categorías encuentra
- qué campos puede mapear
- qué campos no reconoce
- cuántos datos crearía
- cuántos datos ya existen
- posibles duplicados
- errores o bloqueos

### Objetivo

Saber exactamente qué va a pasar antes de tocar Dolibarr.

---

## 10. Importar datos reales en entorno de prueba

Cuando el dry-run esté limpio, haría una importación en pruebas.

Orden recomendado:

1. importar categorías
2. importar prioridades
3. importar estados
4. mapear agentes SC con usuarios Dolibarr
5. importar/mapear clientes
6. importar tickets
7. importar conversaciones/hilos
8. importar adjuntos
9. verificar resultados

Comprobaciones:

- número de tickets SC vs Dolibarr
- estados correctos
- clientes correctos
- técnicos asignados
- últimos mensajes
- adjuntos principales
- notas internas no visibles al cliente

### Objetivo

Validar migración sin arriesgar producción.

---

## 11. Probar con tickets nuevos

Antes de abandonar SupportCandy, probaría Dolibarr con tickets nuevos.

Casos de prueba reales:

- crear ticket de reparación
- asignar técnico
- marcar pendiente de recepción
- registrar recepción
- añadir inspección visual
- poner en diagnóstico
- pedir respuesta al cliente
- pasar a reparación
- dejar esperando recambio
- marcar listo para entrega
- cerrar ticket

También probaría:

- consulta general
- diagnóstico rechazado
- presupuesto rechazado
- ticket sin asignar
- ticket con nota interna
- ticket con adjunto

### Objetivo

Asegurar que funciona para el trabajo diario, no solo técnicamente.

---

## 12. Conectar WordPress después, no antes

No empezaría conectando bases de datos.

Primero Dolibarr debe funcionar solo.

Después decidiría la integración con WordPress:

- formulario WordPress que crea ticket por API en Dolibarr
- sincronización de usuarios WordPress → Dolibarr
- importación temporal desde SupportCandy
- SupportCandy en solo lectura
- migración completa y apagado de SC

### Recomendación

Evitar conexión directa permanente entre bases de datos si se puede.

Mejor usar API o webhooks.

---

# Orden recomendado real

Yo lo haría en este orden:

1. Probar Tickets nativo de Dolibarr.
2. Crear módulo mínimo `letsfixtickets`.
3. Añadir estados Letsfix con colores.
4. Añadir campos de reparación.
5. Adaptar ficha de ticket.
6. Crear listado operativo.
7. Implementar permisos.
8. Crear importador SupportCandy en dry-run.
9. Migrar datos en entorno de prueba.
10. Probar tickets reales nuevos.
11. Conectar WordPress vía API.
12. Dejar SupportCandy en solo lectura o retirarlo.

---

# MVP recomendado

El primer MVP debería limitarse a:

- módulo instalable
- estados personalizados
- campos de reparación
- listado operativo
- detalle de ticket útil
- permisos básicos
- importador dry-run

No metería todavía:

- IA automática
- sincronización compleja
- portal público avanzado
- automatizaciones profundas
- conexión directa de bases de datos

---

# Decisión clave

La decisión importante es esta:

> Dolibarr debe ser el centro operativo. WordPress puede seguir captando clientes o formularios, pero los tickets deberían vivir en Dolibarr.

Así Letsfix gana una herramienta más conectada con:

- clientes
- reparaciones
- técnicos
- presupuestos
- facturación
- agenda
- histórico
- automatizaciones futuras

---

# Resumen final

No hay que construir un SupportCandy clonado.

Hay que construir una capa Letsfix sobre Tickets de Dolibarr.

SupportCandy aporta la inspiración operativa.  
Dolibarr debe aportar la estructura empresarial.  
El módulo Letsfix une ambas cosas.
