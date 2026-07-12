## Tool Use
If you plan to use openspec, please use `bunx @fission-ai/openspec`.

## File operations

Prefer git commands for file operations on tracked files:
- `git mv <src> <dst>` instead of `mv` for renaming/moving
- `git rm <file>` instead of `rm` for deleting
- `git rm -r <dir>` instead of `rm -rf` for deleting directories

Use plain `mv`/`rm` only for untracked files (e.g. build artifacts, temp files).

# Git snapshots
Commit every stable, working state o git as a snapshot, so we always have a known-good point to recover from. Whenever the code is in a verified working state (builds, test pass, feature work), make a commit before moving on to the next change.
