# Plan de desarrollo y delivery basado en TDD (lf_specs)

> Versión: 0.1  
> Fecha: 2026-10-04  
> Estado: listo para ejecución  
> Base: `01_especificacion_modulo_dolibarr_supportcandy.md`, `03_arquitectura_paralela_idempotente_parametrizable.md`, `04_matriz_parametros_brand_vs_generic.md`  
> Scope actual: **implementación Letsfix-first**. La generalización queda diferida a futuras breaking changes.

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
- Arranque correcto en perfil Letsfix (`module_slug=letsfixtickets`).

**Salida**
- CI smoke en verde para el perfil Letsfix.

---

## Fase 1 — Configuración parametrizable

**Objetivo**
- Eliminar hardcode de marca y centralizar configuración.

**TDD de fase**
- Resuelve `module_slug=letsfixtickets` para entorno Letsfix.
- No se implementa aún `module_slug=ticketflow` (queda en backlog de generalización).
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
- Render de labels operativos Letsfix sin romper semántica de estados.

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
- Regresión completa del perfil Letsfix.
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
3. El perfil Letsfix pasa la suite crítica end-to-end.
4. El entregable específico de TFM sobre Letsfix queda apto para defensa y operación.

## 6. Nota de alcance (acordada)

- Este plan ejecuta desarrollo **específico para Letsfix**.
- La versión genérica se tratará después, en futuras breaking changes.
- Los 8 puntos abiertos de arranque quedan aparcados como pendientes para retomar más adelante.



## 7. Decisiones de arranque (confirmadas por negocio)

Fecha de captura: 2026-10-04

1. **Versiones objetivo**
   - Instalado actual: Dolibarr `20.0.2`.
   - Objetivo principal: diseñar e implementar para la rama actual superior indicada (`24.0.2`), manteniendo compatibilidad funcional hacia `20.0.2`.
   - Estrategia técnica: *compatibility-first* (feature detection y degradación controlada cuando aplique).

2. **Módulo Ticket nativo**
   - Estado: activado por negocio.
   - Uso previo: no utilizado operativamente (se usaba SupportCandy).
   - Decisión: reutilizar nativo de Dolibarr como base y extender encima (Dolibarr-first).

3. **Entorno**
   - Necesidad crítica: crear entorno de desarrollo/staging aislado antes de tocar producción.
   - Restricción: no asumir riesgo sobre el Dolibarr productivo actual.

4. **Alcance de migración**
   - Migración de histórico: **completo**.

5. **Aprobación de gates**
   - Responsable de aprobación: **Claudia (negocio)**.
   - Modelo operativo: el agente entrega artefactos; negocio descarga/instala/prueba/confirma.

6. **Prioridad de ejecución**
   - Arranque por **Fase 0**.

## 8. Pendientes de cierre rápido (para ejecutar Fase 0 sin bloqueo)

Quedan dos definiciones funcionales simplificadas para cerrar en el arranque:

1. **Roles y permisos (punto 5 original)**
   - Propuesta mínima inicial:
     - Cliente: crea ticket, ve sus tickets, responde, adjunta.
     - Técnico: ve asignados, cambia estados permitidos, notas internas.
     - Admin: acceso total, configuración, importador.
     - Integración: permisos mínimos de API/import.

2. **Contrato de idempotencia API (punto 6 original)**
   - Propuesta mínima inicial:
     - Requisito de `idempotency_key` en `POST`/`PUT` sensibles.
     - TTL: `24h`.
     - Misma key + mismo payload: misma respuesta lógica.
     - Misma key + payload distinto: `409 Conflict`.

Estas dos propuestas se usarán por defecto en Fase 0/Fase 1 salvo corrección explícita de negocio.
