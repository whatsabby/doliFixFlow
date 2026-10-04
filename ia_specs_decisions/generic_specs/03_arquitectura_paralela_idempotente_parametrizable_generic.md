# Arquitectura paralela e idempotente — versión propia + versión genérica

> Versión: 0.1  
> Fecha: 2026-10-04  
> Estado: diseño de ejecución dual  
> Alcance: no sustituye documentos previos, los complementa

## 1. Decisión de producto (confirmada)

Se mantienen **dos líneas en paralelo**:

1. **Línea propia (marca/taller)**: para operación real.
2. **Línea genérica (sin marca)**: para TFM y reutilización.

Regla clave: **no se reemplaza lo existente**. Se construye el equivalente genérico en paralelo, compartiendo núcleo técnico parametrizable.

## 2. Principios obligatorios

1. **Idempotencia total** en instalación, migración, sincronización y API.
2. **Parametrización primero**: nada hardcodeado a marca, dominio, estados o textos.
3. **Núcleo común + perfiles**: una base funcional única con variaciones declarativas.
4. **Aislamiento por configuración**: cada línea tiene su perfil, sin bifurcar lógica core.
5. **Compatibilidad hacia atrás**: la línea propia actual sigue operativa.

## 3. Modelo de arquitectura recomendado

### 3.1 Capas

- **Core module**: lógica común de tickets sobre Dolibarr.
- **Profile layer**: branding, vocabulario, presets de estados/campos/permisos.
- **Integration layer**: conectores (SupportCandy, WordPress, API externas).
- **Ops layer**: instalador, migrador, auditoría, métricas, backups, rollback.

### 3.2 Resultado práctico

- La línea propia usa `profile=brand`.
- La línea genérica usa `profile=generic`.
- El código de negocio se comparte; cambia la configuración.

## 4. Qué debe ser parametrizable (siempre)

Todo parámetro debe salir de configuración o catálogo editable:

- Identidad visual: nombre módulo, labels, iconos, colores, textos UI.
- Estados: nombre, orden, color, `is_closed`, `is_waiting_customer`, transiciones.
- Prioridades y categorías.
- Campos custom: definición, validación, visibilidad, obligatoriedad.
- Reglas de permisos por rol.
- Reglas de listado: columnas, filtros, ordenaciones por defecto.
- Reglas de importación: mapping SC → Dolibarr, deduplicación, política de conflictos.
- Integraciones: endpoints, credenciales, timeouts, rate limits, webhooks.
- Notificaciones: plantillas, canales, eventos de disparo.
- Política de adjuntos: tipos MIME, tamaño máximo, retención.

## 5. Contrato de idempotencia (obligatorio)

### 5.1 Instalación / upgrades

- Crear tablas y extrafields con comprobación previa (`create if not exists`).
- Seeds mediante **upsert** con clave natural (`code`, `slug`, `external_id`).
- Reinstalar no duplica ni borra datos operativos.
- Versionado de schema con migraciones incrementales y reejecutables.

### 5.2 Importación SupportCandy

- Cada entidad importada guarda `source_system`, `source_id` y hash de contenido.
- Reimportación del mismo lote = 0 duplicados.
- `dry_run=true` no persiste cambios.
- `resume_token` para continuar lotes interrumpidos.
- Log de lote con conteos: creados, actualizados, ignorados, errores.

### 5.3 API

- Operaciones de escritura con `idempotency_key`.
- Repetición de la misma petición devuelve el mismo resultado lógico.
- Reintentos por red no deben crear tickets/mensajes duplicados.

### 5.4 Tareas programadas

- Jobs con lock distribuido o mutex por lote.
- Ventana de reintento controlada y segura.
- Semáforo para evitar ejecución concurrente del mismo job sobre mismo scope.

## 6. Plan de trabajo en paralelo

### 6.1 Stream A — Propio (continuidad)

- Mantener flujo operativo actual.
- Extraer toda referencia de marca a parámetros de perfil.
- Validar que funcionalmente no cambia el comportamiento esperado.

### 6.2 Stream B — Genérico (TFM)

- Crear perfil genérico sin marcas ni nombres comerciales.
- Sustituir catálogos, textos y ejemplos por neutrales.
- Preparar dataset demo anonimizado.

### 6.3 Entregable compartido

- Un único core técnico reutilizable.
- Dos perfiles versionados y trazables.
- Misma batería de pruebas para ambos perfiles.

## 7. Estructura sugerida de configuración

Ejemplo (conceptual):

```yaml
profile:
  id: generic
  module_name: ticketflow
  branding:
    display_name: "Ticket Flow"
    primary_color: "#1F6FEB"

catalogs:
  statuses: []
  priorities: []
  categories: []

permissions:
  roles: []

import:
  source: supportcandy
  dedup_keys: ["source_system", "source_id"]
  dry_run_default: true

api:
  enforce_idempotency: true
  idempotency_ttl_hours: 24
```

## 8. Criterios de aceptación de la estrategia dual

Se da por válida cuando:

1. Existen dos perfiles ejecutables (propio y genérico).
2. Ambos pasan instalación/reinstalación sin duplicidades.
3. Importación repetida no duplica entidades.
4. API soporta reintentos seguros con `idempotency_key`.
5. No hay referencias de marca hardcodeadas en core.
6. El perfil genérico es presentable de forma académica (TFM).

## 9. Riesgos y mitigación

- **Riesgo**: bifurcar lógica por prisas.  
  **Mitigación**: prohibir forks funcionales; sólo perfiles y flags.

- **Riesgo**: deuda por hardcode residual.  
  **Mitigación**: checklist de revisión “0 strings de marca en core”.

- **Riesgo**: migraciones no repetibles.  
  **Mitigación**: pruebas automáticas de reejecución n veces.

## 10. Siguiente paso recomendado

Tomar el documento funcional base y construir una **matriz de parámetros** (estado actual vs genérico) para transformar los artefactos actuales sin romper la línea propia.

