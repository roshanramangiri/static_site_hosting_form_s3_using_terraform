#Create s3 bucket
resource "aws_s3_bucket" "s3_ppt" {
  bucket = "www.roshanramangiri.com.np"
}

#Making the bucket owner the owner of the every file uploaded in the bucket
resource "aws_s3_bucket_ownership_controls" "s3_ppt_own" {
  bucket = aws_s3_bucket.s3_ppt.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#to allow public access
resource "aws_s3_bucket_public_access_block" "s3_ppt_pab" {
  bucket = aws_s3_bucket.s3_ppt.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#allowing everyone to acces the file through the internet
resource "aws_s3_bucket_acl" "s3_ppt_acl" {
  depends_on = [ aws_s3_bucket_ownership_controls.s3_ppt_own,aws_s3_bucket_public_access_block.s3_ppt_pab ]
  bucket = aws_s3_bucket.s3_ppt.id

  acl    = "public-read"
}


#Enabling static website feature
resource "aws_s3_bucket_website_configuration" "s3_ppt_conf" {
  bucket = aws_s3_bucket.s3_ppt.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

#This is the policy to grant public read access to the files inside bucket
data "aws_iam_policy_document" "website_policy" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"
    principals {
      identifiers =  [ "*" ]
      type = "AWS"
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::www.roshanramangiri.com.np/*",
    ]
  }
}

#Attaching the policy to the bucket
resource "aws_s3_bucket_policy" "s3_ppt_policy" {
  bucket = aws_s3_bucket.s3_ppt.id
  policy = data.aws_iam_policy_document.website_policy.json
}