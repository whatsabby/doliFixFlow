# doliFixFlow

Working repository to design a Dolibarr ticketing module inspired by SupportCandy, with an **idempotent** and **100% configurable** approach.

## Repository mission

Define, version, and govern the functional and technical specifications of the Dolibarr ticketing project with a **Dolibarr-first** approach, prioritizing:

- Reuse of Dolibarr's native ticketing module.
- Controlled extension only where the core does not cover business needs.
- Traceability of decisions (operational, technical, and delivery).
- TDD-driven development with phased quality gates.

## Operational line (owned)

- [01_especificacion_modulo_dolibarr_supportcandy.md](C:/Users/moren/OneDrive/Documentos/repositorios/doliFixFlow/01_especificacion_modulo_dolibarr_supportcandy.md)
- [02_paso_a_paso_implementacion_tickets_dolibarr.md](C:/Users/moren/OneDrive/Documentos/repositorios/doliFixFlow/02_paso_a_paso_implementacion_tickets_dolibarr.md)

## Generic line (TFM)

- [01_especificacion_modulo_dolibarr_supportcandy_generica.md](C:/Users/moren/OneDrive/Documentos/repositorios/doliFixFlow/01_especificacion_modulo_dolibarr_supportcandy_generica.md)
- [02_paso_a_paso_implementacion_tickets_dolibarr_generico.md](C:/Users/moren/OneDrive/Documentos/repositorios/doliFixFlow/02_paso_a_paso_implementacion_tickets_dolibarr_generico.md)

## Dual-strategy governance

- [03_arquitectura_paralela_idempotente_parametrizable.md](C:/Users/moren/OneDrive/Documentos/repositorios/doliFixFlow/03_arquitectura_paralela_idempotente_parametrizable.md)

## Execution strategy

- The real operational line is maintained.
- A generic, unbranded line is developed in parallel.
- Both lines share one core and differ through configuration profiles.

## Versioning and changelog management

This repository keeps its change history in [CHANGELOG.md](./CHANGELOG.md).

All relevant changes for this plugin must be documented in that file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Custom versioning scheme (3 numbers `X.Y.Z`, not standard SemVer):

- **Z** (last number) → *fix* (🔴 red): bug fix, no new behavior.
- **Y** (middle number) → *minor* (🟡 yellow): non-breaking change or new feature. Resets Z to 0.
- **X** (first number) → *major* (🟢 green): major milestone (new complete roadmap phase). Resets Y and Z to 0.

Governance rule: **for every new version, `CHANGELOG.md` must be updated and the version must be reflected in affected documents**.

