# serena-setup

Claude Code plugin that makes [Serena MCP](https://github.com/oraios/serena) work in git worktrees.

## The Problem

You use git worktrees to work on multiple branches in parallel. Serena keeps reading and editing files in your main repo — not the worktree you're actually working in.

## What It Does

One slash command — `/serena-setup:serena-setup` — and Serena works in your worktree:

- Copies cache and memories from the main repo (no re-indexing or onboarding)
- Installs a `post-checkout` hook so future worktrees get cache automatically
- Activates the Serena project for the current session

## Install

```bash
claude plugin marketplace add gh:SkillPanel/claude-plugins
claude plugin install serena-setup
```

## Usage

In any git worktree, start Claude Code and run:

```
/serena-setup:serena-setup
```

Run it once in the main repo to install the post-checkout hook. After that, worktrees created with `claude -w` will have cache ready — just run the slash command to activate the project.

## Prerequisites

Serena must be set up in the main repo first:

**1. Register Serena MCP globally (once):**

```bash
claude mcp add --scope user serena -- \
  uvx --from git+https://github.com/oraios/serena \
  serena start-mcp-server --context=claude-code --project-from-cwd
```

**2. Pre-index the project:**

```bash
uvx --from git+https://github.com/oraios/serena serena project index --timeout 300
```

**3. Run Serena onboarding** — start Claude Code and ask "run Serena onboarding".

**4. Commit project config to git:**

```bash
git add .serena/project.yml
git commit -m 'chore: track serena config'
```

## Local Development

```bash
git clone https://github.com/SkillPanel/claude-plugins.git
claude --plugin-dir ./claude-plugins
```

## License

MIT — see [LICENSE](LICENSE) for details.
