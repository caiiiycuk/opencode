---
name: openspec-ru
description: >-
  Russian-language OpenSpec workflow. Use in any project that has an
  `openspec/` directory, whenever the user runs an `/opsx:*` or `/openspec:*`
  command, mentions OpenSpec, a change, proposal, spec, tasks, or asks to
  archive (архивировать, заархивируй) a change. Work artifacts are written in
  Russian; on archive the change is translated to English so that
  `openspec/specs/` and `changes/archive/` stay English. Does not modify
  `openspec/config.yaml`.
license: MIT
---

# OpenSpec на русском

Правила поверх стандартных `/opsx:*` workflow. `openspec/config.yaml` проекта
не менять — он коммитится в репозиторий и должен оставаться общим.

## Приоритет

Если `openspec instructions ...` проекта явно задаёт язык в `context` —
слушать проект. Иначе действуют правила ниже.

## Пока идёт работа — русский

Всё общение с пользователем и все артефакты change (`proposal.md`,
`design.md`, `tasks.md`, `specs/**/spec.md`) — на русском.

На английском остаются:

- структурные заголовки OpenSpec: `## ADDED Requirements`,
  `## MODIFIED Requirements`, `## REMOVED Requirements`,
  `## RENAMED Requirements`, `### Requirement:`, `#### Scenario:`,
  `## Purpose`, `## Requirements`;
- ключевые слова `SHALL` / `MUST` — на них завязана валидация;
- имена changes (kebab-case), пути, код, команды, технические термины.

Заголовок `### Requirement: <name>` существующего требования в блоках
MODIFIED / REMOVED / RENAMED — это идентификатор. Копировать его из
`openspec/specs/<capability>/spec.md` как есть, не переводить, иначе merge
при архивации не найдёт, что менять. Новые требования в ADDED можно
называть по-русски.

## Финализация — английский

Когда пользователь просит заархивировать change или запускает
`/opsx:archive` / `/opsx:bulk-archive`, перед стандартным workflow:

1. Перевести на английский in-place все артефакты в папке change:
   `proposal.md`, `design.md`, `tasks.md`, `specs/**/spec.md`.
   Не менять структуру, заголовки, чекбоксы `- [x]`, код, пути, `SHALL`/`MUST`.
   Заголовки `### Requirement:` из ADDED переводятся; из MODIFIED / REMOVED /
   RENAMED — остаются как в основном спеке.
2. Прогнать `openspec validate --change <name>` (с `--store <id>`, если
   выбран store). При ошибках — починить перевод, не архивировать.
3. Дальше идти обычным archive workflow без изменений. Дельты уже
   английские, поэтому основные спеки в `openspec/specs/` и папка в
   `changes/archive/` получаются на английском.

Переводить до sync, а не во время: после merge archive сверяет дельту с
основным спеком, и русская дельта против английского спека ломает проверку.
