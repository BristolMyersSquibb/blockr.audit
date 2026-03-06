test_that("new_audit_entry creates valid entry", {
  entry <- new_audit_entry("block_add", block_id = "a")
  expect_true(is_audit_entry(entry))
  expect_equal(entry$event, "block_add")
  expect_equal(entry$block_id, "a")
  expect_type(entry$timestamp, "character")
})

test_that("new_audit_log creates empty log", {
  log <- new_audit_log()
  expect_true(is_audit_log(log))
  expect_length(log$entries, 0L)
})

test_that("append_entry adds entries", {
  log <- new_audit_log()
  entry <- new_audit_entry("block_add", block_id = "a")
  log <- append_entry(log, entry)
  expect_length(log$entries, 1L)
  expect_equal(log$entries[[1L]]$event, "block_add")
})

test_that("as.data.frame works on empty log", {
  log <- new_audit_log()
  df <- as.data.frame(log)
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 0L)
  expect_named(df, c("timestamp", "event", "block_id", "user", "details"))
})

test_that("as.data.frame works with entries", {
  log <- new_audit_log()
  log <- append_entry(log, new_audit_entry(
    "block_add", block_id = "a", details = list(class = "dataset_block")
  ))
  log <- append_entry(log, new_audit_entry(
    "link_add", details = list(from = "a", to = "b")
  ))
  df <- as.data.frame(log)
  expect_equal(nrow(df), 2L)
  expect_equal(df$event, c("block_add", "link_add"))
  expect_true(is.na(df$block_id[2L]))
  expect_match(df$details[1L], "class=dataset_block")
})

test_that("serialisation round-trip preserves log", {
  log <- new_audit_log()
  log <- append_entry(log, new_audit_entry(
    "block_add", block_id = "a", details = list(class = "dataset_block"),
    timestamp = "2026-01-01 12:00:00", user = "testuser"
  ))
  log <- append_entry(log, new_audit_entry(
    "block_error", block_id = "b", details = list(errors = "missing column"),
    timestamp = "2026-01-01 12:01:00", user = "testuser"
  ))

  ser <- blockr_ser(log)
  expect_equal(ser$object, "audit_log")
  expect_length(ser$entries, 2L)

  deser <- blockr_deser(ser)
  expect_true(is_audit_log(deser))
  expect_length(deser$entries, 2L)
  expect_equal(deser$entries[[1L]]$event, "block_add")
  expect_equal(deser$entries[[2L]]$block_id, "b")
  expect_equal(deser$entries[[1L]]$user, "testuser")
})
