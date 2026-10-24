# aws-learning repo

Learning projects for AWS and Infrastructure as Code (Terraform). The owner is a junior DevOps engineer learning from scratch. The global `~/CLAUDE.md` has the account details; this file has the rules for working inside this repo.

## No guessing: research first (critical)

- Never guess or answer from memory alone. Read the actual files, run read-only commands to check real state, and use the official docs (AWS, Terraform provider) before answering.
- Say where each claim came from (file, command output, doc page).
- If it can't be verified, say "I don't know" or "unverified". Never fill the gap with a plausible answer.

## Safety (critical)

- Only use the `personal` AWS profile. Never touch `default` or any work profile.
- Every Terraform `provider "aws"` block must pin `profile = "personal"` and `allowed_account_ids = ["165811308370"]`.
- Region is `eu-north-1`.
- Before creating resources, run `aws sts get-caller-identity --profile personal` and confirm the account is `165811308370`.
- Never commit secrets, access keys, tokens or `*.tfstate` files. Check `.gitignore` before adding new file types.

## Git workflow

- `main` is protected by a GitHub ruleset (`protect-main`): no deletion, no force push, changes only through PRs. Never try to push to `main` directly.
- One branch per project: `project/NN-name` (e.g. `project/01-ask-the-cloud`). Commit each stage on that branch and open a single PR to `main` when the project is done.
- Push with `GIT_TERMINAL_PROMPT=0 git push` (auth is a fine-grained PAT for `Salmusawi` in the Keychain).
- Local git email is the personal one. Don't change it.
- Commit or push only when asked.

## Project layout

- One folder per project: `NN-name/`, with its own `README.md` holding the stage plan and progress. Read it first when resuming a project.
- Terraform files per project: `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`. Add more files (e.g. `lambda.tf`) per concern when `main.tf` gets long.
- Explain in comments why something exists, not just what it does. The code is for learning.

## How to work with the owner

- Teach while doing: explain commands and code, don't just run things.
- The owner has ADHD. Keep explanations short and structured: one-sentence summary first, then small labelled chunks, tables and diagrams where they help, and a few key points to remember at the end. Avoid walls of text.
- Run `terraform plan` and walk through the output before any `terraform apply`. Apply only when asked.
- Remind about `terraform destroy` when a project is finished, to avoid cost.
