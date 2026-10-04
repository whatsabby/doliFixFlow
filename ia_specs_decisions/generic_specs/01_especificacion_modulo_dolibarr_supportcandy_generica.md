# Especificación — Migración de SupportCandy a Dolibarr para una organización tipo taller

> Versión: 0.1  
> Fecha: 2026-08-25  
> Estado: borrador técnico para preparar IA Agent Spec, SDD y TDD  
> Autor: Equipo del proyecto

## 1. Objetivo

Crear un módulo instalable en Dolibarr que sustituya el uso actual de SupportCandy en WordPress para la gestión de tickets de la organización, manteniendo las funciones operativas actuales y aprovechando al máximo capacidades nativas de Dolibarr.

El módulo no debe limitarse a replicar pantallas de SupportCandy. Debe integrarse con el modelo de Dolibarr para que los tickets puedan convivir con terceros, contactos, usuarios internos, agenda, documentos, presupuestos/facturas, productos/servicios y futuras automatizaciones.

## 2. Alcance funcional

### 2.1 Incluido

- Gestión de tickets de reparación, diagnóstico, mantenimiento y consultas.
- Clientes equivalentes a los customers actuales de SupportCandy.
- Técnicos y administradores como usuarios internos de Dolibarr.
- Estados personalizados con nombre, orden, color y color de fondo.
- Prioridades con colores.
- Categorías.
- Campos personalizados de ticket, cliente y uso interno/agente.
- Listados configurables similares a SupportCandy.
- Filtros estándar: todos, sin resolver, sin asignar, míos y cerrados.
- Asignación de uno o varios técnicos/agentes.
- Hilos de conversación del ticket.
- Notas internas privadas.
- Adjuntos.
- Histórico de cambios relevantes.
- Migración/importación desde SupportCandy.
- API para conectar WordPress, IA, automatizaciones o formularios externos.
- Permisos por rol/capacidad.
- Preparación para sincronización futura WordPress ↔ Dolibarr.

### 2.2 No incluido en la primera fase salvo decisión explícita

- Sustituir todo WordPress como portal público.
- Chat en tiempo real.
- Base de conocimiento pública.
- IA automática respondiendo al cliente sin revisión humana.
- Sincronización bidireccional completa en tiempo real entre ambas bases de datos.
- Rehacer WooCommerce o flujos de venta.

## 3. Principio de arquitectura

### 3.1 Dolibarr nativo primero

Dolibarr ya dispone de un módulo nativo de tickets/helpdesk. Según documentación oficial, permite crear y seguir tickets desde backoffice y también desde una interfaz pública ligera (`/public/ticket/`). El flujo estándar incluye estados como no leído, leído, asignado, en curso, esperando respuesta, cerrado/resuelto y cancelado.

Por tanto, la recomendación es:

1. Activar y usar el módulo nativo **Ticket** de Dolibarr como base funcional siempre que sea viable.
2. Crear un módulo propio, por ejemplo `ticketflow`, que extienda el comportamiento nativo en vez de duplicarlo todo desde cero.
3. Usar **extrafields** de Dolibarr cuando el dato encaje como campo adicional estándar.
4. Crear tablas propias solo para funciones que Dolibarr no cubra bien: estados visuales personalizados, reglas de transición, vistas guardadas avanzadas, mapeo de migración, auditoría específica, sincronización con WordPress/SupportCandy, metadatos de conversación o SLA propios.

### 3.2 Ventajas de extender Dolibarr en vez de clonar SupportCandy

- Menos deuda técnica.
- Mejor integración con terceros/contactos.
- Aprovecha permisos, usuarios, documentos y agenda nativos.
- Facilita relacionar tickets con presupuestos, facturas, pedidos, productos o servicios.
- Reduce duplicidades de clientes y técnicos.
- Permite usar API, hooks y triggers de Dolibarr.

## 4. Inventario actual extraído de SupportCandy en dominio-origen.local

Fuente de extracción: REST API de SupportCandy en WordPress.  
Archivo local de inventario: `research/supportcandy_api_inventory_2026-08-25.json`.

### 4.1 Agentes actuales

| ID SC | Nombre | Tipo |
|---:|---|---|
| 1 | Abby | Agente |
| 4 | Claudia | Agente |
| 3 | Jose del Valle | Agente |
| 2 | dominio-origen.local | Agente |

> Nota: en Dolibarr estos deben mapearse a usuarios internos (`llx_user`) o grupos de usuarios. El usuario `dominio-origen.local` parece candidato a usuario técnico/sistema/importación, no necesariamente una persona real.

### 4.2 Clientes actuales

- Total detectado en SC: **24 customers**.
- Modelo actual: customers de SupportCandy basados en usuarios/datos de WordPress.
- Modelo objetivo: terceros/contactos en Dolibarr.

Recomendación:

- Si el cliente representa una persona particular: crear/usar un **tercero tipo particular** o tercero genérico con contacto asociado, según configuración de Dolibarr.
- Si el cliente representa empresa: crear/usar **tercero empresa** + contacto.
- Mantener una tabla de mapeo `sc_customer_id` ↔ `fk_soc` / `fk_contact` / `wp_user_id`.
- No depender del email como único identificador definitivo, porque hay casos con email sintético o compartido.

### 4.3 Categorías actuales

| ID SC | Categoría |
|---:|---|
| 1 | Consulta general |
| 2 | Reparación |
| 3 | Diagnóstico |
| 4 | Mantenimiento |

Mapeo recomendado:

- Usar categorías/tipos de ticket si Dolibarr lo permite en el módulo Ticket.
- Si no encaja suficientemente, crear un extrafield `lf_category` o una tabla propia `llx_letsfixticket_category`.
- Mantener IDs legacy para importación.

### 4.4 Prioridades actuales

| ID SC | Nombre | Color texto | Color fondo |
|---:|---|---|---|
| 1 | Bajo | `#22940d` | `#c1ffcf` |
| 2 | Medio | `#EB961C` | `#FFEBCE` |
| 3 | Alto | `#ec1010` | `#ffe7e1` |

Mapeo recomendado:

- Si Dolibarr Ticket ya tiene severidad/prioridad, usar el campo nativo para la lógica.
- Guardar colores en tabla propia o configuración del módulo para conservar la apariencia tipo SupportCandy.

### 4.5 Estados actuales personalizados

| Orden | ID SC | Estado | Color texto | Color fondo |
|---:|---:|---|---|---|
| 1 | 1 | 🚀 Nuevo | `#212121` | `#f8bbd0` |
| 2 | 8 | 📦 Pendiente de recepción | `#ffffff` | `#f06292` |
| 3 | 9 | 🏁 Recepcionado por la organización | `#ffffff` | `#ba68c8` |
| 4 | 10 | 🔍 En diagnostico por la organización | `#ffffff` | `#f914f8` |
| 5 | 15 | ❌ Presupuesto rechazado | `#212121` | `#b0bec5` |
| 6 | 13 | 🛠️ En reparacion | `#FFFFFF` | `#c62828` |
| 7 | 3 | 🚚 En espera de recepción de recambio | `#ffffff` | `#fb8c00` |
| 8 | 2 | 💬 En espera de respuesta del cliente | `#212121` | `#fdd835` |
| 9 | 7 | 🕓 En espera de respuesta por la organización | `#ffffff` | `#ef5350` |
| 10 | 6 | ✅ Listo para envio | `#ffffff` | `#66bb6a` |
| 11 | 11 | ✈️ Enviado de vuelta al cliente | `#ffffff` | `#43a047` |
| 12 | 12 | 📬 Recepcionado por el cliente | `#212121` | `#9ccc65` |
| 13 | 4 | 🔒 Cerrado | `#ffffff` | `#26a69a` |
| 14 | 5 | ⚙️ En curso | `#ffffff` | `#42A5F5` |
| 15 | 14 | 👨‍🔧 / 👩‍🔧 Técnico asignado | `#ffffff` | `#1e88e5` |

Observaciones:

- El flujo real de la organización está orientado a reparación física, recepción de dispositivo, diagnóstico, presupuesto, recambio, reparación y devolución.
- Dolibarr tiene estados nativos de ticket, pero probablemente no cubre toda esta granularidad operativa.
- Recomendación: mantener un campo de estado operativo organización separado del estado técnico interno de Dolibarr.

#### 4.5.1 Mapeo propuesto con estado nativo Dolibarr

| Estado organización | Estado Dolibarr sugerido | Comentario |
|---|---|---|
| 🚀 Nuevo | Not read / Read | Ticket recibido, pendiente de clasificación. |
| 👨‍🔧 Técnico asignado | Assigned | Asignación interna hecha. |
| ⚙️ En curso | In progress | Trabajo activo genérico. |
| 📦 Pendiente de recepción | Assigned / In progress | Esperando que llegue o se recoja el equipo. |
| 🏁 Recepcionado por la organización | In progress | Equipo ya en poder de la organización. |
| 🔍 En diagnostico por la organización | In progress | Diagnóstico técnico. |
| ❌ Presupuesto rechazado | Canceled / Closed | Cierre sin reparación; conviene motivo de cierre. |
| 🛠️ En reparacion | In progress | Reparación activa. |
| 🚚 En espera de recepción de recambio | On hold | Bloqueado por pieza. |
| 💬 En espera de respuesta del cliente | Waiting feedback requester | Depende del cliente. |
| 🕓 En espera de respuesta por la organización | On hold / In progress | Depende de acción interna. |
| ✅ Listo para envio | In progress | Reparado/preparado, pendiente logística. |
| ✈️ Enviado de vuelta al cliente | In progress / Closed pending | En tránsito. |
| 📬 Recepcionado por el cliente | Closed/Solved | Entregado. |
| 🔒 Cerrado | Closed/Solved | Cerrado administrativo. |

Requisito importante: el módulo debe permitir configurar qué estados se consideran **abiertos**, **cerrados**, **bloqueados**, **esperando cliente**, **esperando organización**, **resueltos** y **cancelados**.

### 4.6 Campos actuales de SupportCandy

#### 4.6.1 Campos de ticket / sistema

| ID SC | Slug | Nombre | Tipo SC | Ámbito |
|---:|---|---|---|---|
| 1 | `id` | ID | `df_id` | ticket |
| 2 | `customer` | Cliente | `df_customer` | ticket |
| 5 | `subject` | Titulo del ticket | `df_subject` | ticket |
| 6 | `description` | Descripción | `df_description` | ticket |
| 7 | `status` | Estado | `df_status` | ticket |
| 8 | `priority` | Prioridad | `df_priority` | ticket |
| 9 | `category` | Categoría | `df_category` | ticket |
| 10 | `assigned_agent` | Cesionario | `df_assigned_agent` | ticket |
| 11 | `date_created` | Fecha de creación | `df_date_created` | ticket |
| 12 | `date_updated` | Fecha de actualización | `df_date_updated` | ticket |
| 13 | `agent_created` | Agente creado | `df_agent_created` | ticket |
| 14 | `ip_address` | Dirección IP | `df_ip_address` | ticket |
| 15 | `source` | Fuente | `df_source` | ticket |
| 16 | `browser` | Navegador | `df_browser` | ticket |
| 17 | `os` | Sistema Operativo | `df_os` | ticket |
| 18 | `add_recipients` | Destinatarios adicionales | `df_add_recipients` | ticket |
| 19 | `prev_assignee` | Asignado anterior | `df_prev_assignee` | ticket |
| 20 | `date_closed` | Fecha de cierre | `df_date_closed` | ticket |
| 21 | `user_type` | Tipo de usuario | `df_user_type` | ticket |
| 22 | `last_reply_on` | Última respuesta el | `df_last_reply_on` | ticket |
| 23 | `last_reply_by` | Última respuesta por | `df_last_reply_by` | ticket |
| 24 | `tags` | Etiquetas | `df_tags` | ticket |
| 25 | `last_reply_source` | Last Reply Source | `df_last_reply_source` | ticket |

#### 4.6.2 Campos personalizados de cliente

| ID SC | Slug | Nombre | Tipo SC | Opciones |
|---:|---|---|---|---|
| 3 | `name` | Nombre | `df_customer_name` | — |
| 4 | `email` | Correo Electrónico | `df_customer_email` | — |
| 29 | `cust_29` | Apellidos | `cf_textfield` | — |
| 31 | `cust_31` | Modelo | `cf_textarea` | — |
| 32 | `cust_32` | Tipo de dispositivo | `cf_single_select` | Smartphone, Tablet, Ordenador, Consolas, Smartwatch, Periférico, Robótica de Hogar, Batería |

> Nota: en SC aparece `Smarttphone` con doble t. En Dolibarr conviene normalizar a `Smartphone`, pero guardar el valor legacy para migración.

#### 4.6.3 Campos personalizados de ticket / agente

| ID SC | Slug | Nombre | Tipo SC | Ámbito | Opciones |
|---:|---|---|---|---|---|
| 26 | `cust_26` | Marca del equipo | `cf_single_select` | ticket | iPhone, Samsung, Xiaomi, Otros |
| 27 | `cust_27` | Inspección visual recepción | `cf_textfield` | ticket | — |
| 30 | `cust_30` | Inspeción Visual a la recepción | `cf_textfield` | agentonly | — |

> Nota: hay duplicidad/variación entre `cust_27` y `cust_30`; además `Inspeción` contiene una errata. En Dolibarr conviene consolidar como `inspeccion_visual_recepcion`, con visibilidad pública/interna configurable.

### 4.7 Campos visibles en formulario de creación actual

Campos en formulario SC:

1. Nombre
2. Correo Electrónico
3. Titulo del ticket
4. Marca del equipo
5. Tipo de dispositivo
6. Modelo
7. Descripción
8. Categoría

Requisito: el módulo Dolibarr debe permitir configurar qué campos aparecen en:

- Alta pública del ticket.
- Alta desde backoffice.
- Edición por técnico.
- Vista del cliente.
- Vista interna.

### 4.8 Campos visibles en listado actual

Columnas del listado SC:

1. ID
2. Estado
3. Titulo del ticket
4. Nombre
5. Categoría
6. Prioridad
7. Cesionario
8. Fecha de actualización

Ordenaciones disponibles:

- ID
- Estado
- Titulo del ticket
- Nombre
- Categoría
- Prioridad
- Cesionario
- Fecha de actualización

Filtros estándar actuales:

| Slug | Etiqueta | Orden |
|---|---|---|
| `all` | Todo | Fecha actualización DESC |
| `unresolved` | Sin resolver | Fecha actualización DESC |
| `unassigned` | Sin asignar | Fecha actualización DESC |
| `mine` | Mío | Fecha actualización DESC |
| `closed` | Cerrado | Fecha actualización DESC |

## 5. Modelo objetivo en Dolibarr

### 5.1 Entidades nativas a reutilizar

| Necesidad SC | Dolibarr nativo sugerido | Comentario |
|---|---|---|
| Customers | Terceros/contactos | Usar `societe` / `socpeople` según configuración. |
| Técnicos/admins | Usuarios Dolibarr | `llx_user` y grupos/permisos. |
| Ticket principal | Módulo Ticket nativo | Extender antes que duplicar. |
| Conversaciones | Mensajes/notas del ticket o tabla propia | Depende de capacidad nativa y experiencia requerida. |
| Adjuntos | Documentos vinculados | Usar sistema documental de Dolibarr si encaja. |
| Campos extra | Extrafields | Para ticket, tercero/contacto, usuario si aplica. |
| Agenda/citas | Agenda/eventos | Para recogidas, entregas, domicilio, llamadas. |
| Presupuestos | Propuestas/presupuestos | Vincular ticket ↔ presupuesto. |
| Facturación | Facturas/pedidos | Vincular si hay reparación aceptada. |
| Productos/servicios | Productos/servicios | Recambios, mano de obra, diagnósticos. |
| Notificaciones | Sistema email Dolibarr + módulo propio | Plantillas específicas organización. |

### 5.2 Entidades propias recomendadas

#### `llx_letsfixticket_status`

Estados visuales/operativos de la organización.

Campos sugeridos:

- `rowid`
- `entity`
- `code`
- `label`
- `emoji`
- `position`
- `color`
- `bg_color`
- `is_open`
- `is_closed`
- `is_cancelled`
- `is_waiting_customer`
- `is_waiting_letsfix`
- `is_blocked`
- `maps_to_dolibarr_status`
- `active`
- `datec`
- `tms`
- `import_key`

#### `llx_letsfixticket_transition`

Reglas opcionales de transición entre estados.

Campos:

- `rowid`
- `entity`
- `fk_status_from`
- `fk_status_to`
- `requires_permission`
- `requires_assignee`
- `requires_resolution_reason`
- `auto_notify_customer`
- `position`
- `active`

#### `llx_letsfixticket_mapping_sc`

Tabla de trazabilidad de migración.

Campos:

- `rowid`
- `entity`
- `object_type` (`ticket`, `customer`, `agent`, `thread`, `attachment`, `status`, `priority`, `category`, `field_option`)
- `sc_id`
- `dolibarr_table`
- `dolibarr_id`
- `wp_user_id`
- `checksum`
- `migration_batch`
- `date_imported`
- `last_sync`
- `sync_status`
- `sync_error`

#### `llx_letsfixticket_thread`

Solo si la conversación nativa de Dolibarr no cubre bien el hilo tipo SupportCandy.

Campos:

- `rowid`
- `entity`
- `fk_ticket`
- `fk_author_user`
- `fk_author_contact`
- `author_type` (`customer`, `agent`, `system`, `ai`)
- `visibility` (`public`, `private`, `internal`)
- `source` (`browser`, `email`, `api`, `migration`, `ai`, `whatsapp`)
- `body_html`
- `body_text`
- `datec`
- `tms`
- `import_key`

#### `llx_letsfixticket_eventlog`

Auditoría específica.

Campos:

- `rowid`
- `entity`
- `fk_ticket`
- `event_type`
- `old_value`
- `new_value`
- `fk_user`
- `source`
- `datec`
- `ip`
- `context_json`

#### `llx_letsfixticket_saved_view`

Para listados configurables tipo SC.

Campos:

- `rowid`
- `entity`
- `fk_user`
- `name`
- `filters_json`
- `columns_json`
- `sort_field`
- `sort_order`
- `is_shared`
- `is_default`
- `datec`
- `tms`

## 6. Extrafields recomendados

### 6.1 En ticket

| Código Dolibarr sugerido | Origen SC | Tipo | Comentario |
|---|---|---|---|
| `lf_sc_ticket_id` | `id` | integer/string | ID legacy SC. Solo lectura tras migración. |
| `lf_estado_operativo` | `status` | select/table | Puede apuntar a `llx_letsfixticket_status`. |
| `lf_prioridad_visual` | `priority` | select | Si no basta la prioridad nativa. |
| `lf_categoria` | `category` | select | Consulta/Reparación/Diagnóstico/Mantenimiento. |
| `lf_marca_equipo` | `cust_26` | select | iPhone/Samsung/Xiaomi/Otros. |
| `lf_tipo_dispositivo` | `cust_32` | select | Smartphone/Tablet/etc. Aunque era customer field, operativamente puede vivir también en ticket. |
| `lf_modelo_equipo` | `cust_31` | textarea/text | Modelo concreto del equipo. |
| `lf_inspeccion_visual_recepcion` | `cust_27/cust_30` | textarea | Mejor textarea que textfield. |
| `lf_fuente_origen` | `source` | string/select | browser/email/api/whatsapp/etc. |
| `lf_navegador_origen` | `browser` | string | Solo si se quiere mantener histórico. |
| `lf_os_origen` | `os` | string | Solo histórico. |
| `lf_wp_user_id` | customer/wp | integer | Para sincronización con WordPress. |
| `lf_sc_customer_id` | customer | integer | Para migración. |
| `lf_ultimo_autor` | `last_reply_by` | string/int | Puede ser calculado. |
| `lf_fecha_ultima_respuesta` | `last_reply_on` | datetime | Puede ser calculado. |

### 6.2 En tercero/contacto

| Código | Origen SC | Tipo | Comentario |
|---|---|---|---|
| `lf_sc_customer_id` | customer id | integer | ID legacy. |
| `lf_wp_user_id` | WordPress | integer | Para conexión futura. |
| `lf_apellidos` | `cust_29` | text | Si Dolibarr no separa apellidos como se necesita. |
| `lf_dispositivo_habitual` | `cust_31` | textarea | Opcional; quizá mejor en ticket. |
| `lf_tipo_dispositivo_habitual` | `cust_32` | select | Opcional; quizá mejor en ticket. |

### 6.3 En usuario Dolibarr

| Código | Uso |
|---|---|
| `lf_sc_agent_id` | Mapear agente SC a usuario Dolibarr. |
| `lf_es_tecnico` | Diferenciar técnico operativo de administrativo si no basta con grupos. |

## 7. Roles y permisos

### 7.1 Roles funcionales

#### Cliente

- Puede crear ticket desde portal/formulario autorizado.
- Puede ver sus propios tickets.
- Puede responder en hilos públicos.
- Puede adjuntar archivos permitidos.
- No puede ver notas internas.
- No puede reasignar, cambiar estado interno ni ver tickets ajenos.

#### Técnico

- Puede ver tickets asignados.
- Puede responder al cliente si tiene permiso.
- Puede crear notas internas.
- Puede cambiar estados operativos permitidos.
- Puede subir adjuntos técnicos.
- Puede editar campos técnicos como inspección visual, diagnóstico, recambios necesarios.
- No necesariamente puede borrar tickets ni cambiar configuración.

#### Administrador / responsable

- Puede ver todos los tickets.
- Puede asignar/reasignar técnicos.
- Puede configurar estados, prioridades, categorías, campos y vistas.
- Puede cerrar/reabrir tickets.
- Puede ejecutar importaciones y revisar errores.
- Puede gestionar permisos.

#### Usuario sistema / integración

- Puede crear/actualizar tickets vía API.
- Puede importar desde SupportCandy/WordPress.
- Debe tener permisos mínimos necesarios y quedar auditado.

### 7.2 Capacidades inspiradas en SC

SupportCandy expone capacidades diferenciadas por ticket sin asignar, asignado a mí y asignado a otros. Dolibarr debería implementar equivalente:

- `view_unassigned`
- `view_assigned_me`
- `view_assigned_others`
- `reply_unassigned`
- `reply_assigned_me`
- `reply_assigned_others`
- `private_note_unassigned`
- `private_note_assigned_me`
- `private_note_assigned_others`
- `assign_agent_unassigned`
- `assign_agent_assigned_me`
- `assign_agent_assigned_others`
- `change_status_unassigned`
- `change_status_assigned_me`
- `change_status_assigned_others`
- `change_ticket_fields_unassigned`
- `change_ticket_fields_assigned_me`
- `change_ticket_fields_assigned_others`
- `delete_ticket`
- `manage_configuration`
- `run_import`

Implementación sugerida: permisos del módulo Dolibarr + comprobaciones en controladores y API.

## 8. Flujo operativo organización propuesto

### 8.1 Flujo principal de reparación

1. **Nuevo**: entra solicitud por formulario, WordPress, backoffice, email o API.
2. **Técnico asignado**: se asigna responsable.
3. **Pendiente de recepción**: el dispositivo aún no está en organización o pendiente de recogida.
4. **Recepcionado por la organización**: el equipo ya está recibido.
5. **En diagnóstico por la organización**: revisión técnica inicial.
6. **En espera de respuesta del cliente**: presupuesto, autorización o aclaración pendiente del cliente.
7. **Presupuesto rechazado**: cierre/cancelación sin reparación.
8. **En espera de recepción de recambio**: pieza pedida o pendiente.
9. **En reparación**: intervención activa.
10. **Listo para envío/entrega**: reparación finalizada, pendiente de logística.
11. **Enviado de vuelta al cliente**: equipo entregado a transporte o en reparto.
12. **Recepcionado por el cliente**: cliente confirma recepción.
13. **Cerrado**: cierre administrativo.

### 8.2 Flujo de consulta general

1. Nuevo.
2. Técnico/admin asignado.
3. En espera de respuesta por la organización o cliente según proceda.
4. Cerrado.

### 8.3 Flujo de mantenimiento

Similar a reparación, pero permitiendo subtareas recurrentes o agenda.

## 9. Listados y vistas

### 9.1 Vista principal

Debe mostrar por defecto:

- ID / referencia.
- Estado operativo con color.
- Título/asunto.
- Cliente.
- Categoría.
- Prioridad con color.
- Técnico(s) asignado(s).
- Fecha de última actualización.

### 9.2 Filtros mínimos

- Todos.
- Sin resolver.
- Sin asignar.
- Míos.
- Cerrados.
- Pendientes de cliente.
- Pendientes de la organización.
- Pendientes de recambio.
- En diagnóstico.
- En reparación.
- Listos para entregar/enviar.

### 9.3 Búsqueda

Debe buscar por:

- ID/ref.
- Asunto.
- Nombre cliente.
- Email.
- Teléfono si existe en tercero/contacto.
- Modelo.
- Marca.
- Tipo de dispositivo.
- Texto de hilos si es viable.
- Etiquetas.

### 9.4 Vistas guardadas

Requisito deseable:

- Guardar columnas visibles.
- Guardar filtros.
- Guardar orden.
- Vistas privadas por usuario.
- Vistas compartidas para equipo.
- Vista por defecto por rol.

## 10. Pantalla de detalle de ticket

### 10.1 Cabecera

- Referencia Dolibarr.
- ID legacy SC si existe.
- Estado operativo organización.
- Estado nativo Dolibarr.
- Prioridad.
- Categoría.
- Cliente/contacto.
- Técnicos asignados.
- Fechas: creación, actualización, cierre.

### 10.2 Bloques laterales o pestañas

- Datos del cliente.
- Datos del dispositivo.
- Diagnóstico.
- Inspección visual de recepción.
- Presupuesto relacionado.
- Factura/pedido relacionado.
- Adjuntos.
- Historial.
- Notas internas.
- Conversación con cliente.

### 10.3 Acciones rápidas

- Cambiar estado.
- Asignar técnico.
- Añadir respuesta pública.
- Añadir nota interna.
- Adjuntar archivo.
- Crear presupuesto desde ticket.
- Crear evento/cita en agenda.
- Marcar como pendiente de cliente.
- Marcar como pendiente de recambio.
- Cerrar con motivo.
- Reabrir.

## 11. Conversaciones, notas y adjuntos

### 11.1 Tipos de mensaje

- Respuesta pública al cliente.
- Nota interna.
- Evento de sistema.
- Mensaje importado desde SC.
- Mensaje generado por IA pendiente de revisión.

### 11.2 Reglas

- Las notas internas nunca deben mostrarse al cliente.
- Todo mensaje debe tener autor, fecha, origen y visibilidad.
- Adjuntos deben respetar permisos y tipos permitidos.
- Los mensajes importados deben conservar fecha original cuando sea posible.
- Debe quedar trazabilidad de importación.

## 12. Integración con WordPress

### 12.1 Situación actual

- Los customers de SC proceden de WordPress/SupportCandy.
- Se prevé que los clientes sean los mismos en Dolibarr.
- Aún no está decidido cómo conectar ambas bases de datos.

### 12.2 Recomendación de integración

No conectar bases de datos directamente como primera opción. Preferir API.

Opciones ordenadas de menor a mayor acoplamiento:

1. **Importación puntual SC → Dolibarr** usando REST API de SupportCandy.
2. **Sincronización periódica por API** WordPress → Dolibarr.
3. **Webhook desde WordPress** cuando se crea/actualiza usuario o ticket.
4. **Lectura directa de BD WordPress** solo para migración controlada, no como integración viva.
5. **BD compartida o consultas cruzadas permanentes**: no recomendado salvo necesidad fuerte.

### 12.3 Identificadores que deben conservarse

- `sc_ticket_id`.
- `sc_customer_id`.
- `wp_user_id` si se puede obtener.
- Email original.
- Fecha creación original.
- Fecha actualización original.
- Estado/prioridad/categoría original.

## 13. API objetivo del módulo

### 13.1 Endpoints mínimos

Si se expone API REST en Dolibarr o se extiende la existente:

- `GET /ticketflow/tickets`
- `POST /ticketflow/tickets`
- `GET /ticketflow/tickets/{id}`
- `PUT /ticketflow/tickets/{id}`
- `POST /ticketflow/tickets/{id}/threads`
- `GET /ticketflow/tickets/{id}/threads`
- `POST /ticketflow/tickets/{id}/attachments`
- `POST /ticketflow/tickets/{id}/assign`
- `POST /ticketflow/tickets/{id}/status`
- `GET /ticketflow/statuses`
- `GET /ticketflow/priorities`
- `GET /ticketflow/categories`
- `GET /ticketflow/fields`
- `POST /ticketflow/import/supportcandy/dry-run`
- `POST /ticketflow/import/supportcandy/run`

### 13.2 Requisitos API

- Autenticación mediante mecanismo estándar Dolibarr/API key.
- Permisos por endpoint.
- Validación fuerte de campos.
- Respuestas JSON estables.
- Paginación.
- Filtros por estado, asignado, cliente, fecha, categoría, prioridad.
- Idempotencia en importación usando IDs legacy.
- No exponer notas internas a clientes.

## 14. Migración desde SupportCandy

### 14.1 Estrategia recomendada

1. Activar módulo Dolibarr Ticket en entorno de pruebas.
2. Instalar módulo `ticketflow`.
3. Configurar estados, prioridades, categorías y extrafields.
4. Importar catálogos SC: estados, prioridades, categorías, campos y opciones.
5. Importar agentes y mapearlos a usuarios Dolibarr.
6. Importar customers y mapearlos a terceros/contactos.
7. Importar tickets.
8. Importar hilos.
9. Importar adjuntos.
10. Ejecutar verificación cruzada.
11. Congelar SC o dejarlo solo lectura.
12. Redirigir creación de nuevos tickets hacia Dolibarr.

### 14.2 Dry-run obligatorio

El importador debe tener modo dry-run que informe:

- Nº clientes detectados.
- Nº clientes nuevos a crear.
- Nº clientes a vincular con existentes.
- Nº tickets a crear.
- Nº tickets a actualizar/ignorar por ya importados.
- Nº hilos.
- Nº adjuntos.
- Errores de mapeo.
- Campos desconocidos.
- Estados/prioridades/categorías sin correspondencia.

### 14.3 Reglas de idempotencia

- Nunca duplicar ticket si `sc_ticket_id` ya existe.
- Nunca duplicar cliente si `sc_customer_id` ya está mapeado.
- Si se reimporta, actualizar solo campos permitidos.
- Mantener logs de lote.
- Permitir rollback lógico si un lote falla antes de confirmarse.

### 14.4 Datos sensibles

- No registrar contenido completo de mensajes en logs técnicos salvo modo debug protegido.
- No exponer emails/teléfonos en informes compartidos innecesariamente.
- Adjuntos deben tratarse como potencialmente sensibles.

## 15. Configuración del módulo

Pantalla de configuración admin:

- Activar/desactivar estado operativo organización.
- Configurar estados y colores.
- Configurar prioridades y colores.
- Configurar categorías.
- Mapear estados organización ↔ estados Dolibarr.
- Configurar campos visibles por contexto.
- Configurar roles/capacidades.
- Configurar plantillas de email.
- Configurar importación SC: URL WordPress, credenciales/API, modo dry-run.
- Configurar usuario sistema para integraciones.
- Configurar límites de adjuntos.
- Configurar notificaciones.
- Configurar vistas por defecto.

## 16. Notificaciones

### 16.1 Eventos notificables

- Ticket creado.
- Ticket asignado.
- Cambio de estado.
- Respuesta pública del cliente.
- Respuesta pública de la organización.
- Nota interna mencionando a usuario.
- Ticket pendiente demasiado tiempo.
- Presupuesto aceptado/rechazado.
- Ticket cerrado.

### 16.2 Canales

- Email Dolibarr.
- Backoffice Dolibarr.
- Futuro: Telegram/WhatsApp/OpenClaw si se decide.

### 16.3 Reglas

- Cliente solo recibe mensajes públicos.
- Técnicos reciben tickets asignados y menciones.
- Administradores pueden recibir avisos globales.
- Evitar spam en cambios masivos/importaciones.

## 17. IA y automatización futura

El diseño debe permitir que un agente de IA pueda:

- Leer tickets según permisos.
- Resumir historial para técnico.
- Proponer respuesta al cliente sin enviarla automáticamente.
- Clasificar categoría/prioridad sugerida.
- Detectar marca/modelo/tipo de dispositivo desde descripción.
- Generar checklist de diagnóstico.
- Señalar tickets bloqueados o parados.
- Preparar borradores de presupuesto.

Regla: cualquier mensaje externo generado por IA debe quedar como borrador o requerir confirmación humana salvo autorización explícita posterior.

## 18. Seguridad y cumplimiento

- Respetar permisos Dolibarr en UI y API.
- Proteger notas internas.
- Sanitizar HTML de conversaciones.
- Validar adjuntos por extensión, MIME y tamaño.
- Registrar acciones críticas.
- No guardar credenciales de WordPress en claro si se puede evitar.
- Compatible con multi-entidad (`entity`) de Dolibarr.
- Preparado para RGPD: exportación/borrado/anominización razonable de datos personales según política interna.

## 19. Especificación para IA Agent

### 19.1 Rol del agente desarrollador

El agente debe construir un módulo Dolibarr instalable llamado provisionalmente `ticketflow`, priorizando reutilizar el módulo Ticket nativo y extendiéndolo mediante extrafields, hooks, triggers, páginas admin, CSS propio, API e importador desde SupportCandy.

### 19.2 Objetivos del agente

1. Analizar versión concreta de Dolibarr instalada.
2. Confirmar estructura real del módulo Ticket nativo.
3. Crear esqueleto de módulo externo instalable.
4. Definir migraciones SQL.
5. Crear configuración inicial con estados/prioridades/categorías de la organización.
6. Implementar extrafields necesarios.
7. Añadir UI de listados y detalle si el nativo no basta.
8. Implementar importador SupportCandy con dry-run.
9. Implementar pruebas unitarias/funcionales posibles.
10. Documentar instalación y uso.

### 19.3 Restricciones

- No modificar core de Dolibarr salvo necesidad justificada.
- No romper módulo Ticket nativo.
- No exponer datos personales en logs.
- No enviar notificaciones reales en tests/importaciones dry-run.
- Mantener compatibilidad con actualizaciones futuras de Dolibarr.

## 20. SDD — Software Design Document propuesto

### 20.1 Componentes

- Descriptor módulo: `modticketflow.class.php`.
- SQL install: tablas propias + datos iniciales.
- Clases DAO:
  - `ticketflowtatus`
  - `LetsfixTicketTransition`
  - `LetsfixTicketMappingSC`
  - `LetsfixTicketThread` si aplica
  - `ticketflowavedView`
  - `LetsfixTicketImporterSC`
- Páginas admin:
  - configuración general
  - estados
  - prioridades
  - categorías
  - campos
  - importador SC
- Hooks:
  - detalle ticket
  - listado ticket
  - formulario ticket
  - acciones de cambio de estado/asignación
- Triggers:
  - creación ticket
  - actualización ticket
  - cierre ticket
  - creación mensaje
- CSS:
  - badges de estado/prioridad
  - mejoras de listado
- API:
  - endpoints mínimos del apartado 13.

### 20.2 Instalación

Estructura recomendada:

```text
ticketflow/
  admin/
  api/
  class/
  core/modules/modticketflow.class.php
  core/triggers/
  css/
  docs/
  img/
  langs/es_ES/
  lib/
  scripts/
  sql/
```

### 20.3 Datos iniciales

Al activar el módulo:

- Crear tablas propias.
- Insertar estados de la organización.
- Insertar prioridades de la organización.
- Insertar categorías si no se usan nativas.
- Crear extrafields necesarios si no existen.
- Crear permisos del módulo.

### 20.4 Compatibilidad multi-entidad

Todas las tablas propias deben incluir `entity` y filtrar por entidad activa.

### 20.5 Render visual de estado

El listado debe renderizar un badge con:

- emoji opcional.
- label.
- `color`.
- `bg_color`.
- fallback accesible si no hay color.

## 21. TDD — Test Design Document propuesto

### 21.1 Pruebas de instalación

- El módulo aparece en Setup → Modules.
- Se activa sin errores.
- Crea tablas propias.
- Crea datos iniciales.
- Crea extrafields.
- Se desactiva sin borrar datos.
- Se reinstala sin duplicar datos.

### 21.2 Pruebas de permisos

- Cliente no ve notas internas.
- Técnico ve solo tickets asignados si su rol lo exige.
- Admin ve todos.
- Usuario sin permiso no puede cambiar estado.
- Usuario sin permiso no puede reasignar.
- API respeta permisos.

### 21.3 Pruebas de estados

- Se muestran los 15 estados importados/configurados.
- Cada estado mantiene color y fondo.
- Estados cerrados salen de “sin resolver”.
- Estados esperando cliente aparecen en filtro correspondiente.
- Transición inválida se bloquea si hay reglas activas.
- Cierre exige motivo si se configura.

### 21.4 Pruebas de campos

- Alta pública muestra solo campos configurados.
- Backoffice muestra campos técnicos.
- Campo `marca` acepta opciones válidas.
- Campo `tipo_dispositivo` acepta opciones válidas.
- Inspección visual se guarda y recupera.
- Campos legacy no editables quedan bloqueados si se configura.

### 21.5 Pruebas de listado

- Columnas por defecto coinciden con SC.
- Orden por fecha actualización DESC funciona.
- Filtro “Mío” muestra asignados al usuario.
- Filtro “Sin asignar” excluye tickets con técnico.
- Búsqueda por cliente/modelo/asunto funciona.
- Badges de estado/prioridad se renderizan correctamente.

### 21.6 Pruebas de conversación

- Cliente crea respuesta pública.
- Técnico crea respuesta pública.
- Técnico crea nota interna.
- Cliente no recibe ni ve nota interna.
- Adjuntos se vinculan al mensaje/ticket.
- Mensaje conserva autor, fecha, origen y visibilidad.

### 21.7 Pruebas de importación

- Dry-run no escribe datos.
- Importación crea clientes no existentes.
- Importación mapea clientes existentes.
- Importación crea tickets con `sc_ticket_id`.
- Reimportación no duplica tickets.
- Estados SC se mapean correctamente.
- Prioridades SC se mapean correctamente.
- Campos custom se migran.
- Hilos se migran con fecha original.
- Adjuntos se migran o reportan error controlado.
- Errores quedan en log de lote.

### 21.8 Pruebas de API

- Listar tickets con paginación.
- Crear ticket válido.
- Rechazar ticket inválido.
- Cambiar estado con permiso.
- Rechazar cambio sin permiso.
- Añadir mensaje público.
- Añadir nota interna.
- No exponer nota interna en endpoint de cliente.

### 21.9 Pruebas de regresión

- Actualizar Dolibarr no rompe activación del módulo.
- Desactivar módulo no borra tickets nativos.
- Reinstalar mantiene mapeos si no se purga manualmente.
- No se duplican extrafields.

## 22. Preguntas abiertas para cerrar antes de desarrollo

1. ¿Qué versión exacta de Dolibarr está instalada en `core.dominio-origen.local`?
2. ¿El módulo Ticket nativo está ya activo?
3. ¿Queremos portal público de tickets en Dolibarr o mantener formulario en WordPress?
4. ¿Los clientes particulares deben ser terceros individuales o contactos bajo un tercero genérico?
5. ¿Qué estados son realmente finales: `Cerrado`, `Recepcionado por el cliente`, `Presupuesto rechazado`?
6. ¿Qué plazo define “ticket parado” para avisos internos?
7. ¿Qué adjuntos se permiten y tamaño máximo?
8. ¿La IA podrá crear respuestas solo como borrador o también enviar con aprobación?
9. ¿Se migran todos los tickets históricos o solo abiertos + últimos X meses?
10. ¿SupportCandy quedará solo lectura tras migración?

## 23. Criterios de éxito MVP

El MVP se considera válido si:

- El módulo se instala y activa en Dolibarr sin tocar core.
- Permite gestionar tickets con el flujo operativo de la organización.
- Reproduce estados, prioridades, categorías y campos clave de SC.
- Clientes se vinculan a terceros/contactos.
- Técnicos son usuarios Dolibarr.
- Hay listado funcional con filtros principales.
- Hay detalle de ticket con conversación, notas internas y adjuntos.
- Existe importador SC con dry-run e idempotencia.
- Permisos básicos funcionan.
- No se exponen notas internas ni datos sensibles indebidamente.

## 24. Recomendación final

Construir `ticketflow` como capa vertical de la organización sobre el módulo Ticket nativo de Dolibarr, no como sistema paralelo completamente aislado.

La clave no es copiar SupportCandy pantalla por pantalla, sino conservar lo que SC aporta a la operativa real:

- estados visuales claros,
- campos de reparación,
- asignación técnica,
- conversación ordenada,
- filtros rápidos,
- trazabilidad,
- y migración segura.

Dolibarr debe aportar la base empresarial: clientes, usuarios, agenda, documentos, presupuestos, facturas, servicios y permisos.




