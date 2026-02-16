# Shared AI agent config (Conduit + Claude / Codex / Gemini)

Use Conduit as the common TUI; each machine can run whichever agents are installed (Gemini on personal, Cursor on this box, OpenAI+Claude on the third). This directory holds **versioned templates and docs** so you can keep a common set of MCPs, skills, and workflows across agents.

## Conduit (TUI)

- **Config:** `config/conduit/config.toml` is the template. `setup-apps.sh` can write `~/.conduit/config.toml` from it (using existing `config/conduit/.default_agent` if present). **setup-agents** (run during `setup.sh -i` or manually) asks which default provider to use, installs Conduit and that agent if missing, writes `config/conduit/.default_agent` and `~/.conduit/config.toml`.
- **Default provider:** Chosen in **setup-agents** (1) claude (2) codex (3) gemini. Stored in `config/conduit/.default_agent` (gitignored); that agent is installed if missing.
- **Install:** `./install.sh` installs the Conduit binary; run **setup-agents** to choose default provider and presets.

## Per-agent config locations

| Agent        | User config              | MCP / skills |
|-------------|---------------------------|--------------|
| **Claude Code** | `~/.claude/settings.json`, `~/.claude.json` | MCP in `~/.claude.json`; subagents in `~/.claude/agents/`; project `.mcp.json`, `.claude/` |
| **Codex CLI**   | `~/.codex/config.toml`     | `[mcp_servers.*]` in same file |
| **Gemini CLI**  | `~/.gemini/settings.json` | `mcpServers` in same file |

Sensitive data (API keys, OAuth) lives in those dirs; do **not** symlink the whole `~/.claude` or `~/.gemini`. Symlink or copy only the parts you version (e.g. MCP definitions, shared `settings.json` without secrets).

## Shared MCPs

You already have `config/mcphub/servers.json` (e.g. fetch, github). To mirror MCPs into each agent:

- **Claude Code:** `claude mcp add …` or edit `~/.claude.json` (see [Claude Code MCP](https://docs.claude.com/en/docs/claude-code/mcp)).
- **Codex:** Edit `~/.codex/config.toml`; see `codex/config.toml.example` in this dir for `[mcp_servers]` format.
- **Gemini:** Edit `~/.gemini/settings.json`; see `gemini/settings.json.example` for `mcpServers` shape.

Copy the *logical* list of servers (fetch, github, etc.) from `mcphub/servers.json` into each agent’s format; each uses a different schema.

## Installing agents (per machine)

Install only the agents you use on that machine:

```bash
# One or more:
npm install -g @anthropic-ai/claude-code   # Claude
npm install -g @openai/codex               # OpenAI Codex
npm install -g @google/gemini-cli          # Gemini
```

Then run `conduit` and open a project (Ctrl+N). Conduit discovers agents via PATH.

## Guided setup (default)

When you run `setup.sh -i`, after install and dotfiles/app setup, **setup-agents** runs automatically. It (1) asks which **default provider** to use (claude / codex / gemini), installs Conduit and that agent if missing, and writes `~/.conduit/config.toml`; (2) lets you pick **presets** (product-eng, eng-director, triathlon-coach, state-of-art) and merges the recommended MCPs into Codex and Gemini configs, creates the triathlon plan dir, and emits Claude MCP commands.

You can also run it anytime:

```bash
setup-agents              # from repo root or with ~/bin on PATH
setup-agents --skip-bootstrap   # if base configs already exist
```

- **Presets** live in `config/ai-agents/presets/*.toml`. Each defines MCPs and optional `plan_path` (triathlon) or links (state-of-art).
- **Triathlon:** Plan lives at `~/projects/triathlon/current-plan.md` (created by the script; will eventually sync with Obsidian). Weekly review prompt: `config/ai-agents/triathlon/weekly-review-prompt.md`.
- **Claude:** After the guided run, execute `config/ai-agents/claude-mcp-commands.sh` (or paste its contents) to add the same MCPs to Claude Code. Set the env vars it reminds you of (e.g. `GITHUB_PERSONAL_ACCESS_TOKEN`, `STRAVA_ACCESS_TOKEN`).

Requires **Python 3.11+** (for `tomllib`) and **jq**.

## Bootstrap agent configs (minimal)

If you only want base configs without the guided preset flow:

```bash
bootstrap-agent-config        # copy Codex + Gemini templates if missing
bootstrap-agent-config -f     # overwrite existing ~/.codex/config.toml, ~/.gemini/settings.json
```

This copies the example files. Claude Code uses `~/.claude.json` and `~/.claude/agents/` — add MCP/agents there manually or via `claude mcp add` / the Claude Code config UI.

## Optional: versioned agent configs

To reuse the same MCP/skills across machines:

1. Run `bootstrap-agent-config` (or copy the `.example` files by hand), then add API keys in the copied files.
2. Or symlink only the non-secret parts (e.g. `~/.claude/agents` → `config/ai-agents/claude/agents`) and keep `~/.claude.json` and `~/.claude/settings.json` local.

After that, Conduit + your chosen agents will share a consistent setup. On interactive setup (`setup.sh -i`), **setup-agents** runs and prompts for default provider (and installs it), writes `config/conduit/.default_agent` (gitignored), then runs the preset flow so you can pick MCPs per persona.
