#' Audit log entry
#'
#' Creates a single audit log entry recording a board event.
#'
#' @param event Character string describing the event type (e.g.,
#'   `"block_add"`, `"block_remove"`, `"link_add"`, `"param_change"`,
#'   `"block_error"`, `"block_success"`).
#' @param block_id Optional block identifier related to the event.
#' @param details Optional named list of additional metadata.
#' @param timestamp Timestamp string; defaults to current time.
#' @param user Optional user identifier.
#'
#' @return A list with class `"audit_entry"`.
#' @rdname audit_log
#' @export
new_audit_entry <- function(
  event,
  block_id = NULL,

  details = list(),
  timestamp = timestamp_now(),
  user = Sys.getenv("USER", "unknown")
) {
  structure(
    list(
      event = event,
      block_id = block_id,
      details = details,
      timestamp = timestamp,
      user = user
    ),
    class = "audit_entry"
  )
}

#' @rdname audit_log
#' @param x Object to test.
#' @export
is_audit_entry <- function(x) {
  inherits(x, "audit_entry")
}

#' Audit log
#'
#' A container for audit trail entries. The log is stored as a reactive value
#' internally and can be converted to a data frame for display/export.
#'
#' @param entries Optional list of `audit_entry` objects to initialise with.
#'
#' @return A list with class `"audit_log"`.
#' @rdname audit_log
#' @export
new_audit_log <- function(entries = list()) {
  structure(
    list(entries = entries),
    class = "audit_log"
  )
}

#' @rdname audit_log
#' @export
is_audit_log <- function(x) {
  inherits(x, "audit_log")
}

#' Append an entry to an audit log
#'
#' @param log An `audit_log` object.
#' @param entry An `audit_entry` object.
#'
#' @return The updated `audit_log`.
#' @export
append_entry <- function(log, entry) {
  stopifnot(is_audit_log(log), is_audit_entry(entry))
  log$entries <- c(log$entries, list(entry))
  log
}

#' Convert audit log to data frame
#'
#' @param x An `audit_log` object.
#' @param ... Ignored.
#'
#' @return A `data.frame` with columns: `timestamp`, `event`, `block_id`,
#'   `user`, `details`.
#' @export
as.data.frame.audit_log <- function(x, ...) {
  if (length(x$entries) == 0L) {
    return(data.frame(
      timestamp = character(),
      event = character(),
      block_id = character(),
      user = character(),
      details = character(),
      stringsAsFactors = FALSE
    ))
  }

  data.frame(
    timestamp = vapply(x$entries, `[[`, character(1L), "timestamp"),
    event = vapply(x$entries, `[[`, character(1L), "event"),
    block_id = vapply(
      x$entries,
      function(e) if (is.null(e$block_id)) NA_character_ else e$block_id,
      character(1L)
    ),
    user = vapply(x$entries, `[[`, character(1L), "user"),
    details = vapply(
      x$entries,
      function(e) {
        if (length(e$details) == 0L) return("")
        paste(
          names(e$details),
          vapply(e$details, function(d) paste(as.character(d), collapse = ", "), character(1L)),
          sep = "=",
          collapse = "; "
        )
      },
      character(1L)
    ),
    stringsAsFactors = FALSE
  )
}

#' Serialise / deserialise audit log
#'
#' @param x An `audit_log` object.
#' @param data Serialised list representation.
#' @param ... Ignored.
#'
#' @return For `blockr_ser`: a serialisable list. For `blockr_deser`: an
#'   `audit_log` object.
#' @rdname audit_log_ser
#' @exportS3Method blockr.core::blockr_ser audit_log
blockr_ser.audit_log <- function(x, ...) {
  list(
    object = "audit_log",
    entries = lapply(x$entries, function(e) {
      list(
        event = e$event,
        block_id = e$block_id,
        details = e$details,
        timestamp = e$timestamp,
        user = e$user
      )
    })
  )
}

#' @rdname audit_log_ser
#' @exportS3Method blockr.core::blockr_deser audit_log
blockr_deser.audit_log <- function(x, data, ...) {
  entries <- lapply(data$entries, function(e) {
    new_audit_entry(
      event = e$event,
      block_id = e$block_id,
      details = if (is.null(e$details)) list() else as.list(e$details),
      timestamp = e$timestamp,
      user = if (is.null(e$user)) "unknown" else e$user
    )
  })
  new_audit_log(entries)
}
