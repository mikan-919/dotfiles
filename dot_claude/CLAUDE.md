## Tool Use
If you plan to use openspec, please use `bunx @fission-ai/openspec`.

## File operations

Prefer git commands for file operations on tracked files:
- `git mv <src> <dst>` instead of `mv` for renaming/moving
- `git rm <file>` instead of `rm` for deleting
- `git rm -r <dir>` instead of `rm -rf` for deleting directories

Use plain `mv`/`rm` only for untracked files (e.g. build artifacts, temp files).

## Working-copy snapshots

Use Jujutsu to preserve the working copy. In a Git repository that is not yet managed by Jujutsu, run `jj git init --colocate` once.

Before returning control to the user, run `jj status`. Jujutsu snapshots the working copy whenever a command runs, so the work is preserved even when it is incomplete. A clean Git worktree or a WIP commit is not required.

Use `jj status` for routine in-progress snapshots. These snapshots may remain only in Jujutsu's operation history and do not need to appear as separate Git commits.

When a meaningful, verified unit of work is complete, preserve it in the commit history before continuing:

```sh
jj describe -m "<summary>"
jj new
```

This keeps lightweight intermediate snapshots out of the pushed Git history while retaining meaningful milestones as commits.

# Japanese Output Rule
修飾表現禁止
日本で広く浸透している訳語が存在する語の英化禁止
技術的事項は注釈を付け背景や詳細を説明
過度な改行の使用禁止
