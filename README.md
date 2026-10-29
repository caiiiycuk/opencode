# opencode-caiiiycuk

Личный набор для OpenCode: плагины (dcp, ponytail), инструменты (codegraph, rtk) и skills.

## Установка

```bash
git clone git@github.com:caiiiycuk/opencode.git ~/.opencode/config/opencode-caiiiycuk
~/.opencode/config/opencode-caiiiycuk/scripts/update.sh
```

Для обновления запустить тот же скрипт. Путь клона не важен: скрипт находит репо относительно себя.

`scripts/update.sh`:

- ставит или обновляет плагины `@tarquinen/opencode-dcp`, `@dietrichgebert/ponytail` и пишет `~/.config/opencode/dcp.jsonc`;
- ставит или обновляет `codegraph` и `rtk`;
- создаёт `~/.config/opencode/skills/` и делает симлинк на каждый `skills/<id>` из этого репо;
- дописывает содержимое `AGENTS.md` из этого репо блоком между `<!-- CAIIIYCUK_START -->` и `<!-- CAIIIYCUK_END -->` в `~/.config/opencode/AGENTS.md` (повторный запуск заменяет блок, а не дублирует). Правки инструкций делаются в `AGENTS.md` репо, затем запускается скрипт.

## Русский в walkthrough review OpenChamber

```bash
~/.opencode/config/opencode-caiiiycuk/scripts/pathc-walkthrough-ru.sh
```

Патчит установку OpenChamber в `/opt/OpenChamber` (другой путь: `OPENCHAMBER_DIR=...`), не трогая язык интерфейса:

- в `resources/app.asar` добавляет `ru: 'Russian'` в серверный список языков walkthrough (архив перепаковывается через `@electron/asar`, бэкап `app.asar.orig`);
- в `resources/web-dist/assets/useWalkthroughReview-*.js` добавляет `ru` в селектор языка (бэкап `*.orig`).

Нужен `sudo` (файлы в `/opt` принадлежат root) и `npx`. Повторный запуск ничего не меняет. После обновления OpenChamber установщик перезаписывает `/opt` → запустить скрипт снова; если структура минифицированного кода поменялась, скрипт остановится с сообщением, что именно не совпало.

## Skills

| Skill | Что делает |
|-------|-----------|
| `openspec-ru` | Работа с OpenSpec на русском; при архивации change переводится на английский, чтобы `openspec/specs/` оставались английскими. `openspec/config.yaml` проекта не меняет. |

## Как добавить свой skill

Положить `skills/<id>/SKILL.md` и запустить `scripts/update.sh`.
