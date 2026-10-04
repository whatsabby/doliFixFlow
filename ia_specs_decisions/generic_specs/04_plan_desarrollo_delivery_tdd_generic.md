# Plan de desarrollo y delivery basado en TDD

> Versión: 0.1  
> Fecha: 2026-10-04  
> Estado: listo para ejecución  
> Base: [03_arquitectura_paralela_idempotente_parametrizable_generic.md](C:/Users/moren/OneDrive/Documentos/repositorios/doliFixFlow/ia_specs_decisions/generic_specs/03_arquitectura_paralela_idempotente_parametrizable_generic.md)

## 1. Marco de ejecución (regla global)

Cada fase se ejecuta con el mismo ciclo:

1. **Definir fase** (objetivo, alcance, riesgos, DoD).
2. **Definir TDD de fase** (casos, fixtures, criterios de verde).
3. **Green + refactor + desarrollo**:
   - escribir tests que fallen,
   - implementar mínimo para pasar,
   - refactorizar manteniendo verde,
   - completar desarrollo funcional.
4. **Pruebas** (unitarias + integración + regresión + no funcionales según aplique).
5. **Cierre de feature/fase** (evidencias, métricas, acta de cierre, backlog residual).

Regla obligatoria: **no se desarrolla nada fuera de fase sin TDD definido y aprobado**.

## 2. Estructura de fases del proyecto

## Fase 0 — Fundaciones técnicas y entorno

**Objetivo**
- Dejar preparado el entorno, estructura del módulo, pipeline y plantilla TDD.

**Entregables**
- Estructura base del módulo.
- Plantilla estándar de casos TDD.
- Pipeline CI con ejecución de tests.
- Convención de perfiles `brand` y `generic`.

**TDD de fase (mínimo)**
- Instala/desinstala sin error.
- Reinstala sin duplicar tablas/seeds.
- Arranca con `profile=brand` y `profile=generic` sin cambios de código.
- Falla de configuración produce error controlado.

**Green + refactor + desarrollo**
- Test de instalación idempotente en rojo → implementación mínima → verde.
- Refactor de bootstrap/config loader sin romper tests.

**Pruebas de salida**
- Smoke CI en ambos perfiles.
- Verificación de encoding UTF-8 y lint Markdown.

**Cierre de fase**
- Checklist DoD firmado.
- Matriz de parámetros enlazada y congelada para la siguiente fase.

---

## Fase 1 — Núcleo de configuración parametrizable

**Objetivo**
- Implementar núcleo de configuración sin hardcode de marca.

**Entregables**
- Loader de configuración por perfil.
- Resolución de `module_slug`, branding y catálogos base.
- Registro central de parámetros y validaciones.

**TDD de fase (mínimo)**
- Resuelve `module_slug=letsfixtickets` en `brand`.
- Resuelve `module_slug=ticketflow` en `generic`.
- Rechaza parámetros inválidos con error claro.
- Fallbacks por defecto funcionan cuando un parámetro opcional no existe.
- No aparecen strings de marca en core (test de política).

**Green + refactor + desarrollo**
- Empezar por tests de resolución y validación.
- Implementar servicio de configuración y factoría de perfiles.
- Refactor para eliminar duplicidad de acceso a config.

**Pruebas de salida**
- Unit tests de config al 100% de reglas críticas.
- Test de regresión “sin hardcode” por búsqueda automatizada.

**Cierre de fase**
- Evidencia de ambos perfiles operativos.
- Acta de “config core estable”.

---

## Fase 2 — Dominio de tickets (estados, campos, permisos)

**Objetivo**
- Implementar flujo de tickets con semántica común y presentación por perfil.

**Entregables**
- Catálogo de estados con `status_code` estable.
- Prioridades/categorías parametrizables.
- Campos técnicos y reglas de visibilidad.
- Permisos por rol.

**TDD de fase (mínimo)**
- Cada `status_code` mapea correctamente a flags (`is_closed`, etc.).
- Transiciones inválidas quedan bloqueadas.
- Cliente no ve notas internas.
- Técnico/administrador respetan permisos definidos.
- Render de labels por perfil cambia texto, no semántica.

**Green + refactor + desarrollo**
- Test-first de motor de estados y autorizaciones.
- Implementación mínima de repositorios/servicios.
- Refactor para separar reglas de dominio de capa UI.

**Pruebas de salida**
- Integración ticket completo: alta → asignación → cierre.
- Regresión de permisos y visibilidad.

**Cierre de fase**
- UAT funcional sobre casos operativos clave.
- Aprobación de flujo end-to-end.

---

## Fase 3 — API idempotente y segura

**Objetivo**
- Exponer API estable para tickets con idempotencia completa.

**Entregables**
- Endpoints CRUD + hilos + adjuntos + estados.
- Soporte `idempotency_key` en escrituras.
- Contratos de error consistentes.

**TDD de fase (mínimo)**
- Misma `idempotency_key` + mismo payload => misma respuesta.
- Misma `idempotency_key` + payload distinto => `409 Conflict`.
- Sin permiso => `403`.
- Nota interna no aparece en endpoints cliente.
- Paginación y filtros devuelven shape estable.

**Green + refactor + desarrollo**
- Contract tests primero (request/response).
- Implementar middleware idempotente.
- Refactor para centralizar validaciones de entrada.

**Pruebas de salida**
- Pruebas de concurrencia básica en endpoints de escritura.
- Pruebas de compatibilidad en ambos perfiles (`/api/letsfixtickets` y `/api/ticketflow`).

**Cierre de fase**
- Publicación de contrato API versionado.
- Evidencia de estabilidad de reintentos.

---

## Fase 4 — Importación SupportCandy idempotente

**Objetivo**
- Migrar datos sin duplicar ni perder trazabilidad.

**Entregables**
- Importador `dry-run` y `run`.
- Mapeo `source_system + source_id`.
- Logs de lote y `resume_token`.

**TDD de fase (mínimo)**
- `dry-run` no persiste datos.
- Reimportación del mismo lote no duplica.
- Lote interrumpido se reanuda correctamente.
- Errores parciales no rompen consistencia global.
- Clientes/tickets mapeados conservan relación origen-destino.

**Green + refactor + desarrollo**
- Test-first por pipeline de importación.
- Implementar dedupe + merge de campos permitidos.
- Refactor de parser/mapping para separarlo del motor de persistencia.

**Pruebas de salida**
- Dataset de prueba controlado + métricas de import.
- Comparativa pre/post con conteos esperados.

**Cierre de fase**
- Informe de migración firmado.
- Plan de rollback lógico validado.

---

## Fase 5 — Hardening, rendimiento y release

**Objetivo**
- Preparar salida a producción con calidad y observabilidad.

**Entregables**
- Suite de regresión completa automatizada.
- Observabilidad mínima (logs, métricas de error y latencia).
- Plan de release, rollback y checklist operativo.

**TDD de fase (mínimo)**
- Regresión completa en verde en ambos perfiles.
- Pruebas de carga mínima de endpoints críticos.
- Pruebas de seguridad básicas (acceso no autorizado, exposición de datos).
- Reinstalación/upgrade idempotente sigue verde.

**Green + refactor + desarrollo**
- Corregir deuda técnica detectada por tests.
- Refactor final orientado a mantenibilidad.

**Pruebas de salida**
- Test plan completo + resultados archivados.
- Smoke en entorno preproducción.

**Cierre de fase**
- Go/No-Go.
- Cierre formal de release y backlog de mejoras.

## 3. Definición estándar de TDD por fase (plantilla)

Para cada fase se debe adjuntar un TDD con:

- **Objetivo de pruebas**.
- **Supuestos y fixtures**.
- **Matriz Given/When/Then**.
- **Casos negativos y bordes**.
- **Criterio de verde** (qué porcentaje/casos son obligatorios).
- **Riesgos cubiertos / no cubiertos**.
- **Evidencia** (logs, reportes, capturas, trazas).

## 4. Quality gates obligatorios

- Gate 1: TDD aprobado antes de desarrollo.
- Gate 2: tests en rojo reproducibles.
- Gate 3: verde completo de fase.
- Gate 4: refactor sin regresión.
- Gate 5: cierre con acta y evidencias.

Si falla un gate, **no avanza la fase**.

## 5. Estrategia de paralelización (propio + genérico)

- Se ejecuta una sola implementación core.
- Validación obligatoria en dos perfiles:
  - `profile=brand`
  - `profile=generic`
- Todo bug corregido debe añadir test de regresión para ambos perfiles.

## 6. Cadencia sugerida (iteración)

Por cada fase:

- Día 1: definición + TDD.
- Día 2-3: green + desarrollo mínimo.
- Día 4: refactor.
- Día 5: pruebas de salida + cierre.

(ajustable según complejidad)

## 7. Artefactos de delivery por fase

- `TDD_Fx.md` (diseño de pruebas de fase).
- `TEST_REPORT_Fx.md` (resultado ejecución).
- `CHANGELOG_Fx.md` (qué cambió).
- `RETRO_Fx.md` (riesgos, deuda, mejoras).

## 8. Criterio de éxito global

El plan se considera exitoso cuando:

1. Todas las fases completan gates 1..5.
2. No hay duplicados en instalación/importación/API por reintentos.
3. Brand y Generic pasan la misma suite crítica.
4. El perfil genérico queda apto para defensa TFM sin acoplamiento de marca.
