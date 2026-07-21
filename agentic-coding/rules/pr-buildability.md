---
trigger: always_on
---

# PR Buildability — Every Commit Must Build

When creating or amending commits in a stacked PR workflow:

## Non-negotiable rule

**Each commit in the stack must compile and pass tests independently.** Never leave broken intermediate states — a reviewer (or CI) checking out any single commit must get a green build.

## After every commit (before moving to the next)

1. Run `./skyrun bin gazelle <package>` if imports/includes changed
2. Run `./skyrun bin code_format --mod` to fix formatting
3. Build the **full subtree**: `bazel build <package>/...` (not just the new target — lint rules and downstream deps need the glob)
4. Run tests across the subtree: `bazel test <package>/...`

## When changing function signatures or constructors

Search the entire subtree for all call sites — **including test files** — and update them in the same commit that changes the signature. Use the subtree build glob to catch any you missed.

## When rebasing or amending

After resolving conflicts or amending a mid-stack commit:
- Rebuild the subtree at that commit before continuing the rebase
- If the rebase involves a conflict resolution, use `git add -u && git rebase --continue` (NOT `git commit --amend`, which amends the previous commit)

## Full reference

See `~/c38_logging_notes/reference/pr-structuring-guide.md` for the complete PR structuring guide including commit scoping, sequencing patterns, revup conventions, and the full pre-upload checklist.
