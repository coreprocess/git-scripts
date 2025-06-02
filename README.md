# Git Utility Scripts

A small collection of opinionated shell scripts that automate repetitive (and sometimes dangerous!) Git maintenance tasks.

These scripts grew out of day-to-day work at the command line and are shared in the hope that they might save you a few keystrokes—or a late-night panic.

> ⚠️  **Use at your own risk.** Several of the commands below rewrite Git history or perform force-pushes. Make sure you understand what they do before running them against important repositories.

---

## Contents

| Script | What it does |
|--------|--------------|
| `reset-to-remote.sh` | Resets **all** local branches so they exactly match their `origin/*` counterparts while safely stashing & restoring any uncommitted changes. |
| `mirror.sh` | Performs a one-shot `--mirror` clone of a source repository and pushes it to a destination remote—handy for backups or migrations. |
| `prepare-email-mapping.sh` | Scans every commit in a repository and creates/updates an `email-mapping.txt` file containing every unique `name <email>` identity it finds. |
| `rewrite-emails.sh` | Uses [`git-filter-repo`](https://github.com/newren/git-filter-repo) and the `email-mapping.txt` file to rewrite author/committer information across the entire history of a repository. |

---

## Prerequisites

* Bash 4+
* Git 2.20+
* `git-filter-repo` (only required for `rewrite-emails.sh`). Install via:

```bash
pip install git-filter-repo  # or see the upstream repo for other options
```

---

## Quick start

Clone this repository somewhere on your machine and call the scripts via their absolute path (or add it to your `PATH`):

```bash
git clone https://github.com/coreprocess/git-scripts.git
```

Each script is self-contained and prints progress messages as it runs.

---

## Usage

### 1. `reset-to-remote.sh`

Synchronises every local branch with the matching branch on `origin`:

```bash
cd /path/to/repo
/path/to/git-scripts/reset-to-remote.sh
```

What happens:

1. `git fetch --all --prune` pulls the latest state of every remote.
2. Your current branch name is stored.
3. Uncommitted changes (tracked *and* untracked) are stashed.
4. Each local branch is checked out and hard-reset to `origin/<branch>`.
5. Your original branch is checked out again and the stash is popped (if one was created).
6. `git gc --prune=now` cleans up dangling objects.

### 2. `mirror.sh`

Mirror an entire repository—including all refs, branches, tags, and notes—to another remote:

```bash
/path/to/git-scripts/mirror.sh git@github.com:org/source.git git@github.com:org/backup.git
```

A temporary directory is created automatically and removed afterwards.

### 3. `prepare-email-mapping.sh`

Generate or update an `email-mapping.txt` file that will later be consumed by `rewrite-emails.sh`:

```bash
/path/to/git-scripts/prepare-email-mapping.sh https://github.com/org/repo.git

# Edit email-mapping.txt so that each line follows the format
#   Correct Name <correct.email@example.com> <old.email@example.com>
```

The script:

* Performs a `--mirror` clone in a temp directory.
* Extracts all unique author and committer identities.
* Appends any previously unseen identities to `email-mapping.txt` in the current working directory.

### 4. `rewrite-emails.sh`

Rewrite the entire history of a repository using `email-mapping.txt`:

```bash
/path/to/git-scripts/rewrite-emails.sh https://github.com/org/repo.git
```

A safety backup (`<repo>-backup.git`) is created next to a working clone (`<repo>-rewrite.git`). The working clone's history is rewritten and force-pushed back to the original URL.

After verifying everything looks good, you can remove the backup directory.

---

## Recommended author/email replacement workflow

```bash
# 1. Prepare the mapping file
/path/to/git-scripts/prepare-email-mapping.sh <repo-url>

# 2. Edit email-mapping.txt until all identities are mapped to their desired form
cursor email-mapping.txt

# 3. Rewrite history
/path/to/git-scripts/rewrite-emails.sh <repo-url>
```

---

## Contributing

Bug reports and pull requests are welcome! Feel free to open an issue with questions or improvements.

---

## License

This project is released under the MIT License. See `LICENSE` for details. 