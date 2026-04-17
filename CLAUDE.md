# Defang GitHub Action

A composite GitHub Action that deploys Docker Compose applications using the Defang CLI.

---

## Architecture

This is a **composite action** (`action.yaml`) — pure shell steps, no compiled code. The action:

1. Installs the Defang CLI (from release or builds from source for Git refs)
2. Sets environment variables for provider, stack, and project
3. Logs in to Defang via OIDC (`id-token: write` permission)
4. Optionally sets config values from GitHub Secrets
5. Runs the specified Defang command (default: `compose up`)

### Key Files

| File | Purpose |
|------|---------|
| `action.yaml` | Action definition — inputs, outputs, and all composite steps |
| `test/` | Test fixtures (compose.yaml, Dockerfile, index.js) |
| `.github/workflows/test.yaml` | CI — runs the action against test fixtures |
| `.github/workflows/release.yaml` | Release — updates floating tags (v2, v2.1) on semver push |
| `README.md` | User-facing documentation with usage examples |

---

## Development

### Making Changes

All logic lives in `action.yaml`. There is no build step — changes to the YAML are immediately effective.

When modifying action inputs/outputs:
- Update `action.yaml` (the `inputs:` / `outputs:` sections)
- Update `README.md` to document the change
- Update `test.yaml` if the new input needs test coverage

### Testing

CI runs on every PR and push to main via `.github/workflows/test.yaml`. The test workflow:
- Uses the action from the current branch (`uses: ./`)
- Tests with nightly CLI, from-source CLI build, and default CLI
- Exercises config vars, compose files, and verbose mode
- Runs a teardown step to clean up config

There is no local test framework — testing happens via GitHub Actions CI.

### Releasing

Releases use semver tags (`v1.2.3`). The release workflow:
1. Validates the tag format
2. Updates floating major/minor tags (e.g., `v2`, `v2.1` point to `v2.1.0`)
3. Creates a GitHub Release with auto-generated notes

To release: push a semver tag (e.g., `git tag v2.1.0 && git push origin v2.1.0`).

---

## Conventions

- **Shell scripting**: All steps use `bash`. Use `set -o pipefail` for commands with pipes.
- **Input handling**: Check inputs with `[ -n "${{ inputs['name'] }}" ]` patterns.
- **Action pinning**: Pin third-party actions to full commit SHAs with version comments.
- **Permissions**: The action requires `contents: read` and `id-token: write` (for OIDC login).
- **Commits**: Follow conventional commits — `feat:`, `fix:`, `docs:`, `chore:`.

### Security

- Never log secrets or config values
- The action uses OIDC for authentication — no long-lived tokens
- Config values are passed as environment variables, not command-line arguments
- Pin all `uses:` references to commit SHAs

---

## SAM Workflows

When running inside SAM (detected by `$SAM_WORKSPACE_ID`):

- **Ephemeral environment**: This workspace is a temporary VM. Unpushed work is lost when the workspace stops. Commit and push after every meaningful change.
- **Progress reporting**: Use `update_task_status` after completing changes (e.g., "updated action inputs", "CI passing").
- **Cross-repo coordination**: Changes here may need corresponding updates in the CLI repo (`DefangLabs/defang`). Use `dispatch_task` to coordinate rather than trying to modify both repos in one workspace.
- **Ideas**: Use `create_idea` for improvements noticed but out of scope (e.g., "add DigitalOcean to README providers list").
- Do NOT launch `claude` as a subprocess — use SAM's task dispatch instead.
- **Knowledge graph**: SAM maintains persistent knowledge across sessions. Use `add_knowledge` to store non-obvious observations about user preferences (entityType: `preference`), conventions (entityType: `style`), or project context like deprecations and ongoing initiatives (entityType: `context`). Use `search_knowledge` before key decisions. Use `update_knowledge`/`remove_knowledge` to fix stale observations, and `confirm_knowledge` when you verify one is still accurate. Do NOT store patterns derivable from the code, git history, or anything already in CLAUDE.md.
