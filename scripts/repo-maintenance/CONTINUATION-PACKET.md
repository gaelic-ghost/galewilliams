# Release continuation packet

`scripts/repo-maintenance/release.sh` emits one JSON line with schema
`repo-maintenance-continuation/v1` when a remote release gate needs a
host-native continuation. Consumers must retain the complete packet, wait at
least `minimum_delay_minutes`, then run `resume_command` before any further
release action.

## Fields

- `repository`, `release_tag`, `branch`, and `head_commit` identify the exact
  release state that must still match on resume.
- `pr_number` is a decimal pull-request number once a release PR exists. It is
  the string `pending` before preparation has created one, and `merged` for a
  post-merge publication continuation.
- `phase` is one of `not-started`, `awaiting-branch-visibility`,
  `awaiting-github-state`, `awaiting-pr-checks`, `failed-checks`,
  `changes-requested`, `ready-to-advance`, `awaiting-tag-visibility`, or
  `awaiting-github-release-visibility`.
- `minimum_delay_minutes` is currently `5`. It is a lower bound, not a poll
  interval.
- `resume_command` is the only command consumers should run after the delay.
  It is `prepare` before a PR exists, `inspect` while PR gates settle, and
  `publish` after a merged release needs tag or GitHub-release visibility.
- `advance_command` is the command allowed after a fresh successful
  `resume_command` inspection: `advance` for a release PR, `prepare` before a
  PR exists, and `publish` after merge.

For post-merge phases, `head_commit` is the commit peeled from `release_tag`,
not the currently checked-out branch. The `publish` operation verifies that the
tagged commit is reachable from `origin/main` before it pushes the tag or
creates the GitHub release.
