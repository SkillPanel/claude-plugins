---
name: serena-setup
description: "Use when: (1) starting work in a new git worktree, (2) Serena edits/reads files in wrong directory, (3) Serena's active project path doesn't match current worktree, (4) user reports 'Serena points to main repo'"
allowed-tools: Bash(*/setup-serena.sh), mcp__serena__check_onboarding_performed, mcp__serena__onboarding, mcp__serena__write_memory, mcp__serena__list_memories, mcp__serena__list_dir
---

## Overview

Configures Serena MCP to work in a git worktree. Copies pre-indexed cache from the main repo, installs a `post-checkout` hook for future worktrees, and runs Serena onboarding to activate the project.

`project.yml` and `memories/` should be committed to git — they come with checkout, no copying needed.

## If running in the main repository

Run `setup-serena.sh` — it detects the main repo and installs the post-checkout hook only. Report the output to the user.

## If running in a worktree

**Step 1 — Run setup script:**

```bash
<base-directory>/setup-serena.sh
```

Replace `<base-directory>` with the actual base directory shown at the top of this skill's context.

If it fails, show the error and stop. If it succeeds, **check the output for `[warn]` lines** and report them to the user.

**Step 2 — Activate project:**

Serena MCP is shared across sessions and won't auto-activate the worktree project. Activate it explicitly:

1. Call `activate_project` with the worktree path (`$PWD`)
2. Call `check_onboarding_performed` — should confirm memories exist (they come from git checkout)
3. If no memories: only then run `onboarding`

**Step 3 — Verify:**

Call `list_dir` with `relative_path: "."` to confirm Serena is reading the worktree (not the main repo or a parent directory).

Tell user: "Serena setup complete. Future worktrees will get `.serena/cache` automatically via post-checkout hook."

## Common Mistakes

| Mistake | Consequence |
|---------|-------------|
| Running in main repo | Script installs hook only — no worktree setup needed |
| Skipping onboarding | Serena may point to wrong project (main repo or parent dir) |
| `.serena/project.yml` not committed to git | Worktrees won't have it after checkout — script warns and copies as workaround |
