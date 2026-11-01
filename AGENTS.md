# Agent Guidelines

## Language

- Write everything in English: pull request titles and descriptions, commit messages, code comments, README files, and other documentation.

## Pull requests

- Use the [Conventional Commits](https://www.conventionalcommits.org/) format for PR titles, e.g. `feat: add helm to development environment`, `fix: correct docker group membership`, `docs: add agent guidelines`.
- Create a separate PR for each distinct task. Do not mix unrelated changes in one PR.
- PRs may be stacked on top of each other when a task depends on another one. In that case, set the base branch to the branch of the PR it builds on.
- Follow the repository's pull request template if one exists.
