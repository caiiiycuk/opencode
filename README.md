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

## Skills

| Skill | Что делает |
|-------|-----------|
| `openspec-ru` | Работа с OpenSpec на русском; при архивации change переводится на английский, чтобы `openspec/specs/` оставались английскими. `openspec/config.yaml` проекта не меняет. |

## Как добавить свой skill

Положить `skills/<id>/SKILL.md` и запустить `scripts/update.sh`.
