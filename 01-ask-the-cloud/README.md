# 01 · Ask the Cloud

A web page where you type a question and an AI model answers it.

```
Browser → S3 static website → API Gateway (HTTP API) → Lambda (Python) → Amazon Bedrock (Nova Micro)
```

Built in stages on the branch `project/01-ask-the-cloud`. One PR to `main` when all stages are done.

## Progress

| Stage | What | Status |
|---|---|---|
| 1 | S3 static website | ✅ Done (deployed 2026-10-23) |
| 2 | Lambda + API Gateway returning JSON, with throttling | ⬜ Not started |
| 3 | Lambda calls Bedrock, page calls the API (CORS) | ⬜ Not started |
| 4 | Variables/modules, remote state in S3, budget alarm, `terraform destroy` | ⬜ Not started |

## Stage 1 — S3 static website ✅

What exists in AWS (account `165811308370`, `eu-north-1`):

- Bucket `ask-the-cloud-site-165811308370` with static website hosting (`index.html`)
- Public access block: ACLs blocked, bucket policy allowed
- Bucket policy: public `s3:GetObject` only
- Object `index.html` from `site/index.html` (the Ask button is a placeholder)

Learned: `init` / `plan` / `apply`, providers and pinning, resources vs data sources,
references and implicit dependencies, `depends_on`, `etag = filemd5()` for change detection,
outputs, state (`terraform.tfstate`, kept local and out of git), `default_tags`.

## Stage 2 — Lambda + API Gateway ⬜

Goal: `GET /hello` (or `POST /ask` returning a fixed answer) returns JSON from a Python Lambda.

- `lambda/handler.py`: returns `{"answer": "..."}`
- `archive_file` data source zips the code (`*.zip` is git-ignored)
- IAM role for Lambda: trust policy for `lambda.amazonaws.com` + `AWSLambdaBasicExecutionRole` (logs only)
- `aws_cloudwatch_log_group` with short retention (e.g. 7 days) so logs don't pile up
- `aws_apigatewayv2_api` (HTTP API) + Lambda integration + route + `$default` stage with auto-deploy
- **Throttling** on the stage (`default_route_settings`: low `throttling_rate_limit` / `throttling_burst_limit`) so nobody can burn credits
- `aws_lambda_permission` so API Gateway may invoke the function
- Output the API URL; test with `curl`

## Stage 3 — Bedrock ⬜

- Lambda calls `bedrock-runtime` `converse` with model `eu.amazon.nova-micro-v1:0` (tested working)
- Add an IAM policy allowing `bedrock:InvokeModel` on that inference profile and its underlying foundation models only (least privilege)
- Cap `maxTokens` and question length in the handler
- Enable CORS on the HTTP API for the S3 website origin
- Update `site/index.html` to `fetch()` the API and show the answer

## Stage 4 — Make it production-shaped ⬜

- Variables for everything hardcoded, `terraform.tfvars` (git-ignored)
- Split into modules (e.g. `site`, `api`)
- Remote state: S3 backend with native locking (`use_lockfile = true`)
- AWS Budget alarm (email when spend > small threshold)
- `terraform destroy` and rebuild to prove it's reproducible
- Then open the PR `project/01-ask-the-cloud` → `main`

## Commands

```bash
cd ~/Documents/aws-learning/01-ask-the-cloud
aws login --profile personal          # if credentials expired
terraform fmt && terraform plan
terraform apply
```
