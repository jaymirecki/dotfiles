# Global Context

## Coding Style

- Write well documented code.
- Write well modularized code.

## Coding Loop

- Ask for clarification if any instructions are unclear.
- Confirm all design and implementation decisions.
- Always run linters and tests after making changes. If they fail, troubleshoot the issue.
- If linting or tests fail then changes are incomplete.
- Always consider adding testing for new code.

## Writing Style

- End bulleted sentences with a period.
- Do not use emdashes.

## Git Behavior

- Always check the branch before starting development.
- Never write code on main or master.
- Always git fetch before creating a new branch.
- Always set new branches to track the default branch. For example: `git checkout -b jaymirecki/134-new-branch origin/main`.
- When creating a feature branch, name it based on the following template `<GIT_USERNAME>/<ISSUE-NUMBER>-<FEATURE-DESCRIPTION>`. For example: `jaymirecki/12-add-playwright-tests`.
- Always use conventional commits.

## Package Management

- Always attempt to infer the correct package manager for a repository. For example, if a repo contains javascript and a package-lock.json file, then it probably uses npm instead of yarn.