# Matriz de parámetros — `profile=brand` vs `profile=generic`

> Versión: 0.1  
> Fecha: 2026-10-04  
> Estado: lista para ejecución por fases  
> Base: alineada con `01_especificacion_modulo_dolibarr_supportcandy.md` y estrategia dual

## 1) Objetivo

Definir un catálogo único de parámetros para operar dos perfiles en paralelo sin bifurcar el core:

- **Brand**: operación real (propio).
- **Generic**: versión neutra para TFM/demostración.

Regla obligatoria: **ningún valor de marca en código core**; todo sale de configuración.

## 2) Convención de claves

- Prefijo recomendado: `lf.`
- Jerarquía: `dominio.subdominio.clave`
- Tipos: `string`, `bool`, `int`, `enum`, `json`
- Origen: `env`, `db_config`, `seed_catalog`, `runtime`

## 3) Matriz principal

| Clave | Tipo | Brand (propio) | Generic (TFM) | Origen | Prioridad | Impacto |
|---|---|---|---|---|---|---|
| `lf.profile.id` | enum | `brand` | `generic` | env | Alta | Routing global |
| `lf.module.slug` | string | `letsfixtickets` | `ticketflow` | env | Alta | Rutas/API/nombre técnico |
| `lf.module.display_name` | string | `Letsfix Tickets` | `Ticket Flow` | db_config | Alta | UI |
| `lf.brand.enabled` | bool | `true` | `false` | env | Alta | Branding visible |
| `lf.brand.company_name` | string | `Letsfix` | `Organización` | db_config | Alta | Textos |
| `lf.brand.domain_label` | string | `letsfix.es` | `dominio-origen.local` | db_config | Media | Copys e inventario |
| `lf.api.base_prefix` | string | `/api/letsfixtickets` | `/api/ticketflow` | env | Alta | Integraciones |
| `lf.api.idempotency.enabled` | bool | `true` | `true` | env | Alta | Escrituras seguras |
| `lf.api.idempotency.ttl_hours` | int | `24` | `24` | db_config | Alta | Reintentos |
| `lf.api.idempotency.scope` | enum | `method+path+key` | `method+path+key` | env | Alta | Dedupe |
| `lf.import.source_system` | string | `supportcandy` | `supportcandy` | env | Alta | Migración |
| `lf.import.dry_run_default` | bool | `true` | `true` | db_config | Alta | Seguridad |
| `lf.import.resume.enabled` | bool | `true` | `true` | env | Media | Recuperación de lotes |
| `lf.import.conflict_policy` | enum | `update_allowed_fields` | `update_allowed_fields` | db_config | Alta | Idempotencia import |
| `lf.security.internal_notes_hidden` | bool | `true` | `true` | env | Alta | Privacidad |
| `lf.attachments.max_size_mb` | int | `20` | `20` | db_config | Media | Operación |
| `lf.attachments.allowed_mime` | json | `[...]` | `[...]` | db_config | Media | Seguridad |
| `lf.notifications.enabled` | bool | `true` | `true` | env | Media | Comunicación |
| `lf.notifications.send_real_emails` | bool | `true` | `false` | env | Alta | Entorno demo/real |
| `lf.audit.log_level` | enum | `info` | `info` | env | Media | Trazabilidad |
| `lf.catalog.status.source` | enum | `seed+admin` | `seed+admin` | seed_catalog | Alta | Flujo operativo |
| `lf.catalog.priority.source` | enum | `seed+admin` | `seed+admin` | seed_catalog | Media | Operación |
| `lf.catalog.category.source` | enum | `seed+admin` | `seed+admin` | seed_catalog | Media | Operación |
| `lf.ui.default_view` | string | `mis_tickets` | `all_open` | db_config | Baja | UX |
| `lf.testing.dataset_mode` | enum | `masked_real` | `synthetic` | env | Alta | TFM/compliance |

## 4) Matriz de estados (semántica compartida)

> La semántica de negocio debe ser común; cambia el etiquetado/branding visible cuando aplique.

| `status_code` | Semántica | Brand label | Generic label | `is_closed` | `is_waiting_customer` | `is_waiting_internal` |
|---|---|---|---|---:|---:|---:|
| `new` | Ticket creado | 🚀 Nuevo | 🚀 Nuevo | 0 | 0 | 0 |
| `pending_reception` | Aún no recepcionado | 📦 Pendiente de recepción | 📦 Pendiente de recepción | 0 | 0 | 0 |
| `received` | Equipo recepcionado | 🏁 Recepcionado por Letsfix | 🏁 Recepcionado por taller | 0 | 0 | 0 |
| `diagnosis` | Diagnóstico técnico | 🔍 En diagnóstico por Letsfix | 🔍 En diagnóstico interno | 0 | 0 | 1 |
| `assigned` | Técnico asignado | 👨‍🔧/👩‍🔧 Técnico asignado | 👨‍🔧/👩‍🔧 Técnico asignado | 0 | 0 | 0 |
| `in_progress` | Trabajo activo | ⚙️ En curso | ⚙️ En curso | 0 | 0 | 0 |
| `repairing` | Reparación activa | 🛠️ En reparación | 🛠️ En reparación | 0 | 0 | 0 |
| `waiting_spare` | Espera recambio | 🚚 Espera recambio | 🚚 Espera recambio | 0 | 0 | 1 |
| `waiting_customer` | Espera respuesta cliente | 💬 Espera cliente | 💬 Espera cliente | 0 | 1 | 0 |
| `waiting_internal` | Espera respuesta interna | 🕓 Espera Letsfix | 🕓 Espera interno | 0 | 0 | 1 |
| `ready_to_ship` | Listo para entrega | ✅ Listo para envío | ✅ Listo para entrega | 0 | 0 | 0 |
| `shipped` | Enviado | ✈️ Enviado al cliente | ✈️ Enviado | 0 | 0 | 0 |
| `delivered` | Entregado | 📬 Recepcionado por cliente | 📬 Entregado | 1 | 0 | 0 |
| `quote_rejected` | Presupuesto rechazado | ❌ Presupuesto rechazado | ❌ Presupuesto rechazado | 1 | 0 | 0 |
| `closed` | Cerrado definitivo | 🔒 Cerrado | 🔒 Cerrado | 1 | 0 | 0 |

## 5) Matriz de rutas API

| Operación | Plantilla | Brand ejemplo | Generic ejemplo |
|---|---|---|---|
| Listar tickets | `GET /api/{module_slug}/tickets` | `/api/letsfixtickets/tickets` | `/api/ticketflow/tickets` |
| Crear ticket | `POST /api/{module_slug}/tickets` | `/api/letsfixtickets/tickets` | `/api/ticketflow/tickets` |
| Ver ticket | `GET /api/{module_slug}/tickets/{id}` | `/api/letsfixtickets/tickets/123` | `/api/ticketflow/tickets/123` |
| Actualizar ticket | `PUT /api/{module_slug}/tickets/{id}` | `/api/letsfixtickets/tickets/123` | `/api/ticketflow/tickets/123` |
| Añadir hilo | `POST /api/{module_slug}/tickets/{id}/threads` | `/api/letsfixtickets/tickets/123/threads` | `/api/ticketflow/tickets/123/threads` |
| Import dry-run | `POST /api/{module_slug}/import/supportcandy/dry-run` | `/api/letsfixtickets/import/supportcandy/dry-run` | `/api/ticketflow/import/supportcandy/dry-run` |
| Import run | `POST /api/{module_slug}/import/supportcandy/run` | `/api/letsfixtickets/import/supportcandy/run` | `/api/ticketflow/import/supportcandy/run` |

## 6) Reglas de idempotencia operativa

1. Toda escritura (`POST/PUT`) debe aceptar `idempotency_key`.
2. Unicidad recomendada: `(http_method, canonical_path, idempotency_key, actor_id)`.
3. Repetición con misma clave y mismo payload => misma respuesta lógica.
4. Repetición con misma clave y payload distinto => `409 Conflict`.
5. Importación usa además dedupe por `source_system + source_id`.
6. `dry_run=true` nunca persiste datos.

## 7) Orden de implementación (sprintable)

1. Parametrizar `module_slug`, `profile`, `api.base_prefix`.
2. Parametrizar catálogo de estados con `status_code` estable.
3. Introducir `idempotency_key` en capa API.
4. Alinear importador a dedupe dual (`idempotency_key` + `source_id`).
5. Separar branding a archivo/config de perfil.
6. Ejecutar pruebas en ambos perfiles con misma suite.

## 8) Checklist de aceptación

- [ ] No quedan rutas hardcodeadas a marca en el core.
- [ ] `brand` y `generic` arrancan sin cambios de código.
- [ ] Reinstalar módulo no duplica seeds ni tablas.
- [ ] Reintentos API no crean duplicados.
- [ ] Reimportación de SupportCandy no duplica tickets/clientes.
- [ ] Dataset y textos del perfil generic son aptos para TFM.

## 9) Decisiones abiertas

- Confirmar valor final de `lf.attachments.max_size_mb` en producción.
- Definir catálogo mínimo de categorías para perfil generic.
- Definir política de anonimización del dataset TFM (`masked_real` vs `synthetic`).
