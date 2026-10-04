# Plan de desarrollo y delivery basado en TDD (lf_specs)

> Versión: 0.1  
> Fecha: 2026-10-04  
> Estado: listo para ejecución  
> Base: `01_especificacion_modulo_dolibarr_supportcandy.md`, `03_arquitectura_paralela_idempotente_parametrizable.md`, `04_matriz_parametros_brand_vs_generic.md`

## 1. Marco de trabajo

Cada fase se ejecuta con este ciclo obligatorio:

1. Definir fase (objetivo, alcance, riesgos, DoD).
2. Definir TDD de fase (casos, fixtures, criterio de verde).
3. Ejecutar `red -> green -> refactor -> desarrollo`.
4. Ejecutar pruebas de salida de fase.
5. Cerrar feature/fase con evidencias.

Regla: no se desarrolla ninguna funcionalidad sin TDD de fase aprobado.

## 2. Fases del proyecto

## Fase 0 — Setup y fundaciones

**Objetivo**
- Dejar operativo el esqueleto del módulo y pipeline de pruebas.

**TDD de fase**
- Instalación correcta.
- Desinstalación correcta.
- Reinstalación idempotente (sin duplicados de tablas/seed/extrafields).
- Arranque correcto en `profile=brand` y `profile=generic`.

**Salida**
- CI smoke en verde en ambos perfiles.

---

## Fase 1 — Configuración parametrizable

**Objetivo**
- Eliminar hardcode de marca y centralizar configuración.

**TDD de fase**
- Resuelve `module_slug=letsfixtickets` para `brand`.
- Resuelve `module_slug=ticketflow` para `generic`.
- Fallbacks por defecto correctos.
- Parámetros inválidos devuelven error controlado.
- Política “sin strings de marca en core” en verde.

**Salida**
- Loader de configuración estable y cubierto por tests.

---

## Fase 2 — Dominio tickets (estados/campos/permisos)

**Objetivo**
- Implementar el flujo funcional de tickets sobre semántica común.

**TDD de fase**
- Estados por `status_code` con flags correctos.
- Transiciones inválidas bloqueadas.
- Visibilidad de notas internas restringida.
- Permisos por rol aplicados (cliente/técnico/admin).
- Render de labels dependiente de perfil sin cambiar semántica.

**Salida**
- Flujo de ticket end-to-end en verde.

---

## Fase 3 — API idempotente

**Objetivo**
- Publicar API estable y segura para operación e integraciones.

**TDD de fase**
- Misma `idempotency_key` + mismo payload => mismo resultado.
- Misma `idempotency_key` + payload distinto => `409`.
- Endpoints sin permiso => `403`.
- Paginación/filtros con shape estable.
- Notas internas nunca expuestas al cliente.

**Salida**
- Contrato API versionado y pruebas de regresión en verde.

---

## Fase 4 — Importador SupportCandy idempotente

**Objetivo**
- Migración segura sin duplicación.

**TDD de fase**
- `dry-run` no persiste datos.
- Reimportación no duplica (`source_system + source_id`).
- `resume_token` continúa lotes interrumpidos.
- Errores parciales no rompen consistencia.
- Mapeos cliente/ticket conservan trazabilidad.

**Salida**
- Informe de migración y rollback lógico validado.

---

## Fase 5 — Hardening y release

**Objetivo**
- Preparar producción con calidad y operación controlada.

**TDD de fase**
- Regresión completa en ambos perfiles.
- Pruebas de carga mínima en endpoints críticos.
- Pruebas de seguridad básicas.
- Upgrade/reinstalación mantienen idempotencia.

**Salida**
- Go/No-Go documentado + acta de release.

## 3. Gates de calidad por fase

- Gate 1: TDD aprobado.
- Gate 2: tests en rojo reproducibles.
- Gate 3: tests de fase en verde.
- Gate 4: refactor sin regresión.
- Gate 5: cierre con evidencias.

Si un gate falla, no se avanza de fase.

## 4. Artefactos obligatorios por fase

- `TDD_Fx.md`
- `TEST_REPORT_Fx.md`
- `CHANGELOG_Fx.md`
- `RETRO_Fx.md`

## 5. Criterios de éxito global

1. Todas las fases cierran gates 1..5.
2. No hay duplicados por reintentos en instalación/API/importación.
3. Ambos perfiles (`brand` y `generic`) pasan la suite crítica.
4. El perfil genérico queda apto para TFM y el brand para operación real.
