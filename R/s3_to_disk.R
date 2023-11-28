s3_obj_to_file <- function(key, version_id, bucket, to, endpoint = NULL, region = NULL) {
  s3 <- paws.storage::s3(endpoint = endpoint, region = region)
  dir_create(path_dir(to))
  s3$download_file(Bucket = bucket, Key = key, Filename = to, VersionId = version_id)
  to
}
