# ---------------------------------------------------------------------------
# Stage 1: a public S3 bucket that serves site/index.html as a website
# ---------------------------------------------------------------------------

# A "data source" READS something that already exists (it creates nothing).
# Here: who am I logged in as? We use the account ID to make the bucket name unique.
data "aws_caller_identity" "current" {}

# The bucket itself. Bucket names are global across ALL AWS customers,
# so adding the account ID avoids "name already taken" errors.
resource "aws_s3_bucket" "site" {
  bucket = "${var.project_name}-site-${data.aws_caller_identity.current.account_id}"

  # Lets `terraform destroy` delete the bucket even if it still has files in it.
  # Handy for learning; in production you'd usually leave this off.
  force_destroy = true
}

# Turn on S3's static website hosting and say which file is the home page.
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

# New buckets block all public access by default. A website must be public,
# so we allow a public bucket POLICY but keep the older ACL mechanism blocked.
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

# The policy document: "anyone (*) may read (GetObject) any file in this bucket".
# Read-only: nobody else can upload or delete.
data "aws_iam_policy_document" "public_read" {
  statement {
    sid       = "PublicReadGetObject"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

# Attach that policy to the bucket.
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.public_read.json

  # Terraform normally works out the order itself from references, but here
  # there is no reference between the two, so we tell it explicitly:
  # unblock public policies first, otherwise AWS rejects this policy.
  depends_on = [aws_s3_bucket_public_access_block.site]
}

# Upload the web page. `etag = filemd5(...)` makes Terraform re-upload
# whenever the file's content changes.
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/site/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/site/index.html")
}
