[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/SkillPanel/serena-setup/releases)
[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-purple.svg)](https://docs.anthropic.com/en/docs/claude-code)

# serena-setup

Claude Code plugin that makes [Serena MCP](https://github.com/oraios/serena) work in git worktrees.

## The Problem

You use git worktrees to work on multiple branches in parallel. You use Serena for semantic code navigation in Claude Code. But when you open a worktree, Serena keeps reading and editing files in your main repo — not the worktree you're actually working in.

This happens because Serena locks its project path at startup and ignores worktrees entirely. The result: Claude's edits land in the wrong directory, and you don't notice until something breaks.

## What This Plugin Does

One slash command — `/serena-setup:serena-setup` — and Serena works in your worktree. The plugin handles everything: copying config, syncing cache and memories, verifying MCP registration, and confirming the setup after restart.

No manual file copying. No guessing which flags are missing. No silent edits in the wrong repo.

## Quick Start

```bash
# Install once
claude plugin add --global gh:SkillPanel/serena-setup

# In any git worktree, start Claude Code and run:
/serena-setup:serena-setup
```

The plugin guides you through a two-step process (run → restart → run again) because Serena requires a fresh session to pick up the new project path.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with plugin support
- [Serena MCP](https://github.com/oraios/serena) registered with `--project-from-cwd` flag
- Git 2.5+ (worktree support)

## Installation

**From GitHub (recommended):**

```bash
claude plugin add --global gh:SkillPanel/serena-setup
```

**Local development:**

```bash
git clone https://github.com/SkillPanel/serena-setup.git
claude --plugin-dir ./serena-setup
```

## Contributing

Issues and pull requests welcome at [github.com/SkillPanel/serena-setup](https://github.com/SkillPanel/serena-setup).

## License

MIT — see [LICENSE](LICENSE) for details.
