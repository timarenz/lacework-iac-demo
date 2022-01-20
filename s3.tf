resource "aws_s3_bucket" "public" {
  bucket        = "s3-${random_id.id.hex}"
  acl           = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket" "private" {
  bucket        = "s3-${random_id.id.hex}"
  acl           = "public-read"
  force_destroy = true
}
