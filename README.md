# SkillPanel Claude Plugins

A marketplace of Claude Code plugins from SkillPanel.

## Install the marketplace

```bash
claude plugin marketplace add gh:SkillPanel/claude-plugins
```

Then install individual plugins:

```bash
claude plugin install serena-setup
claude plugin install jdtls-lombok-fix
```

## Plugins

### serena-setup

Makes [Serena MCP](https://github.com/oraios/serena) work in git worktrees.

**Problem:** you use git worktrees to work on multiple branches in parallel. Serena keeps reading and editing files in your main repo — not the worktree you're actually working in.

**What it does:** one slash command — `/serena-setup:serena-setup` — and Serena works in your worktree:

- Copies cache and memories from the main repo (no re-indexing or onboarding)
- Installs a `post-checkout` hook so future worktrees get cache automatically
- Activates the Serena project for the current session

**Usage:** run it once in the main repo to install the post-checkout hook. After that, worktrees created with `claude -w` will have cache ready — just run the slash command to activate the project.

**Prerequisites** (Serena must be set up in the main repo first):

```bash
# 1. Register Serena MCP globally (once):
claude mcp add --scope user serena -- \
  uvx --from git+https://github.com/oraios/serena \
  serena start-mcp-server --context=claude-code --project-from-cwd

# 2. Pre-index the project:
uvx --from git+https://github.com/oraios/serena serena project index --timeout 300

# 3. Run Serena onboarding — start Claude Code and ask "run Serena onboarding".

# 4. Commit project config to git:
git add .serena/project.yml
git commit -m 'chore: track serena config'
```

### jdtls-lombok-fix

Silences false-positive Lombok errors in Claude Code's bundled Java language server.

**Problem:** the official `jdtls-lsp` plugin starts Eclipse JDT LS without Lombok's javaagent, so anything using `@Slf4j`, `@Builder`, `@Getter`, `@Data`, `@RequiredArgsConstructor`, etc. lights up with errors like `log cannot be resolved` or `The method builder() is undefined` — even though Maven/Gradle compile the code cleanly. Upstream: [anthropics/claude-plugins-official#1000](https://github.com/anthropics/claude-plugins-official/issues/1000).

**What it does:** the skill auto-triggers when it sees the Lombok diagnostic fingerprint, runs an idempotent patch that adds `--jvm-arg=-javaagent:<lombok.jar>` to the `jdtls-lsp` plugin's invocation, and tells you to restart the session. It finds the newest Lombok jar in your local `~/.m2/repository` automatically.

**Usage:** no slash command needed — Claude Code picks it up when it sees matching diagnostics. Note that plugin updates to `jdtls-lsp` overwrite the patch; rerun the skill after updating.

## Local development

```bash
git clone https://github.com/SkillPanel/claude-plugins.git
claude --plugin-dir claude-plugins/plugins/serena-setup
# or
claude --plugin-dir claude-plugins/plugins/jdtls-lombok-fix
```

## License

MIT — see [LICENSE](LICENSE) for details.
