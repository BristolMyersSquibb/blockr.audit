test_that("new_audit_extension creates valid extension", {
  ext <- new_audit_extension()
  expect_s3_class(ext, "audit_extension")
  expect_s3_class(ext, "dock_extension")
})

test_that("new_audit_extension accepts a log", {
  log <- new_audit_log(list(
    new_audit_entry("block_add", block_id = "a")
  ))
  ext <- new_audit_extension(log = log)
  expect_s3_class(ext, "audit_extension")
})

test_that("extension_block_callback method exists", {
  ext <- new_audit_extension()
  cb <- extension_block_callback(ext)
  expect_type(cb, "closure")
})
