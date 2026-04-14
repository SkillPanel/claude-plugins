---
name: jdtls-lombok-fix
description: Use this skill whenever JDTLS diagnostics contain false-positive Lombok errors — `log cannot be resolved` (@Slf4j), `The method builder() is undefined` (@Builder), `The method getX() is undefined` (@Getter/@Data), `The blank final field X may not have been initialized` (@RequiredArgsConstructor/@AllArgsConstructor) — especially when they appear in `<new-diagnostics>` system reminders after tool calls in Java projects. The underlying cause is that Claude Code's bundled `jdtls-lsp` plugin launches JDTLS without Lombok's javaagent, so the language server never sees generated code. This skill checks whether the documented workaround (patch `marketplace.json` to pass `--jvm-arg=-javaagent:lombok.jar`, see anthropics/claude-plugins-official#1000) is already applied; if not, it finds the newest Lombok jar in `~/.m2` and applies the patch automatically. Trigger proactively whenever you see these signatures even if the user doesn't explicitly ask — the noise distracts from real review work and blocking the fix costs nothing once compilation is confirmed green. Do NOT trigger when `mvn compile`/`gradle build` also reports the same errors (those are real), or for non-Java diagnostic noise.
---

# jdtls-lombok-fix

Claude Code's `jdtls-lsp` plugin starts Eclipse JDT LS without the Lombok
javaagent. Lombok's compile-time magic (`@Slf4j`, `@Getter`, `@Builder`,
`@RequiredArgsConstructor`, `@Data`, …) never gets applied inside JDTLS, so
every Lombok-using class lights up with false errors in the language server's
diagnostics — while Maven/Gradle compile just fine because they have Lombok
on the annotation-processor path.

The noise is indistinguishable from real compile errors unless you know the
fingerprint, and it distracts from actual code review. This skill applies the
workaround documented in
<https://github.com/anthropics/claude-plugins-official/issues/1000>:
patch `~/.claude/plugins/marketplaces/claude-plugins-official/.claude-plugin/marketplace.json`
so that the `jdtls-lsp` plugin starts JDTLS with
`--jvm-arg=-javaagent:<lombok.jar>`.

## Preconditions

Run this ONLY when both are true:

1. You've seen one or more diagnostics matching the Lombok fingerprint below.
2. The build tool (Maven/Gradle) is not also reporting those errors. If you
   haven't run a build recently, do `./mvnw compile -Dskip.npm -q` (adapt to
   the project) and confirm it succeeds. If it fails, the errors are real —
   do NOT apply this patch; fix the code instead.

### Lombok fingerprint

| Diagnostic message                                                    | Likely annotation                     |
|-----------------------------------------------------------------------|---------------------------------------|
| `log cannot be resolved` (often JDT code `[570425394]`)               | `@Slf4j`, `@Log4j2`, `@Log`, `@CommonsLog` |
| `The method builder() is undefined for the type X`                    | `@Builder`, `@SuperBuilder`           |
| `The method getX() / setX() is undefined for the type Y`              | `@Getter`, `@Setter`, `@Data`, `@Value` |
| `The blank final field X may not have been initialized` (`[33554513]`)| `@RequiredArgsConstructor`, `@AllArgsConstructor`, `@Data` |
| `The constructor X(...) is undefined`                                 | `@RequiredArgsConstructor`, `@AllArgsConstructor`, `@NoArgsConstructor` |
| `The method toBuilder() is undefined`                                 | `@Builder(toBuilder=true)`            |

The fingerprint is cumulative — one hit is suggestive, two or more across
different files is near-certain.

## Procedure

1. Run the idempotent patch script. It handles all cases internally (already
   patched, missing jar, missing plugin) and prints a single status line.

   ```bash
   python3 ~/.claude/skills/jdtls-lombok-fix/scripts/apply_patch.py
   ```

2. Interpret the output:

   | Output                         | Meaning / next step                                                                                                   |
   |--------------------------------|-----------------------------------------------------------------------------------------------------------------------|
   | `already-patched`              | Nothing to do. The current diagnostic noise may have a different cause — investigate without this skill.              |
   | `patched: <path-to-lombok.jar>`| Patch applied. Tell the user to restart the Claude Code session (or reload the window) so JDTLS picks up the javaagent. Also warn them that plugin updates overwrite this patch — issue #1000 tracks the upstream fix. |
   | `no-lombok-jar`                | No Lombok jar in `~/.m2/repository/org/projectlombok/lombok/*/`. Ask the user to run `./mvnw dependency:resolve` (or equivalent) so Maven populates the local repo, then rerun the skill. |
   | `marketplace-missing`          | The `jdtls-lsp` plugin isn't installed in the expected location. Skip — nothing to patch. Mention this to the user so they can install the plugin if they want Java LSP support. |

## Why this exists

Keeping the skill lean: the hard part is recognising that the errors are
Lombok-shaped rather than real, and knowing the upstream issue + exact
workaround. The script is short but wraps up the brittle bits (finding the
latest jar, idempotent JSON editing, safe backup) so the main agent can act
with a single command once it recognises the pattern.

## Scope

- Targets the `jdtls-lsp` plugin bundled with Claude Code's official
  marketplace. If the user uses a different Java LSP (e.g. a custom LSP
  config in their own `settings.json`), the fix path is different — don't
  use this skill blindly; tell them about the `--jvm-arg` flag and let them
  wire it up.
- Does NOT fix other JDTLS gaps (e.g. missing Kotlin support, MapStruct,
  Spring native image). The fingerprint check keeps it from overreaching.
