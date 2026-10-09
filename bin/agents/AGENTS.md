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
- Always check if changelogs or documentation need to updated.

## Writing Style

- End bulleted sentences with a period.
- Do not use emdashes.

## Git Behavior

- Always check the branch before starting development.
- Never write code on main or master.
- Always git fetch before creating a new branch.
- Always set new branches to track the default branch. For example: `git checkout -b jaymirecki/134-new-branch origin/main`.
- When creating a feature branch, name it based on the following template `<GIT_USERNAME>/<ISSUE-NUMBER>-<FEATURE-DESCRIPTION>`. For example: `jaymirecki/12-add-playwright-tests`.
- Always use conventional commits, unless the repo's own conventions specify otherwise.
- When creating a GitHub pull request, check for a PR template first with `gh repo view --json pullRequestTemplates`, and write the description to match the template's structure if one exists.

## Package Management

- Always attempt to infer the correct package manager for a repository. For example, if a repo contains javascript and a package-lock.json file, then it probably uses npm instead of yarn.

## Command Running

- Prefer Justfile as a command runner. If a repo has a Justfile, use `just` commands instead of invoking npm/uv/etc directly, unless the repo's own conventions specify otherwise.

## Context Driven Development

Context Driven Development is an AI software engineering methodology that treats persistent project context as a first-class managed artifact. The core principal is that _ephemeral chat is a terrible way to build software with AI_. Important context (like architecture decisions, tech stacks, workflows) should live alongside code so that it's available context.

To enable Context Driven Development, documentation should adhere to the following rules:
- Level of concept:
    - Something you would explain to a new engineer.
    - Something you would draw on a whiteboard as technical architecture.
- Tone:
    - Guiding. Explain what one _should_ do. Explain what is important, core, where to put things.
    - More like an architecture doc, with pointers at code.
    - Do not replay the codebase.
- Audience:
    - Explains present day codebase as it is now.
    - Oriented towards coding tasks: technical architecture, where to put code, APIs to use, service contracts, what to do or not to do.
- Linked from AGENTS.md:
    - "Read this when...".
    - Do not link directly with @ symbol. (This will bloat the agent's context window.)
- Iterate:
    - If context is missing, if the wrong decisions are made, update the docs to provide the correct guidance.
