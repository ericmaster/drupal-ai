# Drupal AI — AI Skills for Drupal 11 Development

A production-tested collection of Claude Code skills, agents, commands, and rules for Drupal 11 development. The guidance is checked against Drupal 11.4.7 and avoids APIs scheduled for removal in Drupal 12.

## Install a skill

```bash
npx skills add https://github.com/ericmaster/drupal-ai --skill SKILL_NAME
```

## Available Skills

### Local Development
| Skill | Description |
|---|---|
| `ddev-expert` | DDEV local environment configuration and troubleshooting |
| `docker-local` | Docker Compose local development patterns |

### Drupal Core Patterns
| Skill | Description |
|---|---|
| `drupal-access` | Permissions, access callbacks, `AccessResult`, entity access |
| `drupal-caching` | Cache tags, contexts, max-age, bins, invalidation |
| `drupal-entity-api` | Loading, creating, updating, deleting entities |
| `drupal-events` | Symfony events, `KernelEvents`, services.yml tags |
| `drupal-hooks` | Drupal 11.1+ OOP/procedural hooks; 11.2+ hook ordering |
| `drupal-menus` | `links.menu.yml`, `links.task.yml`, programmatic manipulation |
| `drupal-plugins` | Block, Field, Condition, Filter plugins with attributes |
| `drupal-render` | Render arrays, cache metadata, elements, markup safety |
| `drupal-routes` | `routing.yml`, controllers, parameters, upcasting, links |
| `drupal-security` | CSRF, XSS, SQL injection, route permissions, file uploads |
| `drupal-services` | DI for controllers, forms, plugins, `services.yml` |
| `drupal-state` | State API for runtime persistence across requests |
| `drupal-taxonomy` | Terms, vocabularies, hierarchy, reference fields |

### Forms
| Skill | Description |
|---|---|
| `drupal-form-ajax` | AJAX form callbacks and custom `AjaxCommands` |
| `drupal-form-alter` | `hook_form_alter`, OOP hooks, hiding fields, adding handlers |
| `drupal-form-api` | `FormBase`/`ConfigFormBase`, elements, validate/submit, DI |
| `drupal-form-validation` | `validateForm()`, inline errors, conditional validation |
| `drupal-htmx` | Core HTMX 2.0.4 integration in Drupal 11.3+ |

### Fields & Content
| Skill | Description |
|---|---|
| `drupal-fields` | Field types, widgets, formatters, storage, multi-value access |
| `drupal-paragraphs` | Accessing, rendering, altering paragraph entities |
| `drupal-taxonomy` | Terms, vocabularies, hierarchy, reference fields |

### Frontend
| Skill | Description |
|---|---|
| `drupal-javascript` | Behaviors, `libraries.yml`, `drupalSettings`, AJAX commands |
| `drupal-twig` | Templates, auto-escaping, translation, SDC components |

### Data & Search
| Skill | Description |
|---|---|
| `drupal-queries` | Database abstraction layer — Select, Insert, Update, Delete |
| `drupal-search-api` | Index config, boost processors, field types, reindexing |
| `drupal-migrations` | D7-to-D11 upgrades, CSV/JSON API imports, custom plugins |

### Configuration & Tooling
| Skill | Description |
|---|---|
| `drupal-composer` | Requiring modules, updates, patches via `composer-patches` |
| `drupal-config` | Config import/export, preview, splits, environment syncing |
| `drupal-contrib-mgmt` | Contrib upgrade triage, patches, D11 compatibility |
| `drupal-debugging` | Devel, Drush watchdog, Twig debug, XDebug |
| `drupal-drush` | Drush commands, generators, field creation, scaffolding |

### Testing
| Skill | Description |
|---|---|
| `drupal-dtt` | DTT ExistingSite tests against a live Drupal site |
| `drupal-kernel` | `KernelTestBase` tests for services, DB, hooks, entities |
| `drupal-unit` | `UnitTestCase` for isolated PHP logic, no bootstrap |

## Using with Other AI Tools

Skills are native to Claude Code, but the underlying knowledge is plain markdown — reusable anywhere.

### OpenAI Codex

Codex reads skills from `.codex/skills/`. Symlink it to `.claude/skills/` so both tools share the same installed skills automatically:

```bash
ln -s ../.claude/skills .codex/skills
```

Run once after cloning. Any skill added via `npx skills add` is immediately available to both Claude Code and Codex. See [`.codex/README.md`](.codex/README.md) for details.

### Cursor

Drop the relevant skill content into `.cursor/rules/` — Cursor loads those files as project context rules.

**Manual step:** after installing skills via `npx skills add`, symlink or copy them:

```bash
mkdir -p .cursor/rules
# Copy only the skills relevant to the project; skills are directories containing SKILL.md.
cp .claude/skills/drupal-hooks/SKILL.md .cursor/rules/drupal-hooks.md
cp .claude/skills/drupal-services/SKILL.md .cursor/rules/drupal-services.md
```

### GitHub Copilot

Copilot reads `.github/copilot-instructions.md` as custom instructions.

**Manual step:** concatenate the skills you want into that file:

```bash
cat .claude/skills/drupal-hooks/SKILL.md .claude/skills/drupal-services/SKILL.md >> .github/copilot-instructions.md
```

### Where skill content lives

After running `npx skills add`, each skill is stored as a directory with a `SKILL.md` in `.claude/skills/`. These are plain markdown — copy, symlink, or paste the relevant files into any tool's context system.

```
.claude/skills/
├── drupal-hooks/
│   └── SKILL.md
├── drupal-services/
│   └── SKILL.md
└── ...
```

## Sponsors

Development time sponsored by [heydru!](https://heydru.com)

## Credits

Inspired by and built with reference to:
- [drupal-at-your-fingertips](https://skills.sh/grasmash/drupal-claude-skills/drupal-at-your-fingertips) by Selwyn Polit / Greg Sherwood
- [drupal-expert](https://skills.sh/madsnorgaard/agent-resources/drupal-expert) by Mads Nørgaard

## License

MIT — see [LICENSE](LICENSE)
