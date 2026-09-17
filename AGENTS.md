# AGENTS.md

## Working agreement

- **Always commit your changes when you finish a task.** Do not leave
  unrelated work uncommitted in the tree once the task is complete.
- **Rebase when appropriate.** If the branch has drifted from its target
  (or history would be cleaner linear), rebase onto the latest target
  before considering the work done. Prefer rebasing over merge commits.
- **Write commit messages as full, past-tense sentences.** For example,
  `Added test scripts for the distroless image builds.` Use a concise
  subject line and, when it helps, a body explaining the *why*.
- **Use pinentry for the GPG passphrase.** Commits are signed; enter the
  key passphrase in the pinentry prompt when asked, and never disable
  signing. If gpg fails with `cannot open '/dev/tty'`, re-run the commit
  with `git -c gpg.program=/tmp/opencode/gpg-ask commit ...`, which adds
  `--pinentry-mode ask` so pinentry can prompt.

## Project

This is the Dockerize PHP project. Shell code lives under `docker/`
(image `Dockerfile`s, `entrypoint.sh` scripts, and the `grab_files.sh` /
`extract-binaries.sh` helpers) and the PHP tooling lives in `bin/`.

## Tests

Per-commit tests live in `tests/test-<sha>.sh`. Each prints a green
`PASSED` or a red `FAILED` line, and prints `[error]` diagnostics on
failure. Run one directly:

```bash
bash tests/test-<sha>.sh
```
