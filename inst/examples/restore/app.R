library(blockr.audit)
library(blockr.core)
library(blockr.dock)

# Demonstrates restoring an audit log from a previous session
previous_log <- new_audit_log(list(
  new_audit_entry(
    event = "block_add",
    block_id = "a",
    details = list(class = "dataset_block"),
    timestamp = "2026-03-01 10:00:00"
  ),
  new_audit_entry(
    event = "block_add",
    block_id = "b",
    details = list(class = "scatter_block"),
    timestamp = "2026-03-01 10:00:05"
  ),
  new_audit_entry(
    event = "link_add",
    details = list(from = "a", to = "b", input = "data"),
    timestamp = "2026-03-01 10:00:10"
  )
))

serve(
  new_dock_board(
    blocks = c(
      a = new_dataset_block("iris"),
      b = new_scatter_block(x = "Sepal.Length", y = "Sepal.Width")
    ),
    links = list(from = "a", to = "b", input = "data"),
    extensions = new_audit_extension(log = previous_log)
  )
)
