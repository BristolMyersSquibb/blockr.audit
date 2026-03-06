#' Audit extension
#'
#' Records an audit trail of board operations (block additions/removals,
#' link changes, parameter changes, errors) with timestamps and user metadata.
#'
#' @param log An optional `audit_log` object to restore from a previous
#'   session (or `NULL` to start fresh).
#' @param ... Forwarded to [blockr.dock::new_dock_extension()].
#'
#' @return An `audit_extension` object that extends the dock extension system
#'   for recording and displaying an audit trail.
#' @rdname audit
#' @export
new_audit_extension <- function(log = NULL, ...) {
  blockr.dock::new_dock_extension(
    audit_ext_srv(log),
    audit_ext_ui,
    name = "Audit",
    class = "audit_extension",
    ...
  )
}

#' @importFrom blockr.dock extension_block_callback
#' @export
extension_block_callback.audit_extension <- function(x, ...) {
  function(
    id,
    board,
    update,
    conditions,
    audit_extension,
    ...,
    session = get_session()
  ) {
    audit_log <- audit_extension$state$log

    error_state <- reactiveVal(FALSE)

    n_cnd <- reactive(
      sum(lengths(conditions()$error))
    )

    observeEvent(
      req(n_cnd() > 0L, !error_state()),
      {
        errs <- conditions()$error
        msgs <- vapply(
          errs[lengths(errs) > 0L],
          function(e) paste(vapply(e, function(x) {
            if (inherits(x, "condition")) conditionMessage(x) else as.character(x)
          }, character(1L)), collapse = "; "),
          character(1L)
        )

        entry <- new_audit_entry(
          event = "block_error",
          block_id = id,
          details = list(errors = paste(msgs, collapse = " | "))
        )
        audit_log(append_entry(audit_log(), entry))
        error_state(TRUE)
      }
    )

    observeEvent(
      req(n_cnd() == 0L, error_state()),
      {
        entry <- new_audit_entry(
          event = "block_success",
          block_id = id,
          details = list(resolved = "errors cleared")
        )
        audit_log(append_entry(audit_log(), entry))
        error_state(FALSE)
      }
    )

    NULL
  }
}
