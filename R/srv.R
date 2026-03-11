audit_ext_srv <- function(log) {
  function(id, board, update, dock, actions, ...) {
    moduleServer(
      id,
      function(input, output, session) {
        audit_log <- reactiveVal(
          if (is.null(log)) new_audit_log() else log
        )

        record <- function(event, block_id = NULL, details = list()) {
          entry <- new_audit_entry(
            event = event,
            block_id = block_id,
            details = details
          )
          audit_log(append_entry(audit_log(), entry))
        }

        update_observer(update, record)

        filtered_log <- reactive({
          log_df <- as.data.frame(audit_log())
          flt <- input$filter_event
          if (is.null(flt) || identical(flt, "all")) return(log_df)
          log_df[log_df$event == flt, , drop = FALSE]
        })

        output$log_table <- renderTable({
          df <- filtered_log()
          if (nrow(df) == 0L) return(df)
          df[rev(seq_len(nrow(df))), , drop = FALSE]
        }, striped = TRUE, hover = TRUE, width = "100%", na = "-")

        observe({
          n <- length(audit_log()$entries)
          label <- paste(n, if (n == 1L) "entry" else "entries")
          session$sendCustomMessage(
            "audit-update-badge",
            list(id = session$ns("entry-count"), label = label)
          )
        })

        observeEvent(input$clear_log, {
          if (isTRUE(getOption("blockr.allow_clear_audit", FALSE))) {
            audit_log(new_audit_log())
          }
        })

        output$export_log <- downloadHandler(
          filename = function() {
            paste0("audit-log-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".json")
          },
          content = function(file) {
            data <- blockr_ser(audit_log())
            writeLines(
              jsonlite::toJSON(data, auto_unbox = TRUE, pretty = TRUE),
              file
            )
          }
        )

        list(
          state = list(
            log = audit_log
          )
        )
      }
    )
  }
}

update_observer <- function(update, record) {
  observeEvent(
    update(),
    {
      upd <- update()

      if (has_length(upd$blocks$add)) {
        for (blk_id in names(upd$blocks$add)) {
          record("block_add", block_id = blk_id, details = list(
            class = class(upd$blocks$add[[blk_id]])[1L]
          ))
        }
      }

      if (has_length(upd$blocks$rm)) {
        for (blk_id in upd$blocks$rm) {
          record("block_remove", block_id = blk_id)
        }
      }

      if (has_length(upd$links$add)) {
        for (i in seq_along(upd$links$add)) {
          lnk <- upd$links$add[[i]]
          record("link_add", details = list(
            from = lnk[["from"]],
            to = lnk[["to"]],
            input = lnk[["input"]]
          ))
        }
      }

      if (has_length(upd$links$rm)) {
        for (lnk_id in upd$links$rm) {
          record("link_remove", details = list(link = lnk_id))
        }
      }

      if (has_length(upd$stacks$add)) {
        for (stk_id in names(upd$stacks$add)) {
          record("stack_add", details = list(stack = stk_id))
        }
      }

      if (has_length(upd$stacks$rm)) {
        for (stk_id in upd$stacks$rm) {
          record("stack_remove", details = list(stack = stk_id))
        }
      }

      if (has_length(upd$stacks$mod)) {
        for (stk_id in names(upd$stacks$mod)) {
          record("stack_modify", details = list(
            stack = stk_id,
            blocks = as.character(upd$stacks$mod[[stk_id]])
          ))
        }
      }
    }
  )
}
